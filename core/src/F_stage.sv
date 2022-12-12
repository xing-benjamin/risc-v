//--------------------------------------------------------------
/*
    Filename: F_stage.sv

    Fetch stage top module.
*/
//--------------------------------------------------------------

module F_stage (
    input  logic        rst_n,
    input  logic [31:0] curr_pc,
    output logic [31:0] next_pc
);

    logic [31:0] next_pc_raw;
    logic [31:0] curr_pc_plus_4;
    assign curr_pc_plus_4 = curr_pc + 32'd4;

    dl_mux4 #(
        .NUM_BITS   (32)
    ) next_pc_mux (
        .in0    (curr_pc_plus_4),
        .in1    (),
        .in2    (),
        .in3    (),
        .sel    (2'b00), // FIXME BEN
        .out    (next_pc_raw)
    );

    dl_mux2 #(
        .NUM_BITS   (32)
    ) next_pc_reset_mux (
        .in0    (next_pc_raw),
        .in1    (curr_pc),
        .sel    (!rst_n),
        .out    (next_pc)
    );

endmodule : F_stage