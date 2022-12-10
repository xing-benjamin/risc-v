//--------------------------------------------------------------
/*
    Filename: memory_model.sv

    SystemVerilog implementation of main memory model.

    For full-word (32 bit) accesses, the address must be 4-byte
    aligned. For half-word (16 bit) accesses, the address must
    be 2-byte aligned. Byte accesses can occur to any address in
    the address space.
*/
//--------------------------------------------------------------

import memory_types_pkg::*;

module memory_model #(
    parameter SIZE = 64,
    parameter WORD_SIZE = 32
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        pkt_in_vld,
    output logic        pkt_in_rdy,
    input  mem_pkt_t    pkt_in,
    output logic        pkt_out_vld,
    input  logic        pkt_out_rdy,
    output mem_pkt_t    pkt_out
);

    logic [WORD_SIZE-1:0]   mem   [SIZE];

    logic [WORD_SIZE-1:0]   rd_tmp_raw;
    logic [WORD_SIZE-1:0]   rd_tmp;
    logic [WORD_SIZE-1:0]   wr_tmp;
    logic [3:0]             sel_rd;
    logic [3:0]             sel_wr;

    assign sel_rd = (pkt_in.len == 4'd0) ? 4'b1111 :
                    (pkt_in.len == 4'd1) ? 4'b0001 :
                    (pkt_in.len == 4'd2) ? 4'b0011 : 4'b0000;
    assign sel_wr = sel_rd << pkt_in.addr[1:0];
    assign rd_tmp_raw = mem[pkt_in.addr[31:2]];
    assign rd_tmp = rd_tmp_raw >> (8 * pkt_in.addr[1:0]);
    assign wr_tmp = pkt_in.data << (8 * pkt_in.addr[1:0]);

    always @(posedge clk) begin
        if (!rst_n) begin
            pkt_in_rdy <= 1'b0;
            pkt_out_vld <= 1'b0;
        end else begin
            pkt_in_rdy <= 1'b1;
            pkt_out_vld <= pkt_in_vld;
        end
    end

    always @(posedge clk) begin
        if (pkt_in_vld) begin
            pkt_out.mtype <= pkt_in.mtype;
            pkt_out.addr <= pkt_in.addr;
            pkt_out.len <= pkt_in.len;
            if (pkt_in.mtype == READ) begin
                pkt_out.data[31:24] <= sel_rd[3] ? rd_tmp[31:24] : 8'hxx;
                pkt_out.data[23:16] <= sel_rd[2] ? rd_tmp[23:16] : 8'hxx;
                pkt_out.data[15:8] <= sel_rd[1] ? rd_tmp[15:8] : 8'hxx;
                pkt_out.data[7:0] <= sel_rd[0] ? rd_tmp[7:0] : 8'hxx;
            end else if (pkt_in.mtype == WRITE) begin
                mem[pkt_in.addr[31:2]][31:24] <= sel_wr[3] ? wr_tmp[31:24] : rd_tmp_raw[31:24];
                mem[pkt_in.addr[31:2]][23:16] <= sel_wr[2] ? wr_tmp[23:16] : rd_tmp_raw[23:16];
                mem[pkt_in.addr[31:2]][15:8] <= sel_wr[1] ? wr_tmp[15:8] : rd_tmp_raw[15:8];
                mem[pkt_in.addr[31:2]][7:0] <= sel_wr[0] ? wr_tmp[7:0] : rd_tmp_raw[7:0];
            end
        end
    end

endmodule : memory_model