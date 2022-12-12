//--------------------------------------------------------------
/*
    Filename: X_stage.sv

    Execute stage top module.
*/
//--------------------------------------------------------------

`include "alu.sv"

module X_stage #(
    parameter N_BITS = 32
)(
    input  alu_op_t             alu_op,
    input  logic [N_BITS-1:0]   in0,
    input  logic [N_BITS-1:0]   in1,
    output logic [N_BITS-1:0]   out
);

    logic [N_BITS-1:0]  alu_out;

    alu #(
        .N_BITS (N_BITS)
    ) alu_inst (
        .alu_op (alu_op),
        .in0    (in0),
        .in1    (in1),
        .out    (alu_out)
    );

    assign out = alu_out;

endmodule : X_stage