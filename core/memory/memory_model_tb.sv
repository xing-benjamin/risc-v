//--------------------------------------------------------------
/*
    Filename: memory_model_tb.sv

    SystemVerilog testbench of main memory model.
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

module memory_model_tb;

    `SET_SIM_STOP_TIME(100)

    logic       clk;
    logic       rst_n;

    // Clock generator interface
    clk_intf #(.CLK_PERIOD(1)) clk_if (
        .clk    (clk)
    );

    // Reset gen interface
    reset_intf rst_if (
        .rst_n  (rst_n)
    );

    logic       pkt_in_vld;
    logic       pkt_in_rdy;
    mem_pkt_t   pkt_in;
    logic       pkt_out_vld;
    logic       pkt_out_rdy;
    mem_pkt_t   pkt_out;

    memory_model mm (
        .clk            (clk),
        .rst_n          (rst_n),
        .pkt_in_vld     (pkt_in_vld),
        .pkt_in_rdy     (pkt_in_rdy),
        .pkt_in         (pkt_in),
        .pkt_out_vld    (pkt_out_vld),
        .pkt_out_rdy    (pkt_out_rdy),
        .pkt_out        (pkt_out)
    );

    initial begin
        pkt_in.mtype <= WRITE;
        pkt_in.addr <= 32'h0;
        pkt_in.len  <= 2'b0;
        pkt_in.data <= 32'hDEADBEEF;
        pkt_in_vld <= 1'b0;
        #15;
        pkt_in_vld <= 1'b1;
        #2;
        pkt_in_vld <= 1'b0;
        #2;
        pkt_in_vld <= 1'b1;
        pkt_in.addr <= 32'h2;
        pkt_in.mtype <= READ;
        pkt_in.len <= 2'd2;
        #2;
        pkt_in_vld <= 1'b0;
        #2;
        pkt_in_vld <= 1'b1;
        pkt_in.addr <= 32'h1;
        pkt_in.len <= 2'd1;
        #2;
        pkt_in_vld <= 1'b0;
        #2;
        pkt_in_vld <= 1'b1;
        pkt_in.addr <= 32'h3;
        #2;
        pkt_in_vld <= 1'b0;
        #2;
        pkt_in_vld <= 1'b1;
        pkt_in.addr <= 32'h4;
        pkt_in.len <= 2'd0;
        pkt_in.mtype <= WRITE;
        pkt_in.data <= 32'hC0FFEE69;
        #2;
        pkt_in_vld <= 1'b0;
        #2;
        pkt_in_vld <= 1'b1;
        pkt_in.mtype <= READ;
        #2;
        pkt_in_vld <= 1'b0;
    end

    // dump vcd
    `DUMP_ALL_VCD

endmodule