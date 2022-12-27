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
    output logic [N_BITS-1:0]   data_out
);

    logic [N_BITS-1:0]      pc_plus4;
    logic [N_BITS-1:0]      op1;
    logic [N_BITS-1:0]      op2;
    alu_op_t                alu_op;

    logic [N_BITS-1:0]      alu_out;

    //////////////////////////////
    //    Pipeline registers    //
    //////////////////////////////
    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) X_pc_plus_4_reg (
        .clk    (clk),
        .rst_n  (rst_n),
        .en     (1'b1),
        .d      (pc_plus4_in),
        .q      (pc_plus4)
    );

    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) X_branch_tgt_reg (
        .clk    (clk),
        .rst_n  (rst_n),
        .en     (1'b1),
        .d      (branch_tgt_in),
        .q      (branch_tgt)
    );

    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) X_op1_reg (
        .clk    (clk),
        .rst_n  (rst_n),
        .en     (1'b1),
        .d      (op1_nxt),
        .q      (op1)
    );

    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) X_op2_reg (
        .clk    (clk),
        .rst_n  (rst_n),
        .en     (1'b1),
        .d      (op2_nxt),
        .q      (op2)
    );

    dl_reg_en_rst #(
        .NUM_BITS   ($bits(alu_op_t))
    ) alu_op_reg (
        .clk    (clk),
        .rst_n  (rst_n),
        .en     (1'b1),
        .d      (alu_op_nxt),
        .q      (alu_op)
    );

    dl_reg_en_rst #(
        .NUM_BITS   ($bits(rf_ctrl_t))
    ) rf_ctrl_pkt_reg (
        .clk    (clk),
        .rst_n  (rst_n),
        .en     (1'b1),
        .d      (rf_ctrl_pkt_in),
        .q      (rf_ctrl_pkt_out)
    );

    // ALU
    alu #(
        .N_BITS (N_BITS)
    ) alu_inst (
        .alu_op (alu_op),
        .in0    (op1),
        .in1    (op2),
        .out    (alu_out)
    );

    dl_mux2 #(
        .NUM_BITS (N_BITS)
    ) alu_pc_plus_4_mux (
        .in0    (alu_out),
        .in1    (pc_plus4),
        .sel    (1'b0),
        .out    (data_out)
    );

endmodule : X_stage