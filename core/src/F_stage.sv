//--------------------------------------------------------------
/*
    Filename: F_stage.sv

    Fetch stage top module.
*/
//--------------------------------------------------------------

import core_types_pkg::*;

module F_stage (
    input  logic        clk,
    input  logic        rst_n,
    output [N_BITS-1:0] pc,
    output [N_BITS-1:0] pc_plus4,
    output [N_BITS-1:0] next_pc,
    input  [N_BITS-1:0] jmp_branch_tgt
);

    logic        pc_reg_en;

    assign pc_reg_en = rst_n; // FIXME BEN

    // Program counter
    dl_reg_en_rst #(
        .NUM_BITS   (32),
        // 1st instruction fetched at 0x00000000
        .RST_VAL    (32'hfffffffc)
    ) program_cntr (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (pc_reg_en),
        .d          (next_pc),
        .q          (pc)
    );

    assign pc_plus4 = pc + 32'd4;

    dl_mux4 #(
        .NUM_BITS   (32)
    ) next_pc_mux (
        .in0    (pc_plus4),
        .in1    (jmp_branch_tgt),
        .in2    (),
        .in3    (),
        .sel    (2'b00), // FIXME BEN
        .out    (next_pc)
    );

endmodule : F_stage