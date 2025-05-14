`timescale 1ns / 1ps

module cpu_tb;
    logic clk;
    logic reset;
    logic handshake;
    logic [7:0] index;
    logic [7:0] result;

    // Instantiate the Unit Under Test (UUT)
    cpu uut (
        .clk(clk),
        .reset(reset),
        .handshake(handshake),
        .index(index),
        .result(result)
    );

    // Clock generation
    parameter CLK_PERIOD = 2;
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        $display("Starting CPU simulation...");
        reset = 1;
        handshake = 0;
        index = 8'd2;  // 調整 index 值
        #10;
        reset = 0;
        #10;
        handshake = 1;
        #300;
        handshake = 0;
        #10;
        $finish;
    end
endmodule