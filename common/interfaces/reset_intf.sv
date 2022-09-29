//--------------------------------------------------------------
/*
    Filename: reset_intf.sv

    Reset interface. Generates active-low reset signal.
*/
//--------------------------------------------------------------

interface reset_intf #(
    parameter COLD_RESET_TIME = 10
)(
    output logic rst_n
);
    initial begin
        rst_n = 1'b0;
        #COLD_RESET_TIME;
        rst_n <= 1'b1;
    end
    
    task drive_reset_val(logic rst_val);
        rst_n <= rst_val;
    endtask

endinterface