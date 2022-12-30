//--------------------------------------------------------------
/*  
    Filename: dl_dff.sv

    D flip-flop implementation.
*/
//--------------------------------------------------------------

`ifndef __DL_DFF_SV__
`define __DL_DFF_SV__

module dl_dff (
    input   logic   clk,
    input   logic   d,
    output  logic   q
);

    always @(posedge clk) begin
        q <= d;
    end

endmodule

`endif // __DL_DFF_SV__