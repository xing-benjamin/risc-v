//--------------------------------------------------------------
/*
   Filename: dl_mux8.v

   Parameterized 8-to-1 multiplexer implementation
*/
//--------------------------------------------------------------

`ifndef __DL_MUX8_V__
`define __DL_MUX8_V__

module dl_mux8 #(
    parameter NUM_BITS = 32
)(
    input  logic [NUM_BITS-1:0]  in0,
    input  logic [NUM_BITS-1:0]  in1,
    input  logic [NUM_BITS-1:0]  in2,
    input  logic [NUM_BITS-1:0]  in3,
    input  logic [NUM_BITS-1:0]  in4,
    input  logic [NUM_BITS-1:0]  in5,
    input  logic [NUM_BITS-1:0]  in6,
    input  logic [NUM_BITS-1:0]  in7,
    input  logic [2:0]           sel,
    output logic [NUM_BITS-1:0]  out
);

    always_comb begin
        case (sel)
            3'd0:   out = in0;
            3'd1:   out = in1;
            3'd2:   out = in2;
            3'd3:   out = in3;
            3'd4:   out = in4;
            3'd5:   out = in5;
            3'd6:   out = in6;
            3'd7:   out = in7;
            default: out = 'x;
        endcase
    end
endmodule

`endif // __DL_MUX8_V__
