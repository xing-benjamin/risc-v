//--------------------------------------------------------------
/*
    Filename: dl_or.v

    Paramterized bitwise OR operation.
*/
//--------------------------------------------------------------

`ifndef __DL_OR_V__
`define __DL_OR_V__

module dl_or #(
    parameter   NUM_BITS = 1
)(
input  logic [NUM_BITS-1:0]       in0,
input  logic [NUM_BITS-1:0]       in1,
output logic [NUM_BITS-1:0]       out
);
    assign out = in0 | in1;

endmodule

`endif // __DL_OR_V__
