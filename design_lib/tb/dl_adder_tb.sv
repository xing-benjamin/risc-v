//--------------------------------------------------------------
/*
    Filename: dl_adder_tb.v

    Parameterized adder Verilog testbench.
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

module dl_adder_tb;

    localparam  NUM_BITS = 8;

    logic [NUM_BITS-1:0]    a;
    logic [NUM_BITS-1:0]    b;
    logic [NUM_BITS-1:0]    sum;
    logic                   cout;

    // Instantiate DUT
    dl_adder #(.NUM_BITS(NUM_BITS)) dl_adder_inst (
        .a      (a),
        .b      (b),
        .sum    (sum),
        .cout   (cout)
    );

    `SET_SIM_STOP_TIME(100)

    // Drive data input
    initial begin
        a = '0;
        b = '0;
    end

    always begin
        #($urandom_range(10, 0));
        a <= $urandom();
    end

    always begin
        #($urandom_range(10, 0));
        b <= $urandom();
    end

    // dump vcd
    `DUMP_ALL_VCD
endmodule