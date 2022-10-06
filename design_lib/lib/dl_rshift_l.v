//--------------------------------------------------------------
/*  
    Filename: dl_rshift_l.v

    Paramterized right logical shifter implementation.
*/
//--------------------------------------------------------------

`ifndef __DL_RSHIFT_L_V__
`define __DL_RSHIFT_L_V__

module dl_rshift_l #(
    parameter   NUM_BITS = 32,
    localparam  NUM_SHIFT_BITS = $clog2(NUM_BITS)
)(
    input  logic [NUM_BITS-1:0]       in,
    input  logic [NUM_SHIFT_BITS-1:0] shamt,
    output logic [NUM_BITS-1:0]       out
);

    assign out = in >> shamt;
    
endmodule

`endif // __DL_RSHIFT_L_V__