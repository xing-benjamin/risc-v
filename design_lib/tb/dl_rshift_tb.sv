//--------------------------------------------------------------
/*
    Filename: dl_rshift_tb.sv

    Parameterized left shifter Verilog testbench.
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

module dl_rshift_tb;

    localparam  NUM_BITS = 8;
    localparam  NUM_SHIFT_BITS = $clog2(NUM_BITS);

    logic                       sh_type;
    logic [NUM_BITS-1:0]        in;
    logic [NUM_SHIFT_BITS-1:0]  shamt;
    logic [NUM_BITS-1:0]        out;

    // Instantiate DUT
    dl_rshift #(.NUM_BITS(NUM_BITS)) dl_rshift_inst (
        .sh_type    (sh_type),
        .in         (in),
        .shamt      (shamt),
        .out        (out)
    );

    `SET_SIM_STOP_TIME(100)

    // Drive data input
    initial begin
        in = '0;
        shamt = '0;
        sh_type = '0;
    end

    always begin
        #($urandom_range(10, 0));
        in <= $urandom();
    end

    always begin
        #($urandom_range(10, 0));
        shamt <= $urandom();
    end

    always begin
        #($urandom_range(10, 0));
        sh_type <= $urandom();
    end

    // dump vcd
    `DUMP_ALL_VCD
endmodule