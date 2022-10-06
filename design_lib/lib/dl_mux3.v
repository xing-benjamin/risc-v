//--------------------------------------------------------------
/*
   Filename: dl_mux3.v

   Parameterized 3-to-1 multiplexer implementation
*/
//--------------------------------------------------------------

`ifndef __DL_MUX3_V__
`define __DL_MUX3_V__

module dl_mux3 #(
    parameter NUM_BITS = 32
)(
    input  logic [NUM_BITS-1:0]  in0,
    input  logic [NUM_BITS-1:0]  in1,
    input  logic [NUM_BITS-1:0]  in2,
    input  logic [1:0]           sel,
    output logic [NUM_BITS-1:0]  out
);

    always_comb begin
        case (sel)
            2'd0:   out = in0;
            2'd1:   out = in1;
            2'd2:   out = in2;
            default: out = 'x;
        endcase
    end
endmodule

`endif // __DL_MUX3_V__
