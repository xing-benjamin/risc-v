//--------------------------------------------------------------
/*
    Filename: core.sv

    RV32I top module.
*/
//--------------------------------------------------------------

import memory_types_pkg::*;

`include "regfile.sv"
`include "F_stage.sv"
`include "D_stage.sv"
`include "X_stage.sv"
`include "M_stage.sv"
`include "W_stage.sv"

module core #(
    parameter N_BITS = 32,
    parameter N_REGS = 32
)(
    input  logic        clk,
    input  logic        rst_n,
    // imem port
    output logic        imem_req_vld,
    input  logic        imem_req_rdy,
    output mem_pkt_t    imem_req,
    input  logic        imem_rsp_vld,
    output logic        imem_rsp_rdy,
    input  mem_pkt_t    imem_rsp
    // dmem port
    /*
    output logic        dmem_req_vld,
    input  logic        dmem_req_rdy,
    output mem_pkt_t    dmem_req,
    input  logic        dmem_rsp_vld,
    output logic        dmem_rsp_rdy,
    input  mem_pkt_t    dmem_rsp
    */
);

    localparam RF_N_IDX = $clog2(N_REGS);

    logic                   rst_n_sync2clk;
    logic [31:0]            pc;
    logic [31:0]            next_pc;
    logic [31:0]            fetched_instr;
    logic [RF_N_IDX-1:0]    rs1;
    logic [RF_N_IDX-1:0]    rs2;
    logic [RF_N_IDX-1:0]    rd;
    logic [31:0]            opA;
    logic [31:0]            opB;
    logic [N_BITS-1:0]      rs1_data;
    logic [N_BITS-1:0]      rs2_data;
    alu_op_t                alu_op;
    logic                   rf_wr_en;
    logic [N_BITS-1:0]      X_out;
    logic [N_BITS-1:0]      M_out;
    logic [N_BITS-1:0]      rf_wr_data;

    // rst_n synced to clk
    dl_reg #(
        .NUM_BITS   (1)
    ) rst_n_sync2clk_flop (
        .clk    (clk),
        .d      (rst_n),
        .q      (rst_n_sync2clk)
    );

    // Program counter
    dl_reg_rst #(
        .NUM_BITS   (32),
        .RST_VAL    (32'b0)
    ) program_cntr (
        .clk    (clk),
        .rst_n  (rst_n),
        .d      (next_pc),
        .q      (pc)
    );

    // Register file
    regfile #(    
        .N_BITS (32),
        .N_REGS (32)
    ) rf (
        .clk        (clk),
        .rst_n      (rst_n),
        .rd0_idx    (rs1),
        .rd1_idx    (rs2),
        .rd0_data   (rs1_data),
        .rd1_data   (rs2_data),
        .wr_en      (rf_wr_en),
        .wr_idx     (rd),
        .wr_data    (rf_wr_data)
    );

    F_stage F_stage_inst (
        .rst_n      (rst_n_sync2clk),
        .curr_pc    (pc),
        .next_pc    (next_pc)
    );

    D_stage D_stage_inst (
        .instr      (fetched_instr),
        .pc         (pc),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .rs1_data   (rs1_data),
        .rs2_data   (rs2_data),
        .opA        (opA),
        .opB        (opB),
        .alu_op     (alu_op),
        .rf_wr_en   (rf_wr_en)
    );

    X_stage X_stage_inst (
        .alu_op     (alu_op),
        .in0        (opA),
        .in1        (opB),
        .out        (X_out)
    );

    M_stage M_stage_inst (
        .X_stage_data   (X_out),
        .mem_rsp_data   (),
        .out            (M_out)
    );

    W_stage W_stage_inst (
        .in_wr_data     (M_out),
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

    assign fetched_instr = imem_rsp.data;
    assign imem_rsp_rdy = 1'b1;


endmodule : core