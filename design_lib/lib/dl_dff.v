//--------------------------------------------------------------
/*  
    Filename: dl_dff.v

    D flip-flop implementation.
*/
//--------------------------------------------------------------

module dl_dff
(
    input   logic   clk,
    input   logic   d,
    output  logic   q
);

    always @(posedge clk) begin
        q <= d;
    end

endmodule