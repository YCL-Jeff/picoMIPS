`timescale 1ns / 1ps

`include "cpu_pkg.sv"
import cpu_pkg::*;

module alu_tb;
    // Inputs
    logic [7:0] a, b;
    aluFunc_t func;

    // Outputs
    logic [7:0] result;

    // Instantiate the Unit Under Test (UUT)
    alu uut (
        .a(a),
        .b(b),
        .func(func),
        .result(result)
    );

    initial begin
        $display("Starting ALU simulation...");

        // Test case 1: ADD (a=10, b=5)
        a = 8'h0A;
        b = 8'h05;
        func = ALU_ADD;
        #10;
        $display("Test 1: ADD, a=%h, b=%h, result=%h", a, b, result);

        // Test case 2: MUL (a=F6 (-10), b=11 (17))
        a = 8'hF6;
        b = 8'h11;
        func = ALU_MUL;
        #10;
        $display("Test 2: MUL, a=%h, b=%h, result=%h", a, b, result);

        $finish;
    end
endmodule