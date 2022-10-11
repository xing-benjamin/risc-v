//--------------------------------------------------------------
/*  
    Filename: dl_reg_en_rst.v

    Paramterized register implementation w/ enable and
    synchronous reset.
*/
//--------------------------------------------------------------

`ifndef __DL_REG_EN_RST_V__
`define __DL_REG_EN_RST_V__

module dl_reg_en_rst #(
    parameter   NUM_BITS = 32,
    parameter   RST_VAL = 0
)(
    input  logic                clk,
    input  logic                rst_n,
    input  logic                en,
    input  logic [NUM_BITS-1:0] d,
    output logic [NUM_BITS-1:0] q
);

    always @(posedge clk) begin
        if (!rst_n) begin
            q <= RST_VAL;
        end else begin
            if (en) begin
                q <= d;
            end
        end
    end

endmodule

`endif // __DL_REG_EN_RST_V__