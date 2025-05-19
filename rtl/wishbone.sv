`timescale 1ns / 1ps

module wishbone #(
    parameter A_WIDTH = 8
    ) (
    // common
    input logic clk, rst,

    // port A
    input logic pA_wb_stb_i,
    input logic [A_WIDTH:0] pA_wb_addr_i,
    input logic [3:0] pA_wb_sel_i,
    input logic [31:0] pA_wb_data_i,
    output logic pA_wb_err_o, pA_wb_ack_o, pA_wb_stall_o,
    output logic [31:0] pA_wb_data_o,

    // port B
    input logic pB_wb_stb_i,
    input logic [A_WIDTH:0]  pB_wb_addr_i,
    input logic [3:0] pB_wb_sel_i,
    input logic [31:0] pB_wb_data_i,
    output logic pB_wb_err_o, pB_wb_ack_o, pB_wb_stall_o,
    output logic [31:0] pB_wb_data_o
);
    logic turn = 0;     // Set the 
    logic [3:0] ram0_wb_we0_i, ram1_wb_we0_i;
    logic ram0_wb_en0_i, ram1_wb_en0_i;
    logic [A_WIDTH - 1: 0] ram0_wb_a0_i, ram1_wb_a0_i;
    logic [31:0] ram0_wb_Di0_i, ram1_wb_Di0_i;
    logic [31:0] ram0_wb_Do0_o, ram1_wb_Do0_o;
    logic ram_selA, ram_selB, conflict;

    assign ram_selA = pA_wb_addr_i[A_WIDTH];
    assign ram_selB = pB_wb_addr_i[A_WIDTH];

    assign conflict = pA_wb_stb_i && pB_wb_stb_i && (ram_selA == ram_selB);

    always_comb begin
        // Default values
        ram0_wb_en0_i = 0;
        ram1_wb_en0_i = 0;
        ram0_wb_we0_i = 0;
        ram1_wb_we0_i = 0;
        ram0_wb_a0_i = 0;
        ram1_wb_a0_i = 0;
        ram0_wb_Di0_i = 0;
        ram1_wb_Di0_i = 0;

        if(rst) begin
            pA_wb_stall_o = 0;
            pB_wb_stall_o = 0;
        end
        else begin
            if(conflict) begin
                // both pA & pB trying to access same RAM
                if(turn) begin
                    pA_wb_stall_o = 1;
                    pB_wb_stall_o = 0;
                end
                else begin
                    pA_wb_stall_o = 0;
                    pB_wb_stall_o = 1;
                end
            end
        
            if(pA_wb_stb_i && !pA_wb_stall_o) begin
                pA_wb_stall_o = 0;
                pB_wb_stall_o = 0;
                if(ram_selA) begin
                    // Port A -> RAM1
                    ram1_wb_en0_i = 1;
                    ram1_wb_we0_i = pA_wb_sel_i;
                    ram1_wb_a0_i = pA_wb_addr_i[A_WIDTH-1:0];
                    ram1_wb_Di0_i = pA_wb_data_i;
                end
                else begin
                    // Port A -> RAM0
                    ram0_wb_en0_i = 1;
                    ram0_wb_we0_i = pA_wb_sel_i;
                    ram0_wb_a0_i = pA_wb_addr_i[A_WIDTH-1:0];
                    ram0_wb_Di0_i = pA_wb_data_i;
                end
            end
            else if (pB_wb_stb_i && !pB_wb_stall_o) begin
                pA_wb_stall_o = 0;
                pB_wb_stall_o = 0;
                if(ram_selB) begin
                    // Port B -> RAM1
                    ram1_wb_en0_i = 1;
                    ram1_wb_we0_i = pB_wb_sel_i;
                    ram1_wb_a0_i = pB_wb_addr_i[A_WIDTH-1:0];
                    ram1_wb_Di0_i = pB_wb_data_i;
                end
                else begin
                    // Port B -> RAM0
                    ram0_wb_en0_i = 1;
                    ram0_wb_we0_i = pB_wb_sel_i;
                    ram0_wb_a0_i = pB_wb_addr_i[A_WIDTH-1:0];
                    ram0_wb_Di0_i = pB_wb_data_i;
                end
            end
            else begin
                pA_wb_stall_o = 0;
                pB_wb_stall_o = 0;
                ram0_wb_en0_i = 0;
                ram1_wb_en0_i = 0;
                ram0_wb_we0_i = 0;
                ram1_wb_we0_i = 0;
                ram0_wb_a0_i = 0;
                ram1_wb_a0_i = 0;
                ram0_wb_Di0_i = 0;
                ram1_wb_Di0_i = 0; 
            end
            
        end
    end

    // need to keep track of stall, ack, and data signals
    always_ff @(posedge clk) begin
        if(rst) begin
            pA_wb_ack_o <= 0;
            pB_wb_ack_o <= 0;
        end
        else begin
            // if pA || pB
            pA_wb_data_o <= (pA_wb_addr_i[A_WIDTH]) ? ram1_wb_Do0_o : ram0_wb_Do0_o;
            pB_wb_data_o <= (pB_wb_addr_i[A_WIDTH]) ? ram1_wb_Do0_o : ram0_wb_Do0_o;
            
            if(conflict && ((turn && pB_wb_stb_i) || (!turn && pA_wb_stb_i))) begin
                turn <= ~turn;
            end
        end
    end

    // instantiate the RAM modules
    DFFRAM256x32 #(A_WIDTH) RAM0(.*,
                                .en0(ram0_wb_en0_i),
                                .we0(ram0_wb_we0_i),
                                .a0(ram0_wb_a0_i[A_WIDTH - 1:0]),
                                .Di0(ram0_wb_Di0_i),
                                .Do0(ram0_wb_Do0_o)
                                );

    DFFRAM256x32 #(A_WIDTH) RAM1(.*,
                                .en0(ram1_wb_en0_i),
                                .we0(ram1_wb_we0_i),
                                .a0(ram1_wb_a0_i[A_WIDTH - 1:0]),
                                .Di0(ram1_wb_Di0_i),
                                .Do0(ram1_wb_Do0_o)
                                );
endmodule
