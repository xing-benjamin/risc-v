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

    localparam OPCODE_WIDTH = 7;

    typedef enum logic[OPCODE_WIDTH-1:0] {
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

    typedef enum logic[2:0] {
        R_type  = 3'b000,
        I_type  = 3'b001,
        S_type  = 3'b010,
        B_type  = 3'b011,
        U_type  = 3'b100,
        J_type  = 3'b101
    } instr_formats_e;

    /*
    typedef struct packed {

    } memreq_t;

    typedef struct packed {

     } memresp_t;
     */
endpackage