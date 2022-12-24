//--------------------------------------------------------------
/*
    Filename: core.sv

    RV32I top module.
*/
//--------------------------------------------------------------

import memory_types_pkg::*;
import core_types_pkg::*;

module core (
    input  logic        clk,
    input  logic        rst_n,
    // imem port
    output logic        imem_req_vld,
    input  logic        imem_req_rdy,
    output mem_pkt_t    imem_req,
    input  logic        imem_rsp_vld,
    output logic        imem_rsp_rdy,
    input  mem_pkt_t    imem_rsp,
    // dmem port
    output logic        dmem_req_vld,
    input  logic        dmem_req_rdy,
    output mem_pkt_t    dmem_req,
    input  logic        dmem_rsp_vld,
    output logic        dmem_rsp_rdy,
    input  mem_pkt_t    dmem_rsp
);

    logic [N_BITS-1:0]          pc;
    logic [N_BITS-1:0]          pc_plus4;
    logic [N_BITS-1:0]          pc_plus4_D;
    logic [N_BITS-1:0]          next_pc;
    logic [RF_IDX_WIDTH-1:0]    rs1;
    logic [RF_IDX_WIDTH-1:0]    rs2;
    logic [N_BITS-1:0]          op1;
    logic [N_BITS-1:0]          op2;
    logic [N_BITS-1:0]          jal_branch_tgt;
    logic [N_BITS-1:0]          branch_tgt;
    logic [N_BITS-1:0]          rs1_data;
    logic [N_BITS-1:0]          rs2_data;
    alu_op_t                    alu_op;
    rf_wb_ctrl_t                rf_wb_ctrl_pkt_D;
    rf_wb_ctrl_t                rf_wb_ctrl_pkt_X;
    rf_wb_ctrl_t                rf_wb_ctrl_pkt_M;
    rf_wb_ctrl_t                rf_wb_ctrl_pkt_W;
    dmem_req_ctrl_t             dmem_req_ctrl_pkt_D;
    dmem_req_ctrl_t             dmem_req_ctrl_pkt_X;
    logic [N_BITS-1:0]          X_out;
    logic [N_BITS-1:0]          M_out;
    logic [N_BITS-1:0]          W_out;

    // Register file
    regfile #(    
        .N_BITS (N_BITS),
        .N_REGS (RF_N_REGS)
    ) rf (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .rd0_idx                (rs1),
        .rd1_idx                (rs2),
        .rd0_data               (rs1_data),
        .rd1_data               (rs2_data),
        .wr_en                  (rf_wb_ctrl_pkt_W.wr_en),
        .wr_idx                 (rf_wb_ctrl_pkt_W.rd),
        .wr_data                (W_out)
    );

    F_stage F_stage_inst (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .pc                     (pc),
        .pc_plus4               (pc_plus4),
        .next_pc                (next_pc),
        .jal_tgt                (jal_branch_tgt),
        .branch_tgt             (branch_tgt),
        .jalr_tgt               (X_out)
    );

    D_stage D_stage_inst (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .nxt_instr              (imem_rsp.data),
        .pc_in                  (pc),
        .pc_plus4_in            (pc_plus4),
        .pc_plus4_out           (pc_plus4_D),
        .rs1                    (rs1),
        .rs2                    (rs2),
        .rs1_data               (rs1_data),
        .rs2_data               (rs2_data),
        .op1                    (op1),
        .op2                    (op2),
        .jal_branch_tgt         (jal_branch_tgt),
        .alu_op                 (alu_op),
        .rf_wb_ctrl_pkt         (rf_wb_ctrl_pkt_D),
        .dmem_req_ctrl_pkt      (dmem_req_ctrl_pkt_D)
    );

    X_stage X_stage_inst (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .alu_op_nxt             (alu_op),
        .rf_wb_ctrl_pkt_in      (rf_wb_ctrl_pkt_D),
        .rf_wb_ctrl_pkt_out     (rf_wb_ctrl_pkt_X),
        .dmem_req_ctrl_pkt_in   (dmem_req_ctrl_pkt_D),
        .dmem_req_ctrl_pkt_out  (dmem_req_ctrl_pkt_X),
        .op1_nxt                (op1),
        .op2_nxt                (op2),
        .pc_plus4_in            (pc_plus4_D),
        .branch_tgt_in          (jal_branch_tgt),
        .branch_tgt             (branch_tgt),
        .data_out               (X_out)
    );

    M_stage M_stage_inst (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .exe_data_in            (X_out),
        .mem_rsp_data           (dmem_rsp.data),
        .rf_wb_ctrl_pkt_in      (rf_wb_ctrl_pkt_X),
        .rf_wb_ctrl_pkt_out     (rf_wb_ctrl_pkt_M),
        .data_out               (M_out)
    );

    W_stage W_stage_inst (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .rf_wb_ctrl_pkt_in      (rf_wb_ctrl_pkt_M),
        .rf_wb_ctrl_pkt_out     (rf_wb_ctrl_pkt_W),
        .data_in                (M_out),
        .data_out               (W_out)
    );

    ///////////////////////
    // Memory Interfaces //
    ///////////////////////
    assign imem_req_vld = rst_n;

    assign imem_req.mtype = READ;
    assign imem_req.addr = next_pc;
    assign imem_req.len = 2'b0;
    assign imem_req.data = 32'b0;

    assign imem_rsp_rdy = 1'b1;

    assign dmem_req_vld = dmem_req_ctrl_pkt_X.vld;

    assign dmem_req.mtype = dmem_req_ctrl_pkt_X.mtype;
    assign dmem_req.addr = X_out;
    assign dmem_req.len = dmem_req_ctrl_pkt_X.len;
    assign dmem_req.data = rs2_data;

    assign dmem_rsp_rdy = 1'b1;

endmodule : core