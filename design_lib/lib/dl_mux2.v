//--------------------------------------------------------------
/*
   Filename: dl_mux2.v

   Parameterized 2-to-1 multiplexer implementation
*/
//--------------------------------------------------------------

`ifndef __DL_MUX2_V__
`define __DL_MUX2_V__

module dl_mux2 #(
    parameter NUM_BITS = 32
)(
    input  logic [NUM_BITS-1:0]  in0,
    input  logic [NUM_BITS-1:0]  in1,
    input  logic [0:0]           sel,
    output logic [NUM_BITS-1:0]  out
);

    always_comb begin
        case (sel)
            1'd0:   out = in0;
            1'd1:   out = in1;
            default: out = 'x;
        endcase
    end
endmodule

`endif // __DL_MUX2_V__
