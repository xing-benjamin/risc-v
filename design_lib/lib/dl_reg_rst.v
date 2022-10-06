//--------------------------------------------------------------
/*  
    Filename: dl_reg_rst.v

    Paramterized register implementation w/ synchronous reset.
*/
//--------------------------------------------------------------

`ifndef __DL_REG_RST_V__
`define __DL_REG_RST_V__

module dl_reg_rst #(
    parameter   NUM_BITS = 32,
    parameter   RST_VAL = 0
)(
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire [NUM_BITS-1:0]  d,
    output reg  [NUM_BITS-1:0]  q
);

    always @(posedge clk) begin
        if (!rst_n) begin
            q <= RST_VAL;
        end else begin
            q <= d;
        end
    end

endmodule

`endif // __DL_REG_RST_V__