//--------------------------------------------------------------
/*  
    Filename: dl_lshift.v

    Paramterized left shifter implementation.
*/
//--------------------------------------------------------------

`ifndef __DL_LSHIFT_V__
`define __DL_LSHIFT_V__

module dl_lshift #(
    parameter   NUM_BITS = 32,
    localparam  NUM_SHIFT_BITS = $clog2(NUM_BITS)
)(
    input  wire [NUM_BITS-1:0]       in,
    input  wire [NUM_SHIFT_BITS-1:0] shamt,
    output wire [NUM_BITS-1:0]       out
);

    assign out = in << shamt;

endmodule

`endif // __DL_LSHIFT_V__