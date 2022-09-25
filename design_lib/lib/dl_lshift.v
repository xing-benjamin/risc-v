//--------------------------------------------------------------
/*  
    Filename: dl_lshift.v

    Paramterized left shifter implementation.
*/
//--------------------------------------------------------------

module dl_lshift
#(
    parameter   NUM_BITS = 32,
    localparam  NUM_SHIFT_BITS = $clog2(NUM_BITS)
)(
    input  wire [NUM_BITS-1:0]       a,
    input  wire [NUM_SHIFT_BITS-1:0] shift,
    output wire [NUM_BITS-1:0]       out
);

    assign out = a << shift;

endmodule