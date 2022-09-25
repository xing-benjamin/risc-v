//--------------------------------------------------------------
/*  
    Filename: dl_reg.v

    Paramterized register implementation.
*/
//--------------------------------------------------------------

module dl_reg
#(
    parameter   NUM_BITS = 1
)(
    input  wire                 clk,
    input  wire [NUM_BITS-1:0]  d,
    output reg  [NUM_BITS-1:0]  q
);

    always @(posedge clk) begin
        q <= d;
    end

endmodule