//--------------------------------------------------------------
/*  Filename: dlib_dff.v

    D-flip flop
*/
//--------------------------------------------------------------

module dlib_dff
(
    input   logic   clk,
    input   logic   d,
    output  logic   q
);

    always @(posedge clk) begin
        q <= d;
    end

endmodule