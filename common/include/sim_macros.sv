//--------------------------------------------------------------
/*
    Filename: sim_macros.sv

    Macros commonly used in simulations.
*/
//--------------------------------------------------------------

// Dump signals in Icarus Verilog
`define DUMP_ALL_VCD \
    initial begin \
        $dumpfile($sformatf("%s/%m.vcd", `BUILD_DIR_PATH)); \
        $dumpvars; \
    end

// Set simulation end time
`define SET_SIM_STOP_TIME(ticks) \
    initial begin \
        #(ticks); \
        $finish; \
    end

//============================
// Results checking
//============================
`define CHECK_RESULT(message, bool_cond) \
    if (bool_cond) begin \
        $info(message); \
    end else begin \
        $error(message); \
    end

`define PATHSTR(x) `"x`"
