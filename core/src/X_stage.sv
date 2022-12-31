//--------------------------------------------------------------
/*
    Filename: X_stage.sv

    Execute stage top module.
*/
//--------------------------------------------------------------

import core_types_pkg::*;

module X_stage (
    input                       clk,
    input                       rst_n,
    input  alu_op_t             alu_op_nxt,
    input  rf_ctrl_t            rf_ctrl_pkt_in,
    output rf_ctrl_t            rf_ctrl_pkt_out,
    input  logic [N_BITS-1:0]   op1_nxt,
    input  logic [N_BITS-1:0]   op2_nxt,
    input  logic [N_BITS-1:0]   pc_plus4_in,
    input  logic [N_BITS-1:0]   branch_tgt_in,
    output logic [N_BITS-1:0]   branch_tgt,
    output logic                branch_vld,
    input  ctrl_transfer_t      ctrl_transfer_pkt_in,
    output logic [N_BITS-1:0]   jalr_tgt,
    output logic                jalr_vld,
    output logic [N_BITS-1:0]   data_out,
    input  logic                vld_in,
    output logic                vld,
    input  logic                stall_in,
    output logic                stall,
    input  logic                squash_in,
    output logic                squash
);

    logic [N_BITS-1:0]          pc_plus4;
    logic [N_BITS-1:0]          op1;
    logic [N_BITS-1:0]          op2;
    alu_op_t                    alu_op;
    logic [N_BITS-1:0]          alu_out;
    logic                       jalr_vld_raw;
    logic                       gen_stall;
    logic                       gen_squash;
    logic                       vld_raw;
    ctrl_transfer_t             ctrl_transfer_pkt;

    //////////////////////////////
    //    Pipeline registers    //
    //////////////////////////////
    dl_reg_en_rst #(
        .NUM_BITS   (1)
    ) X_stage_vld_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (vld_in),
        .q          (vld_raw)
    );

    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) X_pc_plus_4_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (pc_plus4_in),
        .q          (pc_plus4)
    );

    dl_reg_en_rst #(
        .NUM_BITS   ($bits(ctrl_transfer_t))
    ) is_jalr_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (ctrl_transfer_pkt_in),
        .q          (ctrl_transfer_pkt)
    );

    assign jalr_vld = vld && ctrl_transfer_pkt.is_jalr;
    assign branch_vld = vld && ctrl_transfer_pkt.is_branch && 1'b0;

    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) X_branch_tgt_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (branch_tgt_in),
        .q          (branch_tgt)
    );

    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) X_op1_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (op1_nxt),
        .q          (op1)
    );

    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) X_op2_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (op2_nxt),
        .q          (op2)
    );

    dl_reg_en_rst #(
        .NUM_BITS   ($bits(alu_op_t))
    ) alu_op_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (alu_op_nxt),
        .q          (alu_op)
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

    // ALU
    alu #(
        .N_BITS (N_BITS)
    ) alu_inst (
        .alu_op     (alu_op),
        .in0        (op1),
        .in1        (op2),
        .out        (alu_out)
    );

    assign jalr_tgt = alu_out;

    dl_mux2 #(
        .NUM_BITS (N_BITS)
    ) alu_pc_plus_4_mux (
        .in0        (alu_out),
        .in1        (pc_plus4),
        .sel        (ctrl_transfer_pkt.is_jal || ctrl_transfer_pkt.is_jalr),
        .out        (data_out)
    );

    ///////////////////////
    //  Control signals  //
    ///////////////////////
    assign stall = stall_in || gen_stall;
    assign gen_stall = 1'b0;

    assign gen_squash = jalr_vld || branch_vld;
    assign squash = squash_in || gen_squash;

    assign vld = vld_raw && !gen_stall && !squash_in;

endmodule : X_stage