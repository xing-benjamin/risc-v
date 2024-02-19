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
    input  logic                    vld_in,
    output logic                    vld,
    input  logic                    stall_in,
    output logic                    stall,
    input  logic                    squash_in,
    output logic                    squash,
    input  logic [N_BITS-1:0]       instr,
    input  logic [N_BITS-1:0]       pc,
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
    output logic [N_BITS-1:0]       dmem_store_data
);

    logic [OPCODE_LEN-1:0]          opcode;
    logic [FUNCT3_LEN-1:0]          funct3;
    logic [N_BITS-1:0]              imm;
    alu_op_t                        comp_inst_alu_op;
    opcode_1hot_struct_t            opcode_dec;
    instr_fmt_1hot_struct_t         instr_fmt_dec;
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


    // Decode source and destination registers
    // In RISC-V, these are always specified in the same bit positions across
    // all instructions to simplify decode logic.
    // 31           25 24   20 19   15 14    12 11          7 6      0
    // ================================================================
    // |    funct7    |  rs2  |  rs1  | funct3 |     rd      | opcode |  R-type
    // |      imm[11:0]       |  rs1  | funct3 |     rd      | opcode |  I-type
    // |  imm[11:5]   |  rs2  |  rs1  | funct3 |  imm[4:0]   | opcode |  S-type
    // | imm[12|10:5] |  rs2  |  rs1  | funct3 | imm[4:1|11] | opcode |  B-type
    // |               imm[31:12]              |     rd      | opcode |  U-type
    // |         imm[20|10:1|11|19:12]         |     rd      | opcode |  J-type
    // ================================================================
    assign rf_ctrl_pkt.rd = instr[11:7];
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];

    // Decode instruction opcode
    always_comb begin
        opcode_dec = opcode_1hot_struct_t'(0);
        instr_fmt_dec = instr_fmt_1hot_struct_t'(0);

        // Opcode decode
        case (opcode)
            riscv_pkg::LUI:     opcode_dec.LUI      = 1'b1;
            riscv_pkg::AUIPC:   opcode_dec.AUIPC    = 1'b1;
            riscv_pkg::JAL:     opcode_dec.JAL      = 1'b1;
            riscv_pkg::JALR:    opcode_dec.JALR     = 1'b1;
            riscv_pkg::BRANCH:  opcode_dec.BRANCH   = 1'b1;
            riscv_pkg::LOAD:    opcode_dec.LOAD     = 1'b1;
            riscv_pkg::STORE:   opcode_dec.STORE    = 1'b1;
            riscv_pkg::RI:      opcode_dec.RI       = 1'b1;
            riscv_pkg::RR:      opcode_dec.RR       = 1'b1;
            riscv_pkg::FENCE:   opcode_dec.FENCE    = 1'b1;
            riscv_pkg::EXCPT:   opcode_dec.EXCPT    = 1'b1;
        endcase

        // Instruction format decode
        case (opcode)
            riscv_pkg::LUI:     instr_fmt_dec.U_fmt = 1'b1;
            riscv_pkg::AUIPC:   instr_fmt_dec.U_fmt = 1'b1;
            riscv_pkg::JAL:     instr_fmt_dec.J_fmt = 1'b1;
            riscv_pkg::JALR:    instr_fmt_dec.I_fmt = 1'b1;
            riscv_pkg::BRANCH:  instr_fmt_dec.B_fmt = 1'b1;
            riscv_pkg::LOAD:    instr_fmt_dec.I_fmt = 1'b1;
            riscv_pkg::STORE:   instr_fmt_dec.S_fmt = 1'b1;
            riscv_pkg::RI:      instr_fmt_dec.I_fmt = 1'b1;
            riscv_pkg::RR:      instr_fmt_dec.R_fmt = 1'b1;
        endcase
    end

    // Immediate generation
    always_comb begin
        if      (instr_fmt_dec.I_fmt) imm = {{21{instr[31]}}, instr[30:20]};
        else if (instr_fmt_dec.S_fmt) imm = {{21{instr[31]}}, instr[30:25], instr[11:7]};
        else if (instr_fmt_dec.B_fmt) imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        else if (instr_fmt_dec.U_fmt) imm = {instr[31:12], 12'b0};
        else if (instr_fmt_dec.J_fmt) imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
        else                          imm = 32'b0;
    end

    // ALU op generation
    logic [1:0] alu_op_mux_sel;
    assign alu_op_mux_sel[1] = opcode_dec.RR | opcode_dec.RI;
    assign alu_op_mux_sel[0] = opcode_dec.RI | opcode_dec.BRANCH;

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

    assign jal_vld = vld && opcode_dec.JAL;

    assign ctrl_transfer_pkt.is_jal = opcode_dec.JAL;
    assign ctrl_transfer_pkt.is_jalr = opcode_dec.JALR;
    assign ctrl_transfer_pkt.is_branch = opcode_dec.BRANCH;
    assign ctrl_transfer_pkt.branch_fn = funct3;
    
    // Register file writeback
    assign rf_ctrl_pkt.wr_en = instr_fmt_dec.R_fmt |
                               instr_fmt_dec.I_fmt |
                               instr_fmt_dec.U_fmt |
                               instr_fmt_dec.J_fmt;

    assign rs1_vld = instr_fmt_dec.R_fmt |
                     instr_fmt_dec.I_fmt |
                     instr_fmt_dec.S_fmt |
                     instr_fmt_dec.B_fmt;

    assign rs2_vld = instr_fmt_dec.R_fmt |
                     instr_fmt_dec.S_fmt |
                     instr_fmt_dec.B_fmt;

    // Load/store memory access
    assign dmem_req_ctrl_pkt.vld = (opcode_dec.LOAD | 
                                    opcode_dec.STORE);
    assign dmem_req_ctrl_pkt.mtype = opcode_dec.STORE;
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
    assign U_instr_op1 = (opcode_dec.AUIPC) ? pc : 32'b0;

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
        .sel    (instr_fmt_dec.U_type),
        .out    (op1)
    );

    dl_mux2 #(
        .NUM_BITS   (N_BITS)
    ) op2_mux (
        .in0    (op2_raw),
        .in1    (imm),
        .sel    (!(opcode_dec.RR)),
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
    assign gen_stall = vld_raw && nxt_stg_is_dmem_rd &&  X_rf_ctrl_pkt.wr_en &&
                       ((rs1_vld && rs1 == X_rf_ctrl_pkt.rd) ||
                        (rs2_vld && rs2 == X_rf_ctrl_pkt.rd));
    assign stall = stall_in || gen_stall;

    assign gen_squash = jal_vld;
    assign squash = squash_in || gen_squash;

    assign vld = vld_raw && !gen_stall && !squash_in;

endmodule : D_stage
