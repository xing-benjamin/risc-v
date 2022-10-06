//--------------------------------------------------------------
/*  
    Filename: alu.v

    RV32I arithmetic logic unit.

       alu_op  |  3  2  1  0
    -----------|--------------
        ADD    |  0  0  0  0
        SUB    |  0  0  0  1
        SLL    |  0  0  1  0
        SLT    |  0  1  0  0
        SLTU   |  0  1  1  0
        XOR    |  1  0  0  0
        SRL    |  1  0  1  0
        SRA    |  1  0  1  1
        OR     |  1  1  0  0
        AND    |  1  1  1  0
*/
//--------------------------------------------------------------

module alu #(
    parameter N_BITS = 32,
    localparam N_BITS_LOG2 = $clog2(N_BITS)
)(
    input  logic [3:0]          alu_op, // FIXME: create alu_op_t struct
    input  logic [N_BITS-1:0]   in0,
    input  logic [N_BITS-1:0]   in1,
    output logic [N_BITS-1:0]   out
);

    //=====================
    // ADD, SUB, SLT, SLTU 
    //=====================
    logic [N_BITS-1:0]  add_sub_mux_out;
    logic [N_BITS-1:0]  in1_neg;
    logic [N_BITS-1:0]  alu_adder_sum;

    // -in1 in two's complement
    assign in1_neg = ~in1 + 1'b1;

    dl_mux2 #(
        .NUM_BITS   (N_BITS)
    ) add_sub_mux (
        .in0    (in1),
        .in1    (in1_neg),
        .sel    (alu_op[0]), // FIXME
        .out    (add_sub_mux_out)
    );

    dl_adder #(
        .NUM_BITS   (N_BITS)
    ) alu_adder (
        .a      (in0),
        .b      (add_sub_mux_out),
        .sum    (alu_adder_sum),
        .cout   () 
    );

    //=================
    //  SLL, SRL, SRA  
    //=================
    logic [N_BITS-1:0] alu_rshift_out;
    logic [N_BITS-1:0] alu_lshift_out;

    dl_lshift #(
        .NUM_BITS   (N_BITS)
    ) alu_lshift (
        .in         (in0),
        .shamt      (in1[N_BITS_LOG2-1:0]),
        .out        (alu_lshift_out)
    );

    dl_rshift #(
        .NUM_BITS   (N_BITS)
    ) alu_rshift (
        .sh_type    (alu_op[0]), // FIXME
        .in         (in0),
        .shamt      (in1[N_BITS_LOG2-1:0]),
        .out        (alu_rshift_out)
    );

    //================
    //  XOR, OR, AND  
    //================


    //================
    // ALU OUTPUT MUX
    //================
    dl_mux8 #(
        .NUM_BITS   (N_BITS)
    ) alu_output_mux (
        .in0    (alu_adder_sum),
        .in1    (alu_lshift_out),
        .in2    (), // TODO: SLT
        .in3    (), // TODO: SLTU
        .in4    (), // TODO: XOR
        .in5    (alu_rshift_out),
        .in6    (), // TODO: OR
        .in7    (), // TODO: AND
        .sel    (alu_op[3:1]),
        .out    (out)
    );

endmodule