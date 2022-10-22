//--------------------------------------------------------------
/*
    Filename: X_stage.v

    Execute stage top module.
*/
//--------------------------------------------------------------

module X_stage #(
    parameter N_BITS = 32
)(

);

    alu #(
        .N_BITS (N_BITS)
    )(
        .alu_op (),
        .in0    (),
        .in1    (),
        .out    ()
    );

endmodule : X_stage