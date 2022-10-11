//--------------------------------------------------------------
/*
    Filename: dl_reg_rst_tb.v

    Parameterized register w/ reset Verilog testbench.
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

module dl_reg_rst_tb;

    localparam  NUM_BITS = 32;
    localparam  RST_VAL = 32'hc0ffee69;

    logic                   clk;
    logic                   rst_n;
    logic [NUM_BITS-1:0]    d;
    logic [NUM_BITS-1:0]    q;

    // Clock generator interface
    clk_intf #(.CLK_PERIOD(1)) clk_if (
        .clk    (clk)
    );

    reset_intf reset_if (
        .rst_n  (rst_n)
    );

    // Instantiate DUT
    dl_reg_rst #(
        .NUM_BITS(NUM_BITS),
        .RST_VAL(RST_VAL)
    ) dl_reg_rst_inst (
        .clk    (clk),
        .rst_n  (rst_n),
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

    always begin
        #($urandom_range(50, 0));
        if ($urandom_range(10, 0) < 2) begin
            reset_if.drive_reset_val(1'b0);
            #10;
            reset_if.drive_reset_val(1'b1);
        end
    end

    // dump vcd
    `DUMP_ALL_VCD
endmodule