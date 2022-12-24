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
    input  rf_wb_ctrl_t         rf_wb_ctrl_pkt_in,
    output rf_wb_ctrl_t         rf_wb_ctrl_pkt_out,
    output logic [N_BITS-1:0]   data_out
);

    logic [N_BITS-1:0]  exe_data;

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
        .NUM_BITS   ($bits(rf_wb_ctrl_t))
    ) rf_wb_ctrl_pkt_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (1'b1),
        .d          (rf_wb_ctrl_pkt_in),
        .q          (rf_wb_ctrl_pkt_out)
    );

    dl_mux2 #(
        .NUM_BITS   (N_BITS)
    ) M_out_mux (
        .in0        (exe_data),
        .in1        (mem_rsp_data),
        .sel        (1'b0),
        .out        (data_out)
    );

endmodule : M_stage