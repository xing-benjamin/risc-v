//--------------------------------------------------------------
/*
    Filename: core_types_pkg.sv

    Package containing defines, enums, structs for core RTL.
*/
//--------------------------------------------------------------

package core_types_pkg;

    localparam N_BITS = 32;

    typedef struct packed {
        logic [2:0] alu_opcode;
        logic       aux_sel;
    } alu_op_t;

    typedef enum logic[3:0] {
        ADD = 4'b0000,
        SUB = 4'b0001,
        SLL = 4'b0010,
        SLT = 4'b0100,
        SLTU = 4'b0110,
        XOR = 4'b1000,
        SRL = 4'b1010,
        SRA = 4'b1011,
        OR = 4'b1100,
        AND = 4'b1110
    } alu_op_e;

    typedef struct packed {
        logic [N_BITS-1:0]  pc;
        logic [N_BITS-1:0]  pc_plus_4;
        logic [N_BITS-1:0]  instr
    } F_D_dpath_regs_t;

endpackage