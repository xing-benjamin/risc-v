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

    assign opcode = instr[OPCODE_WIDTH-1:0];

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

    assign decoded_opcode.LUI = (opcode == core_types_pkg::LUI);
    assign decoded_opcode.AUIPC = (opcode == core_types_pkg::AUIPC);
    assign decoded_opcode.JAL = (opcode == core_types_pkg::JAL);
    assign decoded_opcode.JALR = (opcode == core_types_pkg::JALR);
    assign decoded_opcode.BRANCH = (opcode == core_types_pkg::BRANCH);
    assign decoded_opcode.LOAD = (opcode == core_types_pkg::LOAD);
    assign decoded_opcode.STORE = (opcode == core_types_pkg::STORE);
    assign decoded_opcode.RI = (opcode == core_types_pkg::RI);
    assign decoded_opcode.RR = (opcode == core_types_pkg::RR);
    assign decoded_opcode.FENCE = (opcode == core_types_pkg::FENCE);
    assign decoded_opcode.EXCPT = (opcode == core_types_pkg::EXCPT);

    // Instruction format decode
    always_comb begin
        case (opcode)
            core_types_pkg::LUI:    instr_format = core_types_pkg::U_type;
            core_types_pkg::AUIPC:  instr_format = core_types_pkg::U_type;
            core_types_pkg::JAL:    instr_format = core_types_pkg::J_type;
            core_types_pkg::JALR:   instr_format = core_types_pkg::I_type;
            core_types_pkg::BRANCH: instr_format = core_types_pkg::B_type;
            core_types_pkg::LOAD:   instr_format = core_types_pkg::I_type;
            core_types_pkg::STORE:  instr_format = core_types_pkg::S_type;
            core_types_pkg::RI:     instr_format = core_types_pkg::I_type;
            core_types_pkg::RR:     instr_format = core_types_pkg::R_type;
            default: instr_format = R_type;
        endcase
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
        ((instr[14:12] == 3'b0 && opcode == core_types_pkg::RR) | (instr[14:12] == 3'b101))
        && instr[30];

    dl_mux2 #(
        .NUM_BITS   ($bits(alu_op_t))
    ) alu_op_mux (
        .in0    (comp_inst_alu_op),
        .in1    (4'b0),
        .sel    (!(opcode == core_types_pkg::RR || opcode == core_types_pkg::RI)),
        .out    (alu_op)
    );

    assign rd = instr[11:7];
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];

    
    assign rf_wr_en = (opcode == core_types_pkg::LUI ||
                       opcode == core_types_pkg::AUIPC ||
                       opcode == core_types_pkg::JAL ||
                       opcode == core_types_pkg::JALR ||
                       opcode == core_types_pkg::LOAD ||
                       opcode == core_types_pkg::RI ||
                       opcode == core_types_pkg::RR);
                       
    //assign rf_wr_en = 1'b1;

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
        .sel    (!(opcode == core_types_pkg::RR)),
        .out    (opB)
    );

endmodule : D_stage