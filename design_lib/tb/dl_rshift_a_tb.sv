//--------------------------------------------------------------
/*
    Filename: dl_rshift_a_tb.sv

    Parameterized left shifter Verilog testbench.
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

module dl_rshift_a_tb;

    localparam  NUM_BITS = 8;
    localparam  NUM_SHIFT_BITS = $clog2(NUM_BITS);

    logic [NUM_BITS-1:0]        in;
    logic [NUM_SHIFT_BITS-1:0]  shamt;
    logic [NUM_BITS-1:0]        out;

    // Instantiate DUT
    dl_rshift_a #(.NUM_BITS(NUM_BITS)) dl_rshift_a_inst (
        .in     (in),
        .shamt  (shamt),
        .out    (out)
    );

    `SET_SIM_STOP_TIME(100)

    // Drive data input
    initial begin
        in = '0;
        shamt = '0;
    end

    always begin
        #($urandom_range(10, 0));
        in <= $urandom();
    end

    always begin
        #($urandom_range(10, 0));
        shamt <= $urandom();
    end

    // dump vcd
    `DUMP_ALL_VCD
endmodule