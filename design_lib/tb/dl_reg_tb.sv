//--------------------------------------------------------------
/*
    Filename: dl_reg_tb.v

    Parameterized register Verilog testbench.
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

module dl_reg_tb;

    localparam  NUM_BITS = 32;

    logic                   clk;
    logic [NUM_BITS-1:0]    d;
    logic [NUM_BITS-1:0]    q;

    // Clock generator interface
    clk_intf #(.CLK_PERIOD(1)) clk_if (
        .clk    (clk)
    );

    // Instantiate DUT
    dl_reg #(.NUM_BITS(NUM_BITS)) dl_reg_inst (
        .clk    (clk),
        .d      (d),
        .q      (q)
    );

    `SET_SIM_STOP_TIME(500)

    // Drive data input
    initial begin
        d = '0;
    end

    always begin
        #($urandom_range(10, 0));
        d <= $urandom();
    end

    // dump vcd
    `DUMP_ALL_VCD
endmodule