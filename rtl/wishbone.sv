`timescale 1ns / 1ps

module wishbone #(
    parameter A_WIDTH = 8
    ) (
    // common
    input wire clk, rst,

    // port A
    input wire pA_wb_stb_i,
    input wire [A_WIDTH:0] pA_wb_addr_i,
    input wire [3:0] pA_wb_we_i,
    input wire [31:0] pA_wb_data_i,
    output reg pA_wb_ack_o, pA_wb_stall_o,
    output reg [31:0] pA_wb_data_o,

    // port B
    input wire pB_wb_stb_i,
    input wire [A_WIDTH:0]  pB_wb_addr_i,
    input wire [3:0] pB_wb_we_i,
    input wire [31:0] pB_wb_data_i,
    output reg pB_wb_ack_o, pB_wb_stall_o,
    output reg [31:0] pB_wb_data_o
);
    logic turn;
    logic [3:0] ram0_wb_we0_i, ram1_wb_we0_i;
    logic ram0_wb_en0_i, ram1_wb_en0_i;
    logic [A_WIDTH - 1: 0] ram0_wb_a0_i, ram1_wb_a0_i, ram_addrA, ram_addrB;
    logic [31:0] ram0_wb_Di0_i, ram1_wb_Di0_i;
    logic [31:0] ram0_wb_Do0_o, ram1_wb_Do0_o;
    logic ram_selA, ram_selB, conflict;

    assign ram_selA = pA_wb_addr_i[A_WIDTH];
    assign ram_selB = pB_wb_addr_i[A_WIDTH];
    assign ram_addrA = pA_wb_addr_i[A_WIDTH - 1:0];
    assign ram_addrB = pB_wb_addr_i[A_WIDTH - 1:0];

    assign conflict = pA_wb_stb_i && pB_wb_stb_i && (ram_selA == ram_selB);

    always_comb begin
        // Default values
        pA_wb_stall_o = 0;
        pB_wb_stall_o = 0;
        pA_wb_data_o = 0;
        pB_wb_data_o = 0;
        ram0_wb_en0_i = 0;
        ram1_wb_en0_i = 0;
        ram0_wb_we0_i = 0;
        ram1_wb_we0_i = 0;
        ram0_wb_a0_i = 0;
        ram1_wb_a0_i = 0;
        ram0_wb_Di0_i = 0;
        ram1_wb_Di0_i = 0;

        if(rst) begin
            
        end
        else begin
            if(conflict) begin
                // both pA & pB trying to access same RAM so alternate
                if(!turn) begin
                    pA_wb_stall_o = 1;
                    pB_wb_stall_o = 0;
                end
                else begin
                    pA_wb_stall_o = 0;
                    pB_wb_stall_o = 1;
                end
            end

            // port A RAM selection
            if(pA_wb_stb_i && !pA_wb_stall_o) begin
                if(ram_selA) begin
                    ram1_wb_en0_i = 1;
                    ram1_wb_we0_i = pA_wb_we_i;
                    ram1_wb_a0_i = ram_addrA;
                    ram1_wb_Di0_i = pA_wb_data_i;
                    pA_wb_data_o = ram1_wb_Do0_o;
                end
                else begin
                    ram0_wb_en0_i = 1;
                    ram0_wb_we0_i = pA_wb_we_i;
                    ram0_wb_a0_i = ram_addrA;
                    ram0_wb_Di0_i = pA_wb_data_i;
                    pA_wb_data_o = ram0_wb_Do0_o;
                end
            end

            // port B RAM selection
            if(pB_wb_stb_i && !pB_wb_stall_o) begin
                if(ram_selB) begin
                    ram1_wb_en0_i = 1;
                    ram1_wb_we0_i = pB_wb_we_i;
                    ram1_wb_a0_i = ram_addrB;
                    ram1_wb_Di0_i = pB_wb_data_i;
                    pB_wb_data_o = ram1_wb_Do0_o;
                end
                else begin
                    ram0_wb_en0_i = 1;
                    ram0_wb_we0_i = pB_wb_we_i;
                    ram0_wb_a0_i = ram_addrB;
                    ram0_wb_Di0_i = pB_wb_data_i;
                    pB_wb_data_o = ram0_wb_Do0_o;
                end
            end
        end
    end

    // need to keep track of stall, ack, and data signals
    always_ff @(posedge clk) begin
        if(rst) begin
            turn <= 0;
            pA_wb_ack_o <= 0;
            pB_wb_ack_o <= 0;
        end
        else begin
            if(conflict)
                turn <= ~turn;
            else
                turn <= turn;
            
            if(pA_wb_stb_i && !pA_wb_stall_o)
                pA_wb_ack_o <= 1;
            else
                pA_wb_ack_o <= 0;

            if(pB_wb_stb_i && !pB_wb_stall_o)
                pB_wb_ack_o <= 1;
            else
                pB_wb_ack_o <= 0;
        end
    end

    // instantiate the RAM modules
    DFFRAM256x32 RAM0(
        .CLK(clk),
        .EN0(ram0_wb_en0_i),
        .WE0(ram0_wb_we0_i),
        .A0(ram0_wb_a0_i),
        .Di0(ram0_wb_Di0_i),
        .Do0(ram0_wb_Do0_o)
    );

    DFFRAM256x32 RAM1(
        .CLK(clk),
        .EN0(ram1_wb_en0_i),
        .WE0(ram1_wb_we0_i),
        .A0(ram1_wb_a0_i),
        .Di0(ram1_wb_Di0_i),
        .Do0(ram1_wb_Do0_o)
    );
endmodule
