//--------------------------------------------------------------
/*  
    Filename: dl_rshift_a.v

    Paramterized right arithmetic shifter implementation.
*/
//--------------------------------------------------------------

module dl_rshift_a
#(
    parameter   NUM_BITS = 32,
    localparam  NUM_SHIFT_BITS = $clog2(NUM_BITS)
)(
    input  wire [NUM_BITS-1:0]       in,
    input  wire [NUM_SHIFT_BITS-1:0] shift,
    output wire [NUM_BITS-1:0]       out
);

    wire [NUM_BITS-1:0] mask;
    assign mask = (in[NUM_BITS-1]) ?
                  {NUM_BITS{1'b1}} << (NUM_BITS - shift) :
                  {NUM_BITS{1'b0}};
    assign out = (in >> shift) | mask;

endmodule