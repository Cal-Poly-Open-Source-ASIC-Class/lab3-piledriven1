`timescale 1ns / 1ps

module tb_wishbone();
    localparam A_WIDTH = 8;
    localparam CLK_PERIOD = 45;

    logic clk, rst;
    // port A
    logic pA_wb_stb_i;
    logic [A_WIDTH:0] pA_wb_addr_i;
    logic [3:0] pA_wb_we_i;
    logic [31:0] pA_wb_data_i;
    logic pA_wb_err_o, pA_wb_ack_o, pA_wb_stall_o;
    logic [31:0] pA_wb_data_o;

    `ifdef USE_POWER_PINS
        wire VPWR;
        wire VGND;
        assign VPWR=1;
        assign VGND=0;
    `endif

    // port B
    logic pB_wb_stb_i;
    logic [A_WIDTH:0] pB_wb_addr_i;
    logic [3:0] pB_wb_we_i;
    logic [31:0] pB_wb_data_i;
    logic pB_wb_err_o, pB_wb_ack_o, pB_wb_stall_o;
    logic [31:0] pB_wb_data_o;

    wishbone UUT(.*);

    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        $dumpfile("tb_wishbone.vcd");
        $dumpvars(2, tb_wishbone);

        clk = 0;
        rst = 1;
        pA_wb_we_i = 15;
        pA_wb_addr_i = 9'b000000000;
        pA_wb_stb_i = 0;
        pA_wb_data_i = 0;

        pB_wb_we_i = 15;
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
        pA_wb_we_i = 12;
        pB_wb_we_i = 3;
        #CLK_PERIOD;
        // Have both A & B access RAM 1
        pA_wb_addr_i = 9'b100000011;
        pB_wb_addr_i = 9'b100000011;
        #CLK_PERIOD;
        @(posedge clk);
        #(CLK_PERIOD * 2);
        // Have both A & B access different RAM modules
        pA_wb_data_i = 32'hfeedfeed;
        pA_wb_we_i = 15;
        pA_wb_addr_i = 9'b000000000;
        pB_wb_addr_i = 9'b100000011;
        @(posedge clk);
        #(CLK_PERIOD * 4);
        $finish();
    end
endmodule
