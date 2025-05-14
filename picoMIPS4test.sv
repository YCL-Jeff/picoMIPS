//-----------------------------------------------------
// File Name   : picoMIPS4test.sv
// Function    : picoMIPS4test
// Author:  Yu-Cheng Lai
// Last rev. 29 April 2025
//-----------------------------------------------------
`timescale 1ns / 1ps

module picoMIPS4test (
    input wire fastclk,
    input wire [9:0] SW,
    output wire [7:0] LED
);
    picoMIPS u_picoMIPS (
        .clk(fastclk),
        .SW(SW),
        .LED(LED)
    );
endmodule