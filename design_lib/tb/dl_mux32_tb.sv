//--------------------------------------------------------------
/*
    Filename: dl_mux32_tb.v

    Parameterized 2-to-1 mux Verilog testbench.
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

module dl_mux32_tb;

    localparam  NUM_BITS = 32;
    localparam  NUM_INPUTS = 32;
    localparam  SEL_WIDTH = $clog2(NUM_INPUTS);

    `SET_SIM_STOP_TIME(100)

    // Instantiate DUT
    dl_mux32 #(.NUM_BITS(NUM_BITS)) dl_mux32_inst (
        .in0    (genblk_mux32[0].in),
        .in1    (genblk_mux32[1].in),
        .in2    (genblk_mux32[2].in),
        .in3    (genblk_mux32[3].in),
        .in4    (genblk_mux32[4].in),
        .in5    (genblk_mux32[5].in),
        .in6    (genblk_mux32[6].in),
        .in7    (genblk_mux32[7].in),
        .in8    (genblk_mux32[8].in),
        .in9    (genblk_mux32[9].in),
        .in10    (genblk_mux32[10].in),
        .in11    (genblk_mux32[11].in),
        .in12    (genblk_mux32[12].in),
        .in13    (genblk_mux32[13].in),
        .in14    (genblk_mux32[14].in),
        .in15    (genblk_mux32[15].in),
        .in16    (genblk_mux32[16].in),
        .in17    (genblk_mux32[17].in),
        .in18    (genblk_mux32[18].in),
        .in19    (genblk_mux32[19].in),
        .in20    (genblk_mux32[20].in),
        .in21    (genblk_mux32[21].in),
        .in22    (genblk_mux32[22].in),
        .in23    (genblk_mux32[23].in),
        .in24    (genblk_mux32[24].in),
        .in25    (genblk_mux32[25].in),
        .in26    (genblk_mux32[26].in),
        .in27    (genblk_mux32[27].in),
        .in28    (genblk_mux32[28].in),
        .in29    (genblk_mux32[29].in),
        .in30    (genblk_mux32[30].in),
        .in31    (genblk_mux32[31].in),
        .sel    (sel),
        .out    (out)
    );

    logic [SEL_WIDTH-1:0]   sel;
    logic [NUM_BITS-1:0]    out;

    always begin
        #($urandom_range(10, 0));
        sel <= $urandom();
    end

    generate
        for (genvar i = 0; i < NUM_INPUTS; i++) begin : genblk_mux32
            logic [NUM_BITS-1:0] in;

            // Drive data input
            initial begin
                in = '0;
            end

            always begin
                #($urandom_range(10, 0));
                in <= $urandom();
            end
        end
    endgenerate

    // dump vcd
    `DUMP_ALL_VCD
endmodule