`timescale 1ns / 1ps

module tb_wishbone();
    logic CLK, RST;
    logic i_wb_stall, i_wb_ack;
    logic [31:0] i_wb_data;
    logic o_wb_cyc, o_wb_stb, o_wb_we;
    logic [31:0] o_wb_addr;

    localparam CLK_PERIOD = 10;

    wishbone UUT(.*);

    always #(CLK_PERIOD/2) CLK = ~CLK;

    initial begin
        $dumpfile("tb_wishbone.vcd");
        $dumpvars(0, "tb_wishbone");

        CLK = 0;
        RST = 1;
        i_wb_stall = 0;
        i_wb_ack = 0;
        i_wb_data = 0;

        #CLK_PERIOD;
        @(posedge clk);
        RST = 0;
    end
endmodule