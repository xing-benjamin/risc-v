//--------------------------------------------------------------
/*  
    Filename: dl_rshift.v

    Paramterized right shifter implementation.
    Produces logical or arithmetic shift based on input 'sh_type'
*/
//--------------------------------------------------------------

`ifndef __DL_RSHIFT_V__
`define __DL_RSHIFT_V__

module dl_rshift #(
    parameter   NUM_BITS = 32,
    localparam  NUM_SHIFT_BITS = $clog2(NUM_BITS)
)(
    input  logic                        sh_type, // 0 - logical, 1 - arithmetic
    input  logic [NUM_BITS-1:0]         in,
    input  logic [NUM_SHIFT_BITS-1:0]   shamt,
    output logic [NUM_BITS-1:0]         out
);

    generate
        for (genvar i = 0; i < NUM_SHIFT_BITS; i++) begin : genblk_rshift
            logic [NUM_BITS-1:0] stage_in;
            logic [NUM_BITS-1:0] stage_out;
            logic                shift_in;
            assign shift_in = in[NUM_BITS-1] & sh_type;
            assign stage_out = (shamt[i]) ?
                        {{(2**i){shift_in}}, stage_in[(NUM_BITS-1):(2**i)]} :
                        stage_in;
        end

        for (genvar j = 1; j < NUM_SHIFT_BITS; j++) begin
            assign genblk_rshift[j].stage_in = genblk_rshift[j-1].stage_out;
        end
    endgenerate

    assign genblk_rshift[0].stage_in = in;
    assign out = genblk_rshift[NUM_SHIFT_BITS-1].stage_out;

endmodule

`endif // __DL_RSHIFT_V__