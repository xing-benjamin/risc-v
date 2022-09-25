//--------------------------------------------------------------
/*
    Filename: dl_rshift_l_tb.sv

    Parameterized left shifter Verilog testbench.
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

module dl_rshift_l_tb;

    localparam  NUM_BITS = 8;
    localparam  NUM_SHIFT_BITS = $clog2(NUM_BITS);

    logic [NUM_BITS-1:0]        a;
    logic [NUM_SHIFT_BITS-1:0]  shift;
    logic [NUM_BITS-1:0]        out;

    // Instantiate DUT
    dl_rshift_l #(.NUM_BITS(NUM_BITS)) dl_rshift_l_inst (
        .a      (a),
        .shift  (shift),
        .out    (out)
    );

    `SET_SIM_STOP_TIME(100)

    // Drive data input
    initial begin
        a = '0;
        shift = '0;
    end

    always begin
        #($urandom_range(10, 0));
        a <= $urandom();
    end

    always begin
        #($urandom_range(10, 0));
        shift <= $urandom();
    end

    // dump vcd
    `DUMP_ALL_VCD
endmodule