//--------------------------------------------------------------
/*
    Filename: M_stage.sv

    Memory stage top module.
*/
//--------------------------------------------------------------

import core_types_pkg::*;

module M_stage (
    input                       clk,
    input                       rst_n,
    input  logic [N_BITS-1:0]   exe_data_in,
    input  logic [N_BITS-1:0]   mem_rsp_data,
    input  logic                is_dmem_rd,
    input  rf_ctrl_t            rf_ctrl_pkt_in,
    output rf_ctrl_t            rf_ctrl_pkt_out,
    output logic [N_BITS-1:0]   data_out,
    input  logic                stall_in,
    output logic                stall
);

    logic [N_BITS-1:0]  exe_data;
    dmem_req_ctrl_t     dmem_req_ctrl_pkt;
    logic               M_out_sel;
    logic               local_stall;

    //////////////////////////////
    //    Pipeline registers    //
    //////////////////////////////
    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) exe_data_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (1'b1),
        .d          (exe_data_in),
        .q          (exe_data)
    );

    dl_reg_en_rst #(
        .NUM_BITS   ($bits(rf_ctrl_t))
    ) rf_ctrl_pkt_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (1'b1),
        .d          (rf_ctrl_pkt_in),
        .q          (rf_ctrl_pkt_out)
    );

    dl_reg_en_rst #(
        .NUM_BITS   (1)
    ) is_dmem_rd_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (1'b1),
        .d          (is_dmem_rd),
        .q          (M_out_sel)
    );

    dl_mux2 #(
        .NUM_BITS   (N_BITS)
    ) M_out_mux (
        .in0        (exe_data),
        .in1        (mem_rsp_data),
        .sel        (M_out_sel),
        .out        (data_out)
    );

    ///////////////////////
    //  Control signals  //
    ///////////////////////
    assign stall = stall_in || local_stall;
    assign local_stall = 1'b0;

endmodule : M_stage