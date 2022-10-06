//--------------------------------------------------------------
/*  
    Filename: dl_rshift_a.v

    Paramterized right arithmetic shifter implementation.
*/
//--------------------------------------------------------------

`ifndef __DL_RSHIFT_A_V__
`define __DL_RSHIFT_A_V__

module dl_rshift_a #(
    parameter   NUM_BITS = 32,
    localparam  NUM_SHIFT_BITS = $clog2(NUM_BITS)
)(
    input  logic [NUM_BITS-1:0]         in,
    input  logic [NUM_SHIFT_BITS-1:0]   shamt,
    output logic [NUM_BITS-1:0]         out
);

    generate
        for (genvar i = 0; i < NUM_SHIFT_BITS; i++) begin : genblk_rshift_a
            logic [NUM_BITS-1:0] stage_in;
            logic [NUM_BITS-1:0] stage_out;
            assign stage_out = (shamt[i]) ? 
                        {{(2**i){in[NUM_BITS-1]}}, stage_in[NUM_BITS-1:2**i]} :
                        stage_in;
        end

        for (genvar j = 1; j < NUM_SHIFT_BITS; j++) begin
            assign genblk_rshift_a[j].stage_in = genblk_rshift_a[j-1].stage_out;
        end
    endgenerate

    assign genblk_rshift_a[0].stage_in = in;
    assign out = genblk_rshift_a[NUM_SHIFT_BITS-1].stage_out;

endmodule

`endif // __DL_RSHIFT_A_V__