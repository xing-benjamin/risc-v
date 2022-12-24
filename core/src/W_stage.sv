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
    input  rf_wb_ctrl_t         rf_wb_ctrl_pkt_in,
    output rf_wb_ctrl_t         rf_wb_ctrl_pkt_out,
    input  logic [N_BITS-1:0]   data_in,
    output logic [N_BITS-1:0]   data_out
);

    //////////////////////////////
    //    Pipeline registers    //
    //////////////////////////////
    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) data_in_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (1'b1),
        .d          (data_in),
        .q          (data_out)
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

endmodule : W_stage