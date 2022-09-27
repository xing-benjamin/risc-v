//--------------------------------------------------------------
/*  
    Filename: dl_dff.v

    D flip-flop implementation.
*/
//--------------------------------------------------------------

`ifndef __DL_DFF_V__
`define __DL_DFF_V__

module dl_dff (
    input   wire    clk,
    input   wire    d,
    output  reg     q
);

    always @(posedge clk) begin
        q <= d;
    end

endmodule

`endif // __DL_DFF_V__