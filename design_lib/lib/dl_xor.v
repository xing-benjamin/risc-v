//--------------------------------------------------------------
/*
    Filename: dl_xor.v

    Paramterized bitwise XOR operation.
*/
//--------------------------------------------------------------

`ifndef __DL_XOR_V__
`define __DL_XOR_V__

module dl_xor #(
    parameter   NUM_BITS = 1
)(
input  logic [NUM_BITS-1:0]       in0,
input  logic [NUM_BITS-1:0]       in1,
output logic [NUM_BITS-1:0]       out
);
    assign out = in0 ^ in1;

endmodule

`endif // __DL_XOR_V__
