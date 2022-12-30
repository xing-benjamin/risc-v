//--------------------------------------------------------------
/*  
    Filename: dl_adder.sv

    Paramterized adder implementation.
    Includes overflow bit.
*/
//--------------------------------------------------------------

`ifndef __DL_ADDER_SV__
`define __DL_ADDER_SV__

module dl_adder #(
    parameter   NUM_BITS = 1
)(
    input  wire [NUM_BITS-1:0]  a,
    input  wire [NUM_BITS-1:0]  b,
    output wire [NUM_BITS-1:0]  sum,
    output wire                 cout
);
    wire ab_msb_and;
    wire ab_msb_or;

    assign sum = a + b;
    assign ab_msb_and = a[NUM_BITS-1] & b[NUM_BITS-1];
    assign ab_msb_or = a[NUM_BITS-1] | b[NUM_BITS-1];
    assign cout = ab_msb_and | (ab_msb_or & !sum[NUM_BITS-1]);

endmodule

`endif // __DL_ADDER_SV__