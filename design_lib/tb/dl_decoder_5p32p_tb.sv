//--------------------------------------------------------------
/*
    Filename: dl_decoder_5p32p_tb.v

    Parameterized 2-to-1 mux Verilog testbench.
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

module dl_decoder_5p32p_tb;

    localparam  OUTPUT_WIDTH = 32;
    localparam  INPUT_WIDTH = $clog2(OUTPUT_WIDTH);

    `SET_SIM_STOP_TIME(500)

    logic [INPUT_WIDTH-1:0]     in;
    logic [OUTPUT_WIDTH-1:0]    out;

    // Instantiate DUT
    dl_decoder_5p32p dl_decoder_5p32p_inst (
        .in     (in),
        .out    (out)
    );

    always begin
        #($urandom_range(10, 0));
        in <= $urandom();
    end

    // dump vcd
    `DUMP_ALL_VCD
endmodule