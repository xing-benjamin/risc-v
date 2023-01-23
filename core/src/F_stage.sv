//--------------------------------------------------------------
/*
    Filename: F_stage.sv

    Fetch stage top module.
*/
//--------------------------------------------------------------

import core_types_pkg::*;

module F_stage (
    input  logic            clk,
    input  logic            rst_n,
    output [N_BITS-1:0]     pc,
    output [N_BITS-1:0]     pc_plus4,
    output [N_BITS-1:0]     next_pc,
    input  [N_BITS-1:0]     jal_tgt,
    input                   jal_vld,
    input  [N_BITS-1:0]     branch_tgt,
    input                   branch_vld,
    input  [N_BITS-1:0]     jalr_tgt,
    input                   jalr_vld,
    input  logic            vld_in,
    output logic            vld,
    input  logic            stall_in,
    output logic            stall,
    input  logic            squash_in,
    output logic            squash
);

    logic                   pc_reg_en;
    logic [1:0]             next_pc_mux_sel;
    logic                   gen_stall;
    logic                   gen_squash;
    logic                   vld_raw;

    assign pc_reg_en = rst_n && !stall; // FIXME BEN

    // Valid bit
    dl_reg_en_rst #(
        .NUM_BITS   (1)
    ) F_stage_vld_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (vld_in),
        .q          (vld_raw)
    );

    // Program counter
    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS),
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
        .NUM_BITS   (N_BITS)
    ) next_pc_mux (
        .in0        (pc_plus4),
        .in1        (jal_tgt),
        .in2        (branch_tgt),
        .in3        (jalr_tgt),
        .sel        (next_pc_mux_sel), // FIXME BEN
        .out        (next_pc)
    );

    dl_pri_encoder_4p2p next_pc_mux_sel_encoder (
        .in     ({jalr_vld, branch_vld, jal_vld, 1'b1}),
        .out    (next_pc_mux_sel)
    );

    ///////////////////////
    //  Control signals  //
    ///////////////////////
    assign gen_stall = 1'b0;
    assign stall = gen_stall || stall_in;

    assign gen_squash = 1'b0;
    assign squash = squash_in || gen_squash;

    assign vld = vld_raw && !gen_stall && !squash_in;

endmodule : F_stage
