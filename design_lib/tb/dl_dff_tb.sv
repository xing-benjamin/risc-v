//--------------------------------------------------------------
/*
    Filename: dl_dff_tb.v

    D flip-flop Verilog testbench.
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

module dl_dff_tb;

    logic clk;
    logic d;
    logic q;

    // Clock generator interface
    clk_intf #(.CLK_PERIOD(1)) clk_if (
        .clk(clk)
    );

    // Instantiate DUT
    dl_dff dl_dff_inst (
        .clk    (clk),
        .d      (d),
        .q      (q)
    );

    `SET_SIM_STOP_TIME(100)

    // Drive data input
    initial begin
        d = 1'b0;
    end

    always begin
        #($urandom_range(10, 0));
        d <= ~d;
    end

    // dump vcd
    `DUMP_ALL_VCD
endmodule