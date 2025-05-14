//-----------------------------------------------------
// File Name   : program_memory.sv
// Function    : Program Memory for picoMIPS instructions
// Author:  Yu-Cheng Lai
// Last rev. 29 April 2025
//-----------------------------------------------------
`timescale 1ns / 1ps
import cpu_pkg::*;

module program_memory #(
    parameter ADDR_WIDTH = 6
) (
    input wire reset,
    input wire [ADDR_WIDTH-1:0] address,
    output wire [I_WIDTH-1:0] instruction
);
    reg [I_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    initial begin
    // Instruction format: [11:6] opcode, [5:3] imm, [2:0] offset
    mem[0]  = 12'b000001_000_110; // MUL K[0], offset = -2 (110 = -2 in 3-bit 2's complement)
    mem[1]  = 12'b000010_000_000; // ADD
    mem[2]  = 12'b000001_001_111; // MUL K[1], offset = -1 (111 = -1)
    mem[3]  = 12'b000010_000_000; // ADD
    mem[4]  = 12'b000001_010_000; // MUL K[2], offset = 0
    mem[5]  = 12'b000010_000_000; // ADD
    mem[6]  = 12'b000001_011_001; // MUL K[3], offset = 1
    mem[7]  = 12'b000010_000_000; // ADD
    mem[8]  = 12'b000001_100_010; // MUL K[4], offset = 2
    mem[9]  = 12'b000010_000_000; // ADD
    mem[10] = 12'b000011_000_000; // END
end

    assign instruction = reset ? 12'b0 : mem[address];
endmodule