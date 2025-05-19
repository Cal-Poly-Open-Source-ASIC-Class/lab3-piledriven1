`timescale 1ns / 1ps

module tb_dffram();
    // parameters
    localparam A_WIDTH = 8;
    // inputs
    logic clk, en0;
    logic [3:0] we0;
    logic [31:0] Di0;
    logic [(A_WIDTH - 1): 0] a0;
    // output
    logic [31:0] Do0;

    DFFRAM256x32 UUT(.*);

    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_dffram.vcd");
        $dumpvars(0, tb_dffram);

        clk = 0;
        a0 = 0;
        en0 = 0;
        we0 = 0;
        Di0 = 0;
        #10;
        we0 = 1;
        en0 = 1;
        @(posedge clk);
        Di0 = 'hdeadbeef;
        #10;
        we0 = 2;
        #10;
        we0 = 4;
        #10;
        we0 = 8;
        #10;
        we0 = 15;
        #10;

        $finish();
    end
endmodule