//--------------------------------------------------------------
/*
    Filename: M_stage.sv

    Memory stage top module.
*/
//--------------------------------------------------------------

import core_types_pkg::*;

module M_stage #(
    parameter N_BITS = 32
)(
    input  logic [N_BITS-1:0]   X_stage_data,
    input  logic [N_BITS-1:0]   mem_rsp_data,
    output logic [N_BITS-1:0]   out
);

    dl_mux2 #(
        .NUM_BITS   (32)
    ) M_out_mux (
        .in0        (X_stage_data),
        .in1        (mem_rsp_data),
        .sel        (1'b0),
        .out        (out)
    );

endmodule : M_stage