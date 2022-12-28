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
    output logic                stall
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
        .NUM_BITS   ($bits(rf_ctrl_t))
    ) rf_ctrl_pkt_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (1'b1),
        .d          (rf_ctrl_pkt_in),
        .q          (rf_ctrl_pkt_out)
    );

    assign stall = 1'b0;

endmodule : W_stage