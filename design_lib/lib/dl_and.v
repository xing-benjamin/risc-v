//--------------------------------------------------------------
/*
    Filename: dl_and.v

    Paramterized bitwise AND operation.
*/
//--------------------------------------------------------------

`ifndef __DL_AND_V__
`define __DL_AND_V__

module dl_and #(
    parameter   NUM_BITS = 1
)(
input  logic [NUM_BITS-1:0]       in0,
input  logic [NUM_BITS-1:0]       in1,
output logic [NUM_BITS-1:0]       out
);
    assign out = in0 & in1;

endmodule

`endif // __DL_AND_V__
