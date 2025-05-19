`timescale 1ns / 1ps

module tb_wishbone();
    localparam A_WIDTH = 8;
    localparam CLK_PERIOD = 10;

    logic clk, rst;
    // port A
    logic pA_wb_stb_i;
    logic [A_WIDTH:0] pA_wb_addr_i;
    logic [3:0] pA_wb_sel_i;
    logic [31:0] pA_wb_data_i;
    logic pA_wb_err_o, pA_wb_ack_o, pA_wb_stall_o;
    logic [31:0] pA_wb_data_o;

    // port B
    logic pB_wb_stb_i;
    logic [A_WIDTH:0] pB_wb_addr_i;
    logic [3:0] pB_wb_sel_i;
    logic [31:0] pB_wb_data_i;
    logic pB_wb_err_o, pB_wb_ack_o, pB_wb_stall_o;
    logic [31:0] pB_wb_data_o;

    wishbone #(A_WIDTH) UUT(.*);

    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        $dumpfile("tb_wishbone.vcd");
        $dumpvars(0, tb_wishbone);

        clk = 0;
        rst = 1;
        pA_wb_sel_i = 15;
        pA_wb_addr_i = 9'b000000000;
        pA_wb_stb_i = 0;
        pA_wb_data_i = 0;

        pB_wb_sel_i = 15;
        pB_wb_addr_i = 9'b100000000;
        pB_wb_stb_i = 0;
        pB_wb_data_i = 0;

        #CLK_PERIOD;
        rst = 0;
        pA_wb_stb_i = 1;
        pB_wb_stb_i = 1;

        @(posedge clk);
        pA_wb_data_i = 32'hdeaddead;
        pB_wb_data_i = 32'hfeedbeef;
        @(posedge clk);
        pA_wb_sel_i = 12;
        pB_wb_sel_i = 3;
        #CLK_PERIOD;
        // Have both A & B access RAM 1
        pA_wb_addr_i = 9'b100000011;
        pB_wb_addr_i = 9'b100000011;
        #CLK_PERIOD;
        @(posedge clk);
        #(CLK_PERIOD * 5);

        $finish();
    end
endmodule
