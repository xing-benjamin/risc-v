//--------------------------------------------------------------
/*
    Filename: W_stage.sv

    Write stage top module.
*/
//--------------------------------------------------------------

import core_types_pkg::*;

module W_stage (
    input                       clk,
    input                       rst_n,
    input  rf_ctrl_t            rf_ctrl_pkt_in,
    output rf_ctrl_t            rf_ctrl_pkt_out,
    input  logic [N_BITS-1:0]   data_in,
    output logic [N_BITS-1:0]   data_out,
    input  logic                vld_in,
    output logic                vld,
    input  logic                stall_in,
    output logic                stall,
    input  logic                squash_in,
    output logic                squash
);

    logic                       gen_stall;
    logic                       gen_squash;
    logic                       vld_raw;

    //////////////////////////////
    //    Pipeline registers    //
    //////////////////////////////
    dl_reg_en_rst #(
        .NUM_BITS   (1)
    ) W_stage_vld_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (vld_in),
        .q          (vld_raw)
    );

    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) data_in_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (data_in),
        .q          (data_out)
    );

    dl_reg_en_rst #(
        .NUM_BITS   ($bits(rf_ctrl_t))
    ) rf_ctrl_pkt_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (rf_ctrl_pkt_in),
        .q          (rf_ctrl_pkt_out)
    );

    assign gen_stall = 1'b0;
    assign stall = stall_in || gen_stall;

    assign gen_squash = 1'b0;
    assign squash = squash_in || gen_squash;

    assign vld = vld_raw && !gen_stall && !squash_in;

endmodule : W_stage
