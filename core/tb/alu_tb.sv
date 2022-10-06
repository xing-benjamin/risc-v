//--------------------------------------------------------------
/*
    Filename: alu_tb.v

    RV32I arithmetic logic unit Verilog testbench
*/
//--------------------------------------------------------------

`include "sim_macros.sv"

module alu_tb;

    `SET_SIM_STOP_TIME(2000)

    localparam N_BITS = 32;
    localparam N_REGS = 32;
    localparam N_IDX = $clog2(N_REGS);

    // Instantiate DUT
    logic [3:0]         alu_op;
    logic [N_BITS-1:0]  in0;
    logic [N_BITS-1:0]  in1;
    logic [N_BITS-1:0] out;

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
        case_sel = $urandom_range(4, 0);
        case (case_sel)
            0: alu_op <= 4'b0000;
            1: alu_op <= 4'b0001;
            2: alu_op <= 4'b0010;
            3: alu_op <= 4'b1010;
            4: alu_op <= 4'b1011;
        endcase
    end

    // dump vcd
    `DUMP_ALL_VCD
endmodule