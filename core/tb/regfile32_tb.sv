//--------------------------------------------------------------
/*
    Filename: regfile32_tb.v

    Paramterized 32-entry register file, 2r1w Verilog 
    testbench.
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

module regfile32_tb;

    `SET_SIM_STOP_TIME(2000)

    localparam N_BITS = 32;
    localparam N_REGS = 32;
    localparam N_IDX = $clog2(N_REGS);

    logic                   clk;
    logic                   rst_n;

    // Read ports
    logic [N_IDX-1:0]    rd0_idx;
    logic [N_IDX-1:0]    rd1_idx;
    logic [N_BITS-1:0]   rd0_data;
    logic [N_BITS-1:0]   rd1_data;

    // Write port
    logic                wr_en;
    logic [N_IDX-1:0]    wr_idx;
    logic [N_BITS-1:0]   wr_data;

    // Clock generator interface
    clk_intf #(.CLK_PERIOD(1)) clk_if (
        .clk    (clk)
    );

    // Reset gen interface
    reset_intf rst_if (
        .rst_n  (rst_n)
    );

    // Instantiate DUT
    regfile32 #(
        .N_BITS(32),
        .N_REGS(32)
    ) regfile32_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .rd0_idx    (rd0_idx),
        .rd1_idx    (rd1_idx),
        .rd0_data   (rd0_data),
        .rd1_data   (rd1_data),
        .wr_en      (wr_en),
        .wr_idx     (wr_idx),
        .wr_data    (wr_data)
    );

    always begin
        #($urandom_range(10, 0));
        rd0_idx <= $urandom();
    end

    always begin
        #($urandom_range(10, 0));
        rd1_idx <= $urandom();
    end

    always begin
        #($urandom_range(10, 0));
        wr_en <= $urandom();
    end

    always begin
        #($urandom_range(10, 0));
        wr_idx <= $urandom();
    end

    always begin
        #($urandom_range(10, 0));
        wr_data <= $urandom();
    end

    // dump vcd
    `DUMP_ALL_VCD
endmodule