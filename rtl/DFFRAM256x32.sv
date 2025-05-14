/*
 * DFFRAM.v
 *
 * * A 256x32 DFFRAM (1 Kbytes)
 *
 * This is free software: you can redistribute it and/or modify
 * it under the terms of the Apache License, Version 2.0 (the "License").
 *
 * DFFRAM is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * Apache License, Version 2.0 for more details.
 *
 * You should have received a copy of the Apache License, Version 2.0
 * along with DFFRAM. If not, see <https://www.apache.org/licenses/LICENSE-2.0>.
 *
 * For further information, please visit .
 *
 */

`timescale 1ns / 1ps

`default_nettype none

module DFFRAM256x32 #(
    parameter A_WIDTH = 8
)(
    input logic clk,
    input logic [3:0] we0,
    input logic en0,
    input logic [31:0] Di0,
    input logic [(A_WIDTH - 1): 0] a0,
    output logic [31:0] Do0
);
    localparam NUM_WORDS = 2 ** A_WIDTH;

    reg [31:0] RAM[(NUM_WORDS - 1):0];

    always_ff @(posedge clk) begin
        if(en0) begin
            Do0 <= RAM[a0];
            if(we0[0]) RAM[a0][7:0] <= Di0[7:0];
            if(we0[1]) RAM[a0][15:8] <= Di0[15:8];
            if(we0[2]) RAM[a0][23:16] <= Di0[23:16];
            if(we0[3]) RAM[a0][31:24] <= Di0[31:24];
        end
        else
            Do0 <= 32'b0;
    end
endmodule
