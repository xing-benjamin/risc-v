//--------------------------------------------------------------
/*
    Filename: D_stage.sv

    Decode stage top module.
*/
//--------------------------------------------------------------

import core_types_pkg::*;

module D_stage (
    input  logic [31:0] instr,
    input  logic [31:0] pc,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    output logic [31:0] opA,
    output logic [31:0] opB,
    output alu_op_t     alu_op,
    output logic        rf_wr_en
);

    logic [OPCODE_WIDTH-1:0]    opcode;
    logic [2:0]                 instr_format;
    logic [31:0]                imm;
    alu_op_t                    comp_inst_alu_op;
    struct packed {
        logic   LUI;
        logic   AUIPC;
        logic   JAL;
        logic   JALR;
        logic   BRANCH;
        logic   LOAD;
        logic   STORE;
        logic   RI;
        logic   RR;
        logic   FENCE;
        logic   EXCPT;
    } decoded_opcode;

    // Decode source and destination registers
    // In RISC-V, these are always specified in the same bit positions across
    // all instructions to simplify decode logic.
    assign rd = instr[11:7];
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];

    // Decode instruction opcode
    assign opcode = instr[OPCODE_WIDTH-1:0];

    assign decoded_opcode.LUI    = (opcode == core_types_pkg::LUI);
    assign decoded_opcode.AUIPC  = (opcode == core_types_pkg::AUIPC);
    assign decoded_opcode.JAL    = (opcode == core_types_pkg::JAL);
    assign decoded_opcode.JALR   = (opcode == core_types_pkg::JALR);
    assign decoded_opcode.BRANCH = (opcode == core_types_pkg::BRANCH);
    assign decoded_opcode.LOAD   = (opcode == core_types_pkg::LOAD);
    assign decoded_opcode.STORE  = (opcode == core_types_pkg::STORE);
    assign decoded_opcode.RI     = (opcode == core_types_pkg::RI);
    assign decoded_opcode.RR     = (opcode == core_types_pkg::RR);
    assign decoded_opcode.FENCE  = (opcode == core_types_pkg::FENCE);
    assign decoded_opcode.EXCPT  = (opcode == core_types_pkg::EXCPT);

    // Opcode -> instruction format mapping
    always_comb begin
        if      (decoded_opcode.LUI)    instr_format = core_types_pkg::U_type;
        else if (decoded_opcode.AUIPC)  instr_format = core_types_pkg::U_type;
        else if (decoded_opcode.JAL)    instr_format = core_types_pkg::J_type;
        else if (decoded_opcode.JALR)   instr_format = core_types_pkg::I_type;
        else if (decoded_opcode.BRANCH) instr_format = core_types_pkg::B_type;
        else if (decoded_opcode.LOAD)   instr_format = core_types_pkg::I_type;
        else if (decoded_opcode.STORE)  instr_format = core_types_pkg::S_type;
        else if (decoded_opcode.RI)     instr_format = core_types_pkg::I_type;
        else if (decoded_opcode.RR)     instr_format = core_types_pkg::R_type;
        else                            instr_format = core_types_pkg::NONE_t;
    end

    // Immediate generation
    always_comb begin
        case (instr_format)
            core_types_pkg::I_type: imm = {{21{instr[31]}}, instr[30:20]};
            core_types_pkg::S_type: imm = {{21{instr[31]}}, instr[30:25], instr[11:7]};
            core_types_pkg::B_type: imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            core_types_pkg::U_type: imm = {instr[31:12], 12'b0};
            core_types_pkg::J_type: imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            default: imm = 32'b0;
        endcase
    end

    // ALU op generation
    assign comp_inst_alu_op.alu_opcode = instr[14:12];
    assign comp_inst_alu_op.aux_sel =
        (instr[14:12] == 3'b0 && decoded_opcode.RI) ? 1'b0 : instr[30];

    dl_mux2 #(
        .NUM_BITS   ($bits(alu_op_t))
    ) alu_op_mux (
        .in0    (comp_inst_alu_op),
        .in1    (4'b0),
        .sel    (!(decoded_opcode.RR | decoded_opcode.RI)),
        .out    (alu_op)
    );


    assign rf_wr_en = ( decoded_opcode.LUI |
                        decoded_opcode.AUIPC |
                        decoded_opcode.JAL |
                        decoded_opcode.JALR |
                        decoded_opcode.LOAD |
                        decoded_opcode.RI |
                        decoded_opcode.RR );

    dl_mux2 #(
        .NUM_BITS   (32)
    ) opA_mux (
        .in0    (rs1_data),
        .in1    (pc),
        .sel    (1'b0),
        .out    (opA)
    );

    dl_mux2 #(
        .NUM_BITS   (32)
    ) opB_mux (
        .in0    (rs2_data),
        .in1    (imm),
        .sel    (!(decoded_opcode.RR)),
        .out    (opB)
    );

endmodule : D_stage