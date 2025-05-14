//-----------------------------------------------------
// File Name   : decoder.sv
// Function    : Instruction Decoder for picoMIPS
// Author:  Yu-Cheng Lai
// Last rev. 29 April 2025
//-----------------------------------------------------
import cpu_pkg::*;

module decoder (
    input wire [I_WIDTH-1:0] instruction,
    output wire [OPCODE_WIDTH-1:0] opcode,
    output wire signed [2:0] offset,
    output wire [2:0] imm
);
    assign opcode = instruction[11:6];
    assign offset = instruction[2:0];
    assign imm = instruction[5:3];

    always @(*) begin
//        $display("Time: %0t, Decoder: instruction=%h, opcode=%h, offset=%h, imm=%h", $time, instruction, opcode, offset, imm);
    end
endmodule