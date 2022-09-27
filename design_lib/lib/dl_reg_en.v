//--------------------------------------------------------------
/*  
    Filename: dl_reg_en.v

    Paramterized register implementation w/ enable.
*/
//--------------------------------------------------------------

`ifndef __DL_REG_EN_V__
`define __DL_REG_EN_V__

module dl_reg_en #(
    parameter   NUM_BITS = 1
)(
    input  wire                 clk,
    input  wire                 en,
    input  wire [NUM_BITS-1:0]  d,
    output reg  [NUM_BITS-1:0]  q
);

    always @(posedge clk) begin
        if (en) begin
            q <= d;
        end else begin
            q <= q;
        end
    end

endmodule

`endif // __DL_REG_EN_V__