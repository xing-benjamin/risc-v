//--------------------------------------------------------------
/*  
    Filename: dl_dff.v

    D flip-flop implementation.
*/
//--------------------------------------------------------------

module dl_dff
(
    input   wire    clk,
    input   wire    d,
    output  reg     q
);

    always @(posedge clk) begin
        q <= d;
    end

endmodule