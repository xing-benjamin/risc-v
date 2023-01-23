//--------------------------------------------------------------
/*
    Filename: memory_types_pkg.sv

    Package containing defines, enums, structs for memory system.
*/
//--------------------------------------------------------------

`ifndef __MEMORY_TYPES_PKG_SV__
`define __MEMORY_TYPES_PKG_SV__

package memory_types_pkg;

    typedef struct packed {
        logic [2:0]  mtype;
        logic [31:0] addr;
        logic [1:0]  len;
        logic [31:0] data;
    } mem_pkt_t;

    typedef enum logic [2:0] {
        READ = 3'd0,
        WRITE = 3'd1
    } mem_pkt_type_e;

endpackage

`endif // __MEMORY_TYPES_PKG_SV__
