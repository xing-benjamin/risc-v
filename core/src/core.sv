//--------------------------------------------------------------
/*
    Filename: core.sv

    RV32I top module.
*/
//--------------------------------------------------------------

import memory_types_pkg::*;
import core_types_pkg::*;

module core (
    input  logic                clk,
    input  logic                rst_n,
    // imem port
    output logic                imem_req_vld,
    input  logic                imem_req_rdy,
    output mem_pkt_t            imem_req,
    input  logic                imem_rsp_vld,
    output logic                imem_rsp_rdy,
    input  mem_pkt_t            imem_rsp,
    // dmem port
    output logic                dmem_req_vld,
    input  logic                dmem_req_rdy,
    output mem_pkt_t            dmem_req,
    input  logic                dmem_rsp_vld,
    output logic                dmem_rsp_rdy,
    input  mem_pkt_t            dmem_rsp
);

    logic [N_BITS-1:0]          pc;
    logic [N_BITS-1:0]          next_pc;
    logic [N_BITS-1:0]          instr,

    // F <-> D
    logic [N_BITS-1:0]          pc_D;

    // D <-> X
    logic [N_BITS-1:0]          pc_X;
    logic [RF_IDX_WIDTH-1:0]    rs1;
    logic [RF_IDX_WIDTH-1:0]    rs2;
    logic [N_BITS-1:0]          op1;
    logic [N_BITS-1:0]          op2;
    logic [N_BITS-1:0]          jal_branch_tgt;
    logic                       jal_vld;
    logic [N_BITS-1:0]          branch_tgt;
    logic                       branch_vld;
    logic                       jalr_vld;
    ctrl_transfer_t             ctrl_transfer_pkt;
    logic [N_BITS-1:0]          jalr_tgt;
    logic [N_BITS-1:0]          rs1_data;
    logic [N_BITS-1:0]          rs2_data;
    alu_op_t                    alu_op;
    rf_ctrl_t                   rf_ctrl_pkt_D;
    rf_ctrl_t                   rf_ctrl_pkt_X;
    rf_ctrl_t                   rf_ctrl_pkt_M;
    rf_ctrl_t                   rf_ctrl_pkt_W;
    dmem_req_ctrl_t             dmem_req_ctrl_pkt;
    logic [N_BITS-1:0]          dmem_store_data;
    logic                       is_dmem_rd;
    logic [N_BITS-1:0]          X_out;
    logic [N_BITS-1:0]          M_out;
    logic [N_BITS-1:0]          W_out;
    logic                       F_vld;
    logic                       D_vld;
    logic                       X_vld;
    logic                       M_vld;
    logic                       W_vld;
    logic                       F_stall;
    logic                       D_stall;
    logic                       X_stall;
    logic                       M_stall;
    logic                       W_stall;
    logic                       F_squash;
    logic                       D_squash;
    logic                       X_squash;
    logic                       M_squash;
    logic                       W_squash;

    // Program counter
    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS),
        // 1st instruction fetched at 0x00000000
        .RST_VAL    (PC_RESET)
    ) program_cntr (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (pc_reg_en),
        .d          (next_pc),
        .q          (pc)
    );

    // Register file
    regfile #(    
        .N_BITS (N_BITS),
        .N_REGS (RF_N_REGS)
    ) gprf (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .rd0_idx                (rs1),
        .rd1_idx                (rs2),
        .rd0_data               (rs1_data),
        .rd1_data               (rs2_data),
        .wr_en                  (W_vld && rf_ctrl_pkt_W.wr_en),
        .wr_idx                 (rf_ctrl_pkt_W.rd),
        .wr_data                (W_out)
    );

    F_stage F_stage_inst (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .vld_in                 (1'b1), // FIXME BEN - check if this is correct
        .vld                    (F_vld),
        .stall_in               (D_stall),
        .stall                  (F_stall),
        .squash_in              (D_squash),
        .squash                 (),
        .pc                     (pc),
        .next_pc                (next_pc),
        .jal_tgt                (jal_branch_tgt),
        .jal_vld                (jal_vld),
        .branch_tgt             (branch_tgt),
        .branch_vld             (branch_vld),
        .jalr_tgt               (jalr_tgt),
        .jalr_vld               (jalr_vld)
    );

    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) pc_reg_D (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (pc),
        .q          (pc_D)
    );

    // Instruction memory resp
    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) imem_rsp_instr_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (imem_rsp.data),
        .q          (instr)
    );

    D_stage D_stage_inst (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .vld_in                 (F_vld),
        .vld                    (D_vld),
        .stall_in               (X_stall),
        .stall                  (D_stall),
        .squash_in              (X_squash),
        .squash                 (D_squash),
        .instr                  (instr),
        .pc                     (pc_D),
        .rs1                    (rs1),
        .rs2                    (rs2),
        .rs1_data               (rs1_data),
        .rs2_data               (rs2_data),
        .X_bypass               (X_out),
        .M_bypass               (M_out),
        .W_bypass               (W_out),
        .X_rf_ctrl_pkt          (rf_ctrl_pkt_X),
        .M_rf_ctrl_pkt          (rf_ctrl_pkt_M),
        .W_rf_ctrl_pkt          (rf_ctrl_pkt_W),
        .nxt_stg_is_dmem_rd     (is_dmem_rd),
        .op1                    (op1),
        .op2                    (op2),
        .jal_branch_tgt         (jal_branch_tgt),
        .jal_vld                (jal_vld),
        .ctrl_transfer_pkt      (ctrl_transfer_pkt),
        .alu_op                 (alu_op),
        .rf_ctrl_pkt            (rf_ctrl_pkt_D),
        .dmem_req_ctrl_pkt      (dmem_req_ctrl_pkt),
        .dmem_store_data        (dmem_store_data)
    );

    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) pc_reg_X (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall),
        .d          (pc_D),
        .q          (pc_X)
    );

    X_stage X_stage_inst (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .vld_in                 (D_vld),
        .vld                    (X_vld),
        .stall_in               (M_stall),
        .stall                  (X_stall),
        .squash_in              (M_squash),
        .squash                 (X_squash),
        .alu_op_nxt             (alu_op),
        .rf_ctrl_pkt_in         (rf_ctrl_pkt_D),
        .rf_ctrl_pkt_out        (rf_ctrl_pkt_X),
        .op1_nxt                (op1),
        .op2_nxt                (op2),
        .pc                     (pc_X),
        .branch_tgt_in          (jal_branch_tgt),
        .branch_tgt             (branch_tgt),
        .branch_vld             (branch_vld),
        .ctrl_transfer_pkt_in   (ctrl_transfer_pkt),
        .jalr_tgt               (jalr_tgt),
        .jalr_vld               (jalr_vld),
        .data_out               (X_out)
    );

    M_stage M_stage_inst (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .vld_in                 (X_vld),
        .vld                    (M_vld),
        .stall_in               (W_stall),
        .stall                  (M_stall),
        .squash_in              (W_squash),
        .squash                 (M_squash),
        .exe_data_in            (X_out),
        .mem_rsp_data           (dmem_rsp.data),
        .is_dmem_rd             (is_dmem_rd),
        .rf_ctrl_pkt_in         (rf_ctrl_pkt_X),
        .rf_ctrl_pkt_out        (rf_ctrl_pkt_M),
        .data_out               (M_out)
    );

    W_stage W_stage_inst (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .vld_in                 (M_vld),
        .vld                    (W_vld),
        .stall_in               (1'b0),
        .stall                  (W_stall),
        .squash_in              (1'b0),
        .squash                 (W_squash)
        .rf_ctrl_pkt_in         (rf_ctrl_pkt_M),
        .rf_ctrl_pkt_out        (rf_ctrl_pkt_W),
        .data_in                (M_out),
        .data_out               (W_out),
    );

    lsu lsu_inst (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .dmem_req_ctrl_pkt_in   (dmem_req_ctrl_pkt),
        .dmem_req_addr          (X_out),
        .dmem_wr_data_in        (dmem_store_data),
        .is_dmem_rd             (is_dmem_rd),
        .dmem_req_out_vld       (dmem_req_vld),
        .dmem_req_out           (dmem_req),
        .vld_0                  (X_vld),
        .vld_1                  (M_vld),
        .stall_0                (X_stall),
        .stall_1                (M_stall)
    );

    ///////////////////////
    // Memory Interfaces //
    ///////////////////////
    assign imem_req_vld = rst_n && !F_stall;

    assign imem_req.mtype = READ;
    assign imem_req.addr = next_pc;
    assign imem_req.len = 2'b0;
    assign imem_req.data = 32'b0;

    assign imem_rsp_rdy = rst_n & !F_stall;

    assign dmem_rsp_rdy = 1'b1;

endmodule : core
