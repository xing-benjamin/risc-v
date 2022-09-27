//--------------------------------------------------------------
/*
    Filename: dl_reg_en_rst_tb.v

    Parameterized register w/ enable and sync reset Verilog 
    testbench.
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

module dl_reg_en_rst_tb;

    localparam  NUM_BITS = 32;
    localparam  RST_VAL = 32'hdeadbeef;

    logic                   clk;
    logic                   rst_n;
    logic                   en;
    logic [NUM_BITS-1:0]    d;
    logic [NUM_BITS-1:0]    q;

    // Clock generator interface
    clk_intf #(.CLK_PERIOD(1)) clk_if (
        .clk(clk)
    );

    // Instantiate DUT
    dl_reg_en_rst #(
        .NUM_BITS(NUM_BITS),
        .RST_VAL(RST_VAL)
    ) dl_reg_en_rst_inst (
        .clk    (clk),
        .rst_n  (rst_n),
        .en     (en),
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
        #($urandom_range(10, 0));
        en <= $urandom();
    end

    always begin
        #($urandom_range(10, 0));
        if ($urandom_range(10, 0) < 3) begin
            rst_n <= 1'b0;
        end else begin
            rst_n <= 1'b1;
        end
    end

    // dump vcd
    `DUMP_ALL_VCD
endmodule