//--------------------------------------------------------------
/*
    Filename: alu.v

    RV32I arithmetic logic unit.

               |  opcode    aux_sel
       alu_op  |  3  2  1   0
    -----------|--------------------
        ADD    |  0  0  0   0
        SUB    |  0  0  0   1
        SLL    |  0  0  1   0
        SLT    |  0  1  0   0
        SLTU   |  0  1  1   0
        XOR    |  1  0  0   0
        SRL    |  1  0  1   0
        SRA    |  1  0  1   1
        OR     |  1  1  0   0
        AND    |  1  1  1   0
*/
//--------------------------------------------------------------
import core_types_pkg::*;

module alu #(
    parameter N_BITS = 32,
    localparam N_BITS_LOG2 = $clog2(N_BITS)
)(
    input  alu_op_t             alu_op,
    input  logic [N_BITS-1:0]   in0,
    input  logic [N_BITS-1:0]   in1,
    output logic [N_BITS-1:0]   out
);

    //================
    //    ADD, SUB
    //================
    logic [N_BITS-1:0]  add_sub_mux_out;
    logic [N_BITS-1:0]  in1_neg;
    logic [N_BITS-1:0]  alu_adder_sum;
    logic               alu_adder_ovfl;

    // -in1 in two's complement
    assign in1_neg = ~in1 + 1'b1;

    dl_mux2 #(
        .NUM_BITS   (N_BITS)
    ) add_sub_mux (
        .in0    (in1),
        .in1    (in1_neg),
        .sel    (|alu_op), // FIXME BEN: check if this is fine
        .out    (add_sub_mux_out)
    );

    dl_adder #(
        .NUM_BITS   (N_BITS)
    ) alu_adder (
        .a      (in0),
        .b      (add_sub_mux_out),
        .sum    (alu_adder_sum),
        .cout   (alu_adder_ovfl)
    );

    //=================
    //    SLT, SLTU
    //=================
    logic [N_BITS-1:0]  alu_slt_out;
    logic [N_BITS-1:0]  alu_sltu_out;

    assign alu_slt_out = (!in0[N_BITS-1] & in1[N_BITS-1]) ? '0 :
                         (in0[N_BITS-1] & !in1[N_BITS-1]) ? {{(N_BITS-1){1'b0}}, 1'b1} :
                         (alu_adder_sum[N_BITS-1]) ? {{(N_BITS-1){1'b0}}, 1'b1} : '0;
    // FIXME BEN: review this logic
    assign alu_sltu_out = (!alu_adder_ovfl) ? {{(N_BITS-1){1'b0}}, 1'b1} : '0;

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
        .sh_type    (alu_op.aux_sel), // FIXME BEN
        .in         (in0),
        .shamt      (in1[N_BITS_LOG2-1:0]),
        .out        (alu_rshift_out)
    );

    //================
    //  XOR, OR, AND
    //================
    logic [N_BITS-1:0]  alu_xor_out;
    logic [N_BITS-1:0]  alu_or_out;
    logic [N_BITS-1:0]  alu_and_out;

    dl_xor #(
        .NUM_BITS   (N_BITS)
    ) alu_xor (
        .in0         (in0),
        .in1         (in1),
        .out         (alu_xor_out)
    );

    dl_or #(
        .NUM_BITS   (N_BITS)
    ) alu_or (
        .in0         (in0),
        .in1         (in1),
        .out         (alu_or_out)
    );

    dl_and #(
        .NUM_BITS   (N_BITS)
    ) alu_and (
        .in0         (in0),
        .in1         (in1),
        .out         (alu_and_out)
    );

    //================
    // ALU OUTPUT MUX
    //================
    dl_mux8 #(
        .NUM_BITS   (N_BITS)
    ) alu_output_mux (
        .in0    (alu_adder_sum),
        .in1    (alu_lshift_out),
        .in2    (alu_slt_out),
        .in3    (alu_sltu_out),
        .in4    (alu_xor_out),
        .in5    (alu_rshift_out),
        .in6    (alu_or_out),
        .in7    (alu_and_out),
        .sel    (alu_op.alu_opcode),
        .out    (out)
    );

endmodule
