//--------------------------------------------------------------
/*
    Filename: clk_intf.sv

    Clock interface. Generates output clock with parameterized
    frequency.
*/
//--------------------------------------------------------------

interface clk_intf #(
    parameter CLK_PERIOD = 5
)(
    output logic clk
);
    initial begin
        clk = 1'b0;
    end
    
    always #(CLK_PERIOD) clk = !clk;

endinterface