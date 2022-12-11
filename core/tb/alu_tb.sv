//--------------------------------------------------------------
/*
    Filename: alu_tb.v

    RV32I arithmetic logic unit Verilog testbench
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

import core_types_pkg::*;

module alu_tb;

    `SET_SIM_STOP_TIME(2000)

    localparam N_BITS = 32;
    localparam N_REGS = 32;
    localparam N_IDX = $clog2(N_REGS);

    // Instantiate DUT
    alu_op_t            alu_op;
    logic [N_BITS-1:0]  in0;
    logic [N_BITS-1:0]  in1;
    logic [N_BITS-1:0]  out;

    alu #(.N_BITS(32)) alu_inst (
        .alu_op     (alu_op),
        .in0        (in0),
        .in1        (in1),
        .out        (out)
    );

    always begin
        #($urandom_range(10, 0));
        in0 <= $urandom();
    end

    always begin
        #($urandom_range(10, 0));
        in1 <= $urandom();
    end

    int case_sel;
    always begin
        #($urandom_range(10, 0));
        case_sel = $urandom_range(9, 0);
        case (case_sel)
            0: alu_op <= 4'b0000;
            1: alu_op <= 4'b0001;
            2: alu_op <= 4'b0010;
            3: alu_op <= 4'b0100;
            4: alu_op <= 4'b0110;
            5: alu_op <= 4'b1000;
            6: alu_op <= 4'b1010;
            7: alu_op <= 4'b1011;
            8: alu_op <= 4'b1100;
            9: alu_op <= 4'b1110;
        endcase
    end

    logic [N_BITS-1:0] exp_output;
    string alu_trace_str;
    always @(alu_op, in0, in1) begin
        #0.1;
        exp_output = get_expected_output(alu_op, in0, in1);
        alu_trace_str = $sformatf("alu_op = %4b, in0 = %8h, in1 = %8h, out = %8h, exp_out = %8h",
                        alu_op, in0, in1, out, exp_output);
        `CHECK_RESULT(alu_trace_str, exp_output === out)
    end

    function logic [N_BITS-1:0] get_expected_output(logic [3:0] alu_op,
                                                    logic [N_BITS-1:0] in0,
                                                    logic [N_BITS-1:0] in1);
        case (alu_op)
            ADD: return in0 + in1;
            SUB: return in0 - in1;
            SLL: return in0 << in1[4:0];
            SLT: return $signed(in0) < $signed(in1);
            SLTU: return in0 < in1; // FIXME BEN: what if in0 == in1 == 0?
            XOR: return in0 ^ in1;
            SRL: return in0 >> in1[4:0];
            SRA: return $signed(in0) >>> in1[4:0];
            OR: return in0 | in1;
            AND: return in0 & in1;
        endcase
    endfunction : get_expected_output

    // dump vcd
    `DUMP_ALL_VCD
endmodule
