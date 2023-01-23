//--------------------------------------------------------------
/*
    Filename: core_tb.sv

    SystemVerilog testbench of RV32I core.
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

import memory_types_pkg::*;

module core_tb;

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

    logic       imem_req_vld;
    logic       imem_req_rdy;
    mem_pkt_t   imem_req;
    logic       imem_rsp_vld;
    logic       imem_rsp_rdy;
    mem_pkt_t   imem_rsp;
    logic       dmem_req_vld;
    logic       dmem_req_rdy;
    mem_pkt_t   dmem_req;
    logic       dmem_rsp_vld;
    logic       dmem_rsp_rdy;
    mem_pkt_t   dmem_rsp;

    core dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .imem_req_vld   (imem_req_vld),
        .imem_req_rdy   (imem_req_rdy),
        .imem_req       (imem_req),
        .imem_rsp_vld   (imem_rsp_vld),
        .imem_rsp_rdy   (imem_rsp_rdy),
        .imem_rsp       (imem_rsp),
        .dmem_req_vld   (dmem_req_vld),
        .dmem_req_rdy   (dmem_req_rdy),
        .dmem_req       (dmem_req),
        .dmem_rsp_vld   (dmem_rsp_vld),
        .dmem_rsp_rdy   (dmem_rsp_rdy),
        .dmem_rsp       (dmem_rsp)
    );

    memory_model imem (
        .clk            (clk),
        .rst_n          (rst_n),
        .pkt_in_vld     (imem_req_vld),
        .pkt_in_rdy     (imem_req_rdy),
        .pkt_in         (imem_req),
        .pkt_out_vld    (imem_rsp_vld),
        .pkt_out_rdy    (imem_rsp_rdy),
        .pkt_out        (imem_rsp)
    );

    memory_model dmem (
        .clk            (clk),
        .rst_n          (rst_n),
        .pkt_in_vld     (dmem_req_vld),
        .pkt_in_rdy     (dmem_req_rdy),
        .pkt_in         (dmem_req),
        .pkt_out_vld    (dmem_rsp_vld),
        .pkt_out_rdy    (dmem_rsp_rdy),
        .pkt_out        (dmem_rsp)
    );

    initial begin
        $readmemh($sformatf("%s.hex", `PATHSTR(`TEST_PATH)), imem.mem);
        $readmemh("/Users/benjaminxing/Projects/risc-v/core/tb/dmem.hex", dmem.mem);
    end

    // dump vcd
    `DUMP_ALL_VCD

endmodule