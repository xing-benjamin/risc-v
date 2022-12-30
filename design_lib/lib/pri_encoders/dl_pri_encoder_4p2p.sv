//--------------------------------------------------------------
/*
   Filename: dl_pri_encoder_4p2p.sv

   Parameterized 4-to-2 priority encoder implementation
*/
//--------------------------------------------------------------

`ifndef __DL_PRI_ENCODER_4P2P_SV__
`define __DL_PRI_ENCODER_4P2P_SV__

module dl_pri_encoder_4p2p #(
    localparam INPUT_WIDTH = 4,
    localparam OUTPUT_WIDTH = $clog2(INPUT_WIDTH)
)(
    input  logic [INPUT_WIDTH-1:0]  in,
    output logic [OUTPUT_WIDTH-1:0] out
);

    always_comb begin
        if      (in[3]) out = 2'd3;
        else if (in[2]) out = 2'd2;
        else if (in[1]) out = 2'd1;
        else            out = 2'd0;
    end

endmodule

`endif // __DL_PRI_ENCODER_4P2P_SV__
