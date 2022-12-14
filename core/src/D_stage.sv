//--------------------------------------------------------------
/*
    Filename: D_stage.sv

    Decode stage top module.
*/
//--------------------------------------------------------------

import riscv_pkg::*;
import core_types_pkg::*;

module D_stage (
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [N_BITS-1:0]       nxt_instr,
    input  logic [N_BITS-1:0]       pc_in,
    input  logic [N_BITS-1:0]       pc_plus4_in,
    output logic [N_BITS-1:0]       pc_plus4_out,
    output logic [RF_IDX_WIDTH-1:0] rs1,
    output logic [RF_IDX_WIDTH-1:0] rs2,
    input  logic [N_BITS-1:0]       rs1_data,
    input  logic [N_BITS-1:0]       rs2_data,
    input  logic [N_BITS-1:0]       X_bypass,
    input  logic [N_BITS-1:0]       M_bypass,
    input  logic [N_BITS-1:0]       W_bypass,
    input  rf_ctrl_t                X_rf_ctrl_pkt,
    input  rf_ctrl_t                M_rf_ctrl_pkt,
    input  rf_ctrl_t                W_rf_ctrl_pkt,
    input  logic                    nxt_stg_is_dmem_rd,
    output logic [N_BITS-1:0]       op1,
    output logic [N_BITS-1:0]       op2,
    output logic [N_BITS-1:0]       jal_branch_tgt,
    output logic                    jal_vld,
    output ctrl_transfer_t          ctrl_transfer_pkt,
    output alu_op_t                 alu_op,
    output rf_ctrl_t                rf_ctrl_pkt,
    output dmem_req_ctrl_t          dmem_req_ctrl_pkt,
    output logic [N_BITS-1:0]       dmem_store_data,
    input  logic                    vld_in,
    output logic                    vld,
    input  logic                    stall_in,
    output logic                    stall,
    input  logic                    squash_in,
    output logic                    squash
);

    logic [N_BITS-1:0]              instr;
    logic [N_BITS-1:0]              pc;
    logic [OPCODE_LEN-1:0]          opcode;
    logic [FUNCT3_LEN-1:0]          funct3;
    logic [2:0]                     instr_format;
    logic [N_BITS-1:0]              imm;
    alu_op_t                        comp_inst_alu_op;
    opcode_1hot_struct_t            decoded_opcode;
    instr_fmt_1hot_struct_t         decoded_instr_fmt;
    logic [N_BITS-1:0]              op1_raw;
    logic [N_BITS-1:0]              op2_raw;
    logic                           rs1_vld;
    logic                           rs2_vld;
    logic                           gen_stall;
    logic                           gen_squash;
    logic                           vld_raw;

    //////////////////////////////
    //    Pipeline registers    //
    //////////////////////////////
    dl_reg_en_rst #(
        .NUM_BITS   (1)
    ) D_stage_vld_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (vld_in),
        .q          (vld_raw)
    );

    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) D_imem_rsp_instr_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (nxt_instr),
        .q          (instr)
    );

    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) D_pc_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (pc_in),
        .q          (pc)
    );

    dl_reg_en_rst #(
        .NUM_BITS   (32)
    ) D_pc_plus_4_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (pc_plus4_in),
        .q          (pc_plus4_out)
    );

    // Decode source and destination registers
    // In RISC-V, these are always specified in the same bit positions across
    // all instructions to simplify decode logic.
    assign rf_ctrl_pkt.rd = instr[11:7];
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];

    // Decode instruction opcode
    assign decoded_opcode.LUI    = (opcode == riscv_pkg::LUI);
    assign decoded_opcode.AUIPC  = (opcode == riscv_pkg::AUIPC);
    assign decoded_opcode.JAL    = (opcode == riscv_pkg::JAL);
    assign decoded_opcode.JALR   = (opcode == riscv_pkg::JALR);
    assign decoded_opcode.BRANCH = (opcode == riscv_pkg::BRANCH);
    assign decoded_opcode.LOAD   = (opcode == riscv_pkg::LOAD);
    assign decoded_opcode.STORE  = (opcode == riscv_pkg::STORE);
    assign decoded_opcode.RI     = (opcode == riscv_pkg::RI);
    assign decoded_opcode.RR     = (opcode == riscv_pkg::RR);
    assign decoded_opcode.FENCE  = (opcode == riscv_pkg::FENCE);
    assign decoded_opcode.EXCPT  = (opcode == riscv_pkg::EXCPT);

    // Opcode -> instruction format mapping
    always_comb begin
        if      (decoded_opcode.LUI)    instr_format = riscv_pkg::U_type;
        else if (decoded_opcode.AUIPC)  instr_format = riscv_pkg::U_type;
        else if (decoded_opcode.JAL)    instr_format = riscv_pkg::J_type;
        else if (decoded_opcode.JALR)   instr_format = riscv_pkg::I_type;
        else if (decoded_opcode.BRANCH) instr_format = riscv_pkg::B_type;
        else if (decoded_opcode.LOAD)   instr_format = riscv_pkg::I_type;
        else if (decoded_opcode.STORE)  instr_format = riscv_pkg::S_type;
        else if (decoded_opcode.RI)     instr_format = riscv_pkg::I_type;
        else if (decoded_opcode.RR)     instr_format = riscv_pkg::R_type;
        else                            instr_format = riscv_pkg::NONE_t;
    end

    // Decode instruction format
    assign decoded_instr_fmt.R_type = (instr_format == riscv_pkg::R_type);
    assign decoded_instr_fmt.I_type = (instr_format == riscv_pkg::I_type);
    assign decoded_instr_fmt.S_type = (instr_format == riscv_pkg::S_type);
    assign decoded_instr_fmt.B_type = (instr_format == riscv_pkg::B_type);
    assign decoded_instr_fmt.U_type = (instr_format == riscv_pkg::U_type);
    assign decoded_instr_fmt.J_type = (instr_format == riscv_pkg::J_type);

    // Immediate generation
    always_comb begin
        case (instr_format)
            riscv_pkg::I_type: imm = {{21{instr[31]}}, instr[30:20]};
            riscv_pkg::S_type: imm = {{21{instr[31]}}, instr[30:25], instr[11:7]};
            riscv_pkg::B_type: imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            riscv_pkg::U_type: imm = {instr[31:12], 12'b0};
            riscv_pkg::J_type: imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            default: imm = 32'b0;
        endcase
    end

    // ALU op generation
    logic [1:0] alu_op_mux_sel;
    assign alu_op_mux_sel[1] = decoded_opcode.RR | decoded_opcode.RI;
    assign alu_op_mux_sel[0] = decoded_opcode.RI | decoded_opcode.BRANCH;

    dl_mux4 #(
        .NUM_BITS   ($bits(alu_op_t))
    ) alu_op_mux (
        .in0    (core_types_pkg::ALU_OP_ADD),    // default
        .in1    (core_types_pkg::ALU_OP_SUB),    // BRANCH
        .in2    ({funct3, instr[30]}),           // RR
        .in3    ({funct3, instr[30] & |funct3}), // RI
        .sel    (alu_op_mux_sel),
        .out    (alu_op)
    );

    assign jal_vld = vld && decoded_opcode.JAL;

    assign ctrl_transfer_pkt.is_jal = decoded_opcode.JAL;
    assign ctrl_transfer_pkt.is_jalr = decoded_opcode.JALR;
    assign ctrl_transfer_pkt.is_branch = decoded_opcode.BRANCH;
    assign ctrl_transfer_pkt.branch_fn = funct3;
    
    // Register file writeback
    assign rf_ctrl_pkt.wr_en = (decoded_instr_fmt.R_type |
                                decoded_instr_fmt.I_type |
                                decoded_instr_fmt.U_type |
                                decoded_instr_fmt.J_type);

    assign rs1_vld = (decoded_instr_fmt.R_type |
                      decoded_instr_fmt.I_type |
                      decoded_instr_fmt.S_type |
                      decoded_instr_fmt.B_type);

    assign rs2_vld = (decoded_instr_fmt.R_type |
                      decoded_instr_fmt.S_type |
                      decoded_instr_fmt.B_type);

    // Load/store memory access
    assign dmem_req_ctrl_pkt.vld = (decoded_opcode.LOAD | 
                                    decoded_opcode.STORE);
    assign dmem_req_ctrl_pkt.mtype = decoded_opcode.STORE;
    assign dmem_req_ctrl_pkt.len = (funct3[1:0] == 2'b00) ? 2'd1 :
                                   (funct3[1:0] == 2'b01) ? 2'd2 : 2'd0;

    logic [1:0] op1_bypass_mux_sel;
    always_comb begin
        if (rs1 == 5'b0) op1_bypass_mux_sel = 2'b00;
        else if (X_rf_ctrl_pkt.rd == rs1 && X_rf_ctrl_pkt.wr_en && rs1_vld) op1_bypass_mux_sel = 2'b01;
        else if (M_rf_ctrl_pkt.rd == rs1 && M_rf_ctrl_pkt.wr_en && rs1_vld) op1_bypass_mux_sel = 2'b10;
        else if (W_rf_ctrl_pkt.rd == rs1 && W_rf_ctrl_pkt.wr_en && rs1_vld) op1_bypass_mux_sel = 2'b11;
        else op1_bypass_mux_sel = 2'b00;
    end

    logic [N_BITS-1:0]  U_instr_op1;
    assign U_instr_op1 = (decoded_opcode.AUIPC) ? pc : 32'b0;

    // op1 bypass mux
    dl_mux4 #(
        .NUM_BITS   (N_BITS)
    ) op1_bypass_mux (
        .in0    (rs1_data),
        .in1    (X_bypass),
        .in2    (M_bypass),
        .in3    (W_bypass),
        .sel    (op1_bypass_mux_sel),
        .out    (op1_raw)
    );

    logic [1:0] op2_bypass_mux_sel;
    always_comb begin
        if (rs2 == 5'b0) op2_bypass_mux_sel = 2'b00;
        else if (X_rf_ctrl_pkt.rd == rs2 && X_rf_ctrl_pkt.wr_en && rs2_vld) op2_bypass_mux_sel = 2'b01;
        else if (M_rf_ctrl_pkt.rd == rs2 && M_rf_ctrl_pkt.wr_en && rs2_vld) op2_bypass_mux_sel = 2'b10;
        else if (W_rf_ctrl_pkt.rd == rs2 && W_rf_ctrl_pkt.wr_en && rs2_vld) op2_bypass_mux_sel = 2'b11;
        else op2_bypass_mux_sel = 2'b00; 
    end

    // op2 bypass mux
    dl_mux4 #(
        .NUM_BITS   (N_BITS)
    ) op2_bypass_mux (
        .in0    (rs2_data),
        .in1    (X_bypass),
        .in2    (M_bypass),
        .in3    (W_bypass),
        .sel    (op2_bypass_mux_sel),
        .out    (op2_raw)
    );

    assign dmem_store_data = op2_raw;

    dl_mux2 #(
        .NUM_BITS   (N_BITS)
    ) op1_mux (
        .in0    (op1_raw),
        .in1    (U_instr_op1),
        .sel    (decoded_instr_fmt.U_type),
        .out    (op1)
    );

    dl_mux2 #(
        .NUM_BITS   (N_BITS)
    ) op2_mux (
        .in0    (op2_raw),
        .in1    (imm),
        .sel    (!(decoded_opcode.RR)),
        .out    (op2)
    );

    dl_adder #(
        .NUM_BITS   (N_BITS)
    ) jal_branch_tgt_adder (
        .a      (pc),
        .b      (imm),
        .sum    (jal_branch_tgt),
        .cout   ()
    );

    ///////////////////////
    //  Control signals  //
    ///////////////////////
    assign gen_stall = vld && nxt_stg_is_dmem_rd &&  X_rf_ctrl_pkt.wr_en &&
                       ((rs1_vld && rs1 == X_rf_ctrl_pkt.rd) ||
                        (rs2_vld && rs2 == X_rf_ctrl_pkt.rd));
    assign stall = stall_in || gen_stall;

    assign gen_squash = jal_vld;
    assign squash = squash_in || gen_squash;

    assign vld = vld_raw && !gen_stall && !squash_in;

endmodule : D_stage