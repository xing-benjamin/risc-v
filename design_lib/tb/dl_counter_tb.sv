//--------------------------------------------------------------
/*
    Filename: dl_dff_tb.v

   Counter Verilog testbench.
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

module dl_counter_tb;

    localparam  NUM_BITS = 5;
    localparam  MAX_VAL = 13;

    logic clk;
    logic en;
    logic done;
    logic rst_n;
    logic [NUM_BITS-1:0] q;

    // Clock generator interface
    clk_intf #(.CLK_PERIOD(1)) clk_if (
        .clk(clk)
    );

    // Instantiate DUT
    dl_counter #(.NUM_BITS(NUM_BITS),.MAX_VAL(MAX_VAL)) dl_counter_inst (
        .clk    (clk),
        .en     (en),
        .q      (q),
        .done   (done),
        .rst_n  (rst_n)
    );

    `SET_SIM_STOP_TIME(200)

    // Drive data input
    initial begin
      en = 0;
      rst_n = 0;
      #2;
      rst_n = 1;

      // test reset
      #150;
      rst_n <= ~rst_n;
      #200;
      rst_n <= ~rst_n;
    end

    // Drive EN input 
    always begin
      #($urandom_range(3, 0));
      en <= ~en;
    end

    // dump vcd
    `DUMP_ALL_VCD
endmodule