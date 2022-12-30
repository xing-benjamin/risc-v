//--------------------------------------------------------------
/*
   Filename: dl_mux2.sv

   Parameterized 2-to-1 multiplexer implementation
*/
//--------------------------------------------------------------

`ifndef __DL_MUX2_SV__
`define __DL_MUX2_SV__

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
            default: out = in0;
        endcase
    end
endmodule

`endif // __DL_MUX2_SV__
