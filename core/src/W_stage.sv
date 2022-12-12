//--------------------------------------------------------------
/*
    Filename: W_stage.sv

    Write stage top module.
*/
//--------------------------------------------------------------

module W_stage #(
    parameter N_BITS = 32
)(
    input  logic [N_BITS-1:0]   in_wr_data,
    output logic [N_BITS-1:0]   out_wr_data
);

    assign out_wr_data = in_wr_data;

endmodule : W_stage