//--------------------------------------------------------------
/*
    Filename: tb_lib_macros.sv

    Macros commonly used in testbench files.
*/
//--------------------------------------------------------------

// Dump signals in Icarus Verilog
`define DUMP_ALL_VCD \
    initial begin \
        $dumpfile($sformatf("%m.vcd")); \
        $dumpvars; \
    end

// Set simulation end time
`define SET_SIM_STOP_TIME(ticks) \
    initial begin \
        #(ticks); \
        $stop; \
    end