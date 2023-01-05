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
    output mem_pkt_t            dmem_req_out,
    input  logic                vld_0,
    input  logic                vld_1,
    input  logic                stall_0,
    input  logic                stall_1
);

    dmem_req_ctrl_t             dmem_req_ctrl_pkt_0;
    dmem_req_ctrl_t             dmem_req_ctrl_pkt_1;
    logic [N_BITS-1:0]          dmem_wr_data;

    //////////////////////////////
    //    Pipeline registers    //
    //////////////////////////////
    dl_reg_en_rst #(
        .NUM_BITS   ($bits(dmem_req_ctrl_t))
    ) dmem_req_ctrl_pkt_reg_0 (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall_0),
        .d          (dmem_req_ctrl_pkt_in),
        .q          (dmem_req_ctrl_pkt_0)
    );

    dl_reg_en_rst #(
        .NUM_BITS   ($bits(dmem_req_ctrl_t))
    ) dmem_req_ctrl_pkt_reg_1 (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall_1),
        .d          (dmem_req_ctrl_pkt_0),
        .q          (dmem_req_ctrl_pkt_1)
    );

    dl_reg_en_rst #(
        .NUM_BITS   (N_BITS)
    ) dmem_wr_data_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (!stall_0),
        .d          (dmem_wr_data_in),
        .q          (dmem_wr_data)
    );

    assign is_dmem_rd = vld_0 && dmem_req_ctrl_pkt_0.vld &&
                        !dmem_req_ctrl_pkt_0.mtype;

    assign dmem_req_out_vld = vld_0 && dmem_req_ctrl_pkt_0.vld;

    assign dmem_req_out.mtype = dmem_req_ctrl_pkt_0.mtype ? WRITE : READ;
    assign dmem_req_out.addr = dmem_req_addr;
    assign dmem_req_out.len = dmem_req_ctrl_pkt_0.len;
    assign dmem_req_out.data = dmem_wr_data;

endmodule : lsu
