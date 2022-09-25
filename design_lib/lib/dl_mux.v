//--------------------------------------------------------------
/*  
    Filename: dl_mux.v

    Paramterized 2-to-1 multiplexer implementation.
*/
//--------------------------------------------------------------

module dl_mux
#(
    parameter   NUM_BITS = 1
)(
    input  wire [NUM_BITS-1:0]  in0,
    input  wire [NUM_BITS-1:0]  in1,
    input  wire                 sel,
    output wire [NUM_BITS-1:0]  out
);

    assign out = sel ? in1 : in0;

endmodule