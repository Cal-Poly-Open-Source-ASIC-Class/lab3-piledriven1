/*
Lab 3: Wishbone
The goal of this module is to create a
*/

`timescale 1ns / 1ps

module wishbone (
    input logic CLK, RST,
    input logic i_wb_stall, i_wb_ack,
    input logic [31:0] i_wb_data,
    output logic o_wb_cyc, o_wb_stb, o_wb_we,
    output logic [31:0] o_wb_addr
);
    localparam A_WIDTH = 8;

    logic [3:0] WE0;
    logic EN0;
    logic [31:0] Di0, Do0;
    logic [(A_WIDTH - 1): 0] A0;

    DFFRAM256x32 RAM(.*);

endmodule