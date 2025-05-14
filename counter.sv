//-----------------------------------------------------
// File Name   : counter.sv
// Function    : Clock Divider for picoMIPS slow clock
// Author:  Yu-Cheng Lai
// Last rev. 29 April 2025
//-----------------------------------------------------
`timescale 1ns / 1ps

module counter #(
    parameter n = 20
) (
    input logic fastclk,
    output logic clk
);
    logic [n-1:0] count;
    logic clk_reg;

    always_ff @(posedge fastclk) begin
        count <= count + 1;
        clk_reg <= count[n-1];
    end

    assign clk = clk_reg;
endmodule