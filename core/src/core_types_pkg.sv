//--------------------------------------------------------------
/*
    Filename: core_types_pkg.sv

    Package containing defines, enums, structs for core RTL.
*/
//--------------------------------------------------------------

`ifndef __CORE_TYPES_PKG_SV__
`define __CORE_TYPES_PKG_SV__

package core_types_pkg;

    localparam N_BITS = 32;
    localparam N_BITS_LOG2 = $clog2(N_BITS);
    localparam RF_N_REGS = 32;
    localparam RF_IDX_WIDTH = $clog2(RF_N_REGS);

    localparam logic [31:0] PC_RESET = 32'hfffffffc;

    typedef struct packed {
        logic [2:0] funct;
        logic       aux_sel;
    } alu_op_t;

    typedef enum logic[2:0] {
        ALU_FN_AS   = 3'b000,
        ALU_FN_SLL  = 3'b001,
        ALU_FN_SLT  = 3'b010,
        ALU_FN_SLTU = 3'b011,
        ALU_FN_XOR  = 3'b100,
        ALU_FN_SR   = 3'b101,
        ALU_FN_OR   = 3'b110,
        ALU_FN_AND  = 3'b111
    } alu_funct_e;

    typedef enum logic[3:0] {
        ALU_OP_ADD  = {ALU_FN_AS, 1'b0},
        ALU_OP_SUB  = {ALU_FN_AS, 1'b1},
        ALU_OP_SLL  = {ALU_FN_SLL, 1'b0},
        ALU_OP_SLT  = {ALU_FN_SLT, 1'b0},
        ALU_OP_SLTU = {ALU_FN_SLTU, 1'b0},
        ALU_OP_XOR  = {ALU_FN_XOR, 1'b0},
        ALU_OP_SRL  = {ALU_FN_SR, 1'b0},
        ALU_OP_SRA  = {ALU_FN_SR, 1'b1},
        ALU_OP_OR   = {ALU_FN_OR, 1'b0},
        ALU_OP_AND  = {ALU_FN_AND, 1'b0}
    } alu_op_e;

    typedef struct packed {
        logic [RF_IDX_WIDTH-1:0]    rd;
        logic                       wr_en;
    } rf_ctrl_t;

    typedef struct packed {
        logic       vld;
        logic       mtype; // 0 = read, 1 = write
        logic [1:0] len;
    } dmem_req_ctrl_t;

    typedef struct packed {
        logic       is_jal;
        logic       is_jalr;
        logic       is_branch;
        logic [2:0] branch_fn;
    } ctrl_transfer_t;

endpackage

`endif // __CORE_TYPES_PKG_SV__
