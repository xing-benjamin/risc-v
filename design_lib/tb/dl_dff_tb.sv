//--------------------------------------------------------------
/*
    Filename: dl_dff_tb.v

    D flip-flop Verilog testbench.
    Target simulator: Icarus Verilog -g2012
*/
//--------------------------------------------------------------

module dl_dff_tb;

    localparam CLK_CYC_NS = 1;

    logic clk;
    logic d;
    logic q;

    initial begin
        clk = 1'b0;
        d = 1'b0;

        #100;
        $stop;
    end

    always #(CLK_CYC_NS) clk = ~clk;
        

    always begin
        #($urandom_range(10, 0));
        @(negedge clk);
        d = ~d;
    end

    dl_dff dl_dff_inst (
        .clk    (clk),
        .d      (d),
        .q      (q)
    );

    // dump vcd
    initial begin
        $dumpfile("dl_dff.vcd");
        $dumpvars(0, dl_dff_tb);
    end

endmodule