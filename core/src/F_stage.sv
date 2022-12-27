//--------------------------------------------------------------
/*
    Filename: F_stage.sv

    Fetch stage top module.
*/
//--------------------------------------------------------------

import core_types_pkg::*;

module F_stage (
    input  logic        clk,
    input  logic        rst_n,
    output [N_BITS-1:0] pc,
    output [N_BITS-1:0] pc_plus4,
    output [N_BITS-1:0] next_pc,
    input  [N_BITS-1:0] jal_tgt,
    input  [N_BITS-1:0] branch_tgt,
    input  [N_BITS-1:0] jalr_tgt,
    input  logic        stall_in,
    output logic        stall
);

    logic       pc_reg_en;
    logic       local_stall;

    assign pc_reg_en = rst_n && !stall; // FIXME BEN

    // Program counter
    dl_reg_en_rst #(
        .NUM_BITS   (32),
        // 1st instruction fetched at 0x00000000
        .RST_VAL    (32'hfffffffc)
    ) program_cntr (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (pc_reg_en),
        .d          (next_pc),
        .q          (pc)
    );

    assign pc_plus4 = pc + 32'd4;

    dl_mux4 #(
        .NUM_BITS   (32)
    ) next_pc_mux (
        .in0    (pc_plus4),
        .in1    (jal_tgt),
        .in2    (branch_tgt),
        .in3    (jalr_tgt),
        .sel    (2'b00), // FIXME BEN
        .out    (next_pc)
    );

    ///////////////////////
    //  Control signals  //
    ///////////////////////
    assign local_stall = 1'b0;
    assign stall = local_stall || stall_in;

endmodule : F_stage