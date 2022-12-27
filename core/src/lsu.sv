//--------------------------------------------------------------
/*
    Filename: lsu.sv

    Load-store unit module.
*/
//--------------------------------------------------------------

import core_types_pkg::*;
import memory_types_pkg::*;

module lsu (
    input  logic                clk,
    input  logic                rst_n,
    input  dmem_req_ctrl_t      dmem_req_ctrl_pkt_in,
    input  logic [N_BITS-1:0]   dmem_req_addr,
    input  logic [N_BITS-1:0]   dmem_wr_data_in,
    output logic                is_dmem_rd,
    output logic                dmem_req_out_vld,
    output mem_pkt_t            dmem_req_out
);

    dmem_req_ctrl_t     dmem_req_ctrl_pkt;
    logic [N_BITS-1:0]  dmem_wr_data;

    //////////////////////////////
    //    Pipeline registers    //
    //////////////////////////////
    dl_reg_en_rst #(
        .NUM_BITS   ($bits(dmem_req_ctrl_t))
    ) dmem_req_ctrl_pkt_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (1'b1),
        .d          (dmem_req_ctrl_pkt_in),
        .q          (dmem_req_ctrl_pkt)
    );

    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) dmem_wr_data_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (1'b1),
        .d          (dmem_wr_data_in),
        .q          (dmem_wr_data)
    );

    assign is_dmem_rd = (!dmem_req_ctrl_pkt.mtype &&
                          dmem_req_ctrl_pkt.vld);

    assign dmem_req_out_vld = dmem_req_ctrl_pkt.vld;

    assign dmem_req_out.mtype = dmem_req_ctrl_pkt.mtype ? WRITE : READ;
    assign dmem_req_out.addr = dmem_req_addr;
    assign dmem_req_out.len = dmem_req_ctrl_pkt.len;
    assign dmem_req_out.data = dmem_wr_data;

endmodule : lsu
