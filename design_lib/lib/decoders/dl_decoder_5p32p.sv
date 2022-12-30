//--------------------------------------------------------------
/*
   Filename: dl_decoder_5p32p.sv

   Parameterized 5-to-32 decoder implementation
*/
//--------------------------------------------------------------

`ifndef __DL_DECODER_5P32P_SV__
`define __DL_DECODER_5P32P_SV__

module dl_decoder_5p32p #(
    localparam OUTPUT_WIDTH = 32,
    localparam INPUT_WIDTH = $clog2(OUTPUT_WIDTH)
)(
    input  logic [INPUT_WIDTH-1:0]  in,
    output logic [OUTPUT_WIDTH-1:0] out
);

    always_comb begin
        out = 32'b0;
        case (in)
            5'd0:   out[0] = 1'b1;
            5'd1:   out[1] = 1'b1;
            5'd2:   out[2] = 1'b1;
            5'd3:   out[3] = 1'b1;
            5'd4:   out[4] = 1'b1;
            5'd5:   out[5] = 1'b1;
            5'd6:   out[6] = 1'b1;
            5'd7:   out[7] = 1'b1;
            5'd8:   out[8] = 1'b1;
            5'd9:   out[9] = 1'b1;
            5'd10:   out[10] = 1'b1;
            5'd11:   out[11] = 1'b1;
            5'd12:   out[12] = 1'b1;
            5'd13:   out[13] = 1'b1;
            5'd14:   out[14] = 1'b1;
            5'd15:   out[15] = 1'b1;
            5'd16:   out[16] = 1'b1;
            5'd17:   out[17] = 1'b1;
            5'd18:   out[18] = 1'b1;
            5'd19:   out[19] = 1'b1;
            5'd20:   out[20] = 1'b1;
            5'd21:   out[21] = 1'b1;
            5'd22:   out[22] = 1'b1;
            5'd23:   out[23] = 1'b1;
            5'd24:   out[24] = 1'b1;
            5'd25:   out[25] = 1'b1;
            5'd26:   out[26] = 1'b1;
            5'd27:   out[27] = 1'b1;
            5'd28:   out[28] = 1'b1;
            5'd29:   out[29] = 1'b1;
            5'd30:   out[30] = 1'b1;
            5'd31:   out[31] = 1'b1;
        endcase
    end

endmodule

`endif // __DL_DECODER_5P32P_SV__
