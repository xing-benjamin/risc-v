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
    logic [N_BITS-1:0]          next_pc;
    logic [RF_IDX_WIDTH-1:0]    rs1;
    logic [RF_IDX_WIDTH-1:0]    rs2;
    logic [RF_IDX_WIDTH-1:0]    D_rd;
    logic [N_BITS-1:0]          op1;
    logic [N_BITS-1:0]          op2;
    logic [N_BITS-1:0]          jmp_branch_tgt;
    logic [4:0]                 X_rd;
    logic [N_BITS-1:0]          rs1_data;
    logic [N_BITS-1:0]          rs2_data;
    alu_op_t                    alu_op;
    rf_wb_ctrl_t                rf_wb_ctrl_pkt;
    dmem_req_ctrl_t             dmem_req_ctrl_pkt;              

    logic [N_BITS-1:0]      X_out;
    logic [N_BITS-1:0]      M_out;
    logic [N_BITS-1:0]      rf_wr_data;
    logic [N_BITS-1:0]      W_data_in;

    // Register file
    regfile #(    
        .N_BITS (N_BITS),
        .N_REGS (RF_N_REGS)
    ) rf (
        .clk        (clk),
        .rst_n      (rst_n),
        .rd0_idx    (rs1),
        .rd1_idx    (rs2),
        .rd0_data   (rs1_data),
        .rd1_data   (rs2_data),
        .wr_en      (rf_wr_en),
        .wr_idx     (D_rd),
        .wr_data    (rf_wr_data)
    );

    F_stage F_stage_inst (
        .clk            (clk),
        .rst_n          (rst_n),
        .pc             (pc),
        .pc_plus4       (pc_plus4),
        .next_pc        (next_pc),
        .jmp_branch_tgt (jmp_branch_tgt)
    );

    D_stage D_stage_inst (
        .nxt_instr          (imem_rsp.data),
        .pc_in              (pc),
        .pc_plus4_in        (pc_plus4),
        .pc_plus4_out       ()
        .rs1                (rs1),
        .rs2                (rs2),
        .rs1_data           (rs1_data),
        .rs2_data           (rs2_data),
        .op1                (op1),
        .op2                (op2),
        .jmp_branch_tgt     (jmp_branch_tgt),
        .alu_op             (D_alu_op),
        .rf_wb_ctrl_pkt     (rf_wb_ctrl_pkt),
        .dmem_req_ctrl_pkt  (dmem_req_ctrl_pkt)
    );

    X_stage X_stage_inst (
        .alu_op     (alu_op),
        .in0        (X_op1),
        .in1        (X_op2),
        .out        (X_out)
    );

    M_stage M_stage_inst (
        .X_stage_data   (X_out),
        .mem_rsp_data   (dmem_rsp.data),
        .out            (M_out)
    );

    dl_reg_en_rst #(
        .NUM_BITS   (32)
    ) rf_wr_data_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (1'b1),
        .d          (M_out),
        .q          (W_data_in)
    );

    W_stage W_stage_inst (
        .in_wr_data     (W_data_in),
        .out_wr_data    (rf_wr_data)
    );

    ///////////////////////
    // Memory Interfaces //
    ///////////////////////
    assign imem_req.mtype = READ;
    assign imem_req.addr = next_pc;
    assign imem_req.len = 2'b0;
    assign imem_req.data = 32'b0;
    assign imem_req_vld = rst_n;

    assign imem_rsp_rdy = 1'b1;

    assign dmem_req_vld = mem_access;
    assign dmem_req.addr = X_out;
    assign dmem_req.len = mem_len;
    assign dmem_req.data = rs2_data;

    


endmodule : core