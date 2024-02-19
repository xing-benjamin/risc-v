//--------------------------------------------------------------
/*
    Filename: riscv_pkg.sv

    Package containing defines, enums, structs, and classes
    related to RISC-V spec.
*/
//--------------------------------------------------------------

`ifndef __RISCV_PKG_SV__
`define __RISCV_PKG_SV__

package riscv_pkg;

    localparam  OPCODE_LEN = 7;
    localparam  FUNCT3_LEN = 3;

    typedef enum logic[6:0] {
        LUI     = 7'b0110111,
        AUIPC   = 7'b0010111,
        JAL     = 7'b1101111,
        JALR    = 7'b1100111,
        BRANCH  = 7'b1100011,
        LOAD    = 7'b0000011,
        STORE   = 7'b0100011,
        RI      = 7'b0010011, // register-immediate
        RR      = 7'b0110011, // register-register
        FENCE   = 7'b0001111,
        EXCPT   = 7'b1110011
    } opcode_e;

    typedef struct packed {
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
    } opcode_1hot_struct_t;

    typedef enum logic[2:0] {
        R_type  = 3'b000,
        I_type  = 3'b001,
        S_type  = 3'b010,
        B_type  = 3'b011,
        U_type  = 3'b100,
        J_type  = 3'b101,
        NONE_t  = 3'b111
    } instr_formats_e;

    typedef struct packed {
        logic   R_fmt;
        logic   I_fmt;
        logic   S_fmt;
        logic   B_fmt;
        logic   U_fmt;
        logic   J_fmt;
    } instr_fmt_1hot_struct_t;

endpackage

`endif // __RISCV_PKG_SV__
