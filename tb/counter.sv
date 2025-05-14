//-----------------------------------------------------
// File Name   : counter.sv
// Function    : Clock Divider for picoMIPS slow clock
// Author:  Yu-Cheng Lai
// Last rev. 29 April 2025
//-----------------------------------------------------
`timescale 1ns / 1ps

module counter (
    input  wire fastclk,
    input wire reset,
    output logic clk
);
    logic [11:0] counter;
    logic prev_clk;

    initial begin
        counter = 0;
        clk = 0;
        prev_clk = 0;
    end

    always @(posedge fastclk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk <= 0;
            prev_clk <= 0;
        end else begin
            counter <= counter + 1'b1;
            clk <= counter[11];
            if (clk != prev_clk) begin
                prev_clk <= clk;
            end
        end
    end
endmodule