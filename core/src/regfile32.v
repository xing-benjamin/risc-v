//--------------------------------------------------------------
/*  
    Filename: regfile32.v

    Paramterized 32-entry register file implementation.
    2 read ports, 1 write port
*/
//--------------------------------------------------------------

module regfile32 #(
    parameter N_BITS = 32,
    parameter N_REGS = 32,
    localparam N_IDX = $clog2(N_REGS)
)(
    input  logic                clk,
    input  logic                rst_n,

    // Read ports
    input  logic [N_IDX-1:0]    rd0_idx,
    input  logic [N_IDX-1:0]    rd1_idx,
    output logic [N_BITS-1:0]   rd0_data,
    output logic [N_BITS-1:0]   rd1_data,

    // Write port
    input  logic                wr_en,
    input  logic [N_IDX-1:0]    wr_idx,
    input  logic [N_BITS-1:0]   wr_data
);

    // Decoder
    logic [N_BITS-1:0]  wr_sel;
    dl_decoder_5p32p wr_idx_decoder (
        .in     (wr_idx),
        .out    (wr_sel)
    );

    // Register array
    generate
        for (genvar i = 0; i < N_REGS; i++) begin : genblk_regfile_arr
            logic [N_BITS-1:0]  rd_data;
            dl_reg_en_rst #(
                .NUM_BITS(N_BITS)
            ) reg_inst (
                .clk    (clk),
                .rst_n  (rst_n),
                .en     (wr_en & wr_sel[i]),
                .d      (wr_data),
                .q      (rd_data)
            );
        end

        for (genvar j = 0; j < 2; j++) begin : genblk_rd_data_mux
            logic [N_IDX-1:0]   sel;
            logic [N_BITS-1:0]  out;
            dl_mux32 #(
                .NUM_BITS(N_BITS)
            ) rd0_data_mux (
                .in0    (genblk_regfile_arr[0].rd_data),
                .in1    (genblk_regfile_arr[1].rd_data),
                .in2    (genblk_regfile_arr[2].rd_data),
                .in3    (genblk_regfile_arr[3].rd_data),
                .in4    (genblk_regfile_arr[4].rd_data),
                .in5    (genblk_regfile_arr[5].rd_data),
                .in6    (genblk_regfile_arr[6].rd_data),
                .in7    (genblk_regfile_arr[7].rd_data),
                .in8    (genblk_regfile_arr[8].rd_data),
                .in9    (genblk_regfile_arr[9].rd_data),
                .in10   (genblk_regfile_arr[10].rd_data),
                .in11   (genblk_regfile_arr[11].rd_data),
                .in12   (genblk_regfile_arr[12].rd_data),
                .in13   (genblk_regfile_arr[13].rd_data),
                .in14   (genblk_regfile_arr[14].rd_data),
                .in15   (genblk_regfile_arr[15].rd_data),
                .in16   (genblk_regfile_arr[16].rd_data),
                .in17   (genblk_regfile_arr[17].rd_data),
                .in18   (genblk_regfile_arr[18].rd_data),
                .in19   (genblk_regfile_arr[19].rd_data),
                .in20   (genblk_regfile_arr[20].rd_data),
                .in21   (genblk_regfile_arr[21].rd_data),
                .in22   (genblk_regfile_arr[22].rd_data),
                .in23   (genblk_regfile_arr[23].rd_data),
                .in24   (genblk_regfile_arr[24].rd_data),
                .in25   (genblk_regfile_arr[25].rd_data),
                .in26   (genblk_regfile_arr[26].rd_data),
                .in27   (genblk_regfile_arr[27].rd_data),
                .in28   (genblk_regfile_arr[28].rd_data),
                .in29   (genblk_regfile_arr[29].rd_data),
                .in30   (genblk_regfile_arr[30].rd_data),
                .in31   (genblk_regfile_arr[31].rd_data),
                .sel    (sel),
                .out    (out)
            );
        end
    endgenerate

    assign genblk_rd_data_mux[0].sel = rd0_idx;
    assign genblk_rd_data_mux[1].sel = rd1_idx;
    assign rd0_data = genblk_rd_data_mux[0].out;
    assign rd1_data = genblk_rd_data_mux[1].out;

endmodule