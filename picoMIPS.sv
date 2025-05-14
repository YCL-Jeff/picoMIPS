//-----------------------------------------------------
// File Name   : picoMIPS.sv
// Function    : picoMIPS top
// Author:  Yu-Cheng Lai
// Last rev. 29 April 2025
//-----------------------------------------------------
`timescale 1ns / 1ps

module picoMIPS (
    input wire clk,
    input wire [9:0] SW,
    output wire [7:0] LED
);
    wire slowclk;

    counter u_counter (
        .fastclk(clk),
        .clk(slowclk)
    );

    cpu u_cpu (
        .clk(slowclk),
        .reset(SW[9]),
        .handshake(SW[8]),
        .index(SW[7:0]),
        .result(LED)
    );

    reg prev_sw8;
    reg [7:0] prev_led;
    initial begin
        prev_sw8 = SW[8];
        prev_led = LED;
    end

    always @(posedge slowclk) begin
        if (SW[8] != prev_sw8 || LED != prev_led) begin
            prev_sw8 <= SW[8];
            prev_led <= LED;
        end
    end
endmodule