//--------------------------------------------------------------
/*  
    Filename: dl_counter.sv

    Paramterized incrementing counter implementation with a max value.
    Includes done bit.
*/
//--------------------------------------------------------------

`ifndef __DL_COUNTER_SV__
`define __DL_COUNTER_SV__

module dl_counter #(
    parameter   NUM_BITS = 4, 
    parameter   MAX_VAL    = 14
)(
    input  wire clk,
    input  wire rst_n,
    input  wire en,
    output reg [NUM_BITS-1:0]  q,
    output reg                 done
);
    always @(posedge clk) begin
      done <= (q == MAX_VAL);
      
      if (!rst_n) begin
        q <= 0;
      end
      else begin 
        if (en) begin
          q <= (q == MAX_VAL) ? 0 : q + 1;
        end 
        else begin 
          q <= q;
        end
      end  
    end
endmodule

`endif // __DL_COUNTER_SV__
