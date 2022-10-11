//--------------------------------------------------------------
/*  
    Filename: dl_reg.v

    Paramterized register implementation.
*/
//--------------------------------------------------------------

`ifndef __DL_REG_V__
`define __DL_REG_V__

module dl_reg #(
    parameter   NUM_BITS = 1
)(
    input  logic                clk,
    input  logic [NUM_BITS-1:0] d,
    output logic [NUM_BITS-1:0] q
);

    always @(posedge clk) begin
        q <= d;
    end

endmodule

`endif // __DL_REG_V__