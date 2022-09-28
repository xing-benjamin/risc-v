//--------------------------------------------------------------
/*
    Filename: dl_mux2_tb.v

    Parameterized 2-to-1 mux Verilog testbench.
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

module dl_mux2_tb;

    localparam  NUM_BITS = 32;

    logic [NUM_BITS-1:0]    in0;
    logic [NUM_BITS-1:0]    in1;
    logic                   sel;
    logic [NUM_BITS-1:0]    out;

    // Instantiate DUT
    dl_mux2 #(.NUM_BITS(NUM_BITS)) dl_mux2_inst (
        .in0    (in0),
        .in1    (in1),
        .sel    (sel),
        .out    (out)
    );

    `SET_SIM_STOP_TIME(100)

    // Drive data input
    initial begin
        in0 = '0;
        in1 = '0;
    end

    always begin
        #($urandom_range(10, 0));
        in0 <= $urandom();
    end

    always begin
        #($urandom_range(10, 0));
        in1 <= $urandom();
    end

    always begin
        #($urandom_range(10, 0));
        sel <= $urandom_range(1, 0);
    end

    // dump vcd
    `DUMP_ALL_VCD
endmodule