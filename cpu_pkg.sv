//-----------------------------------------------------
// File Name   : cpu_pkg.sv
// Function    : Package for CPU parameters and types
// Author:  Yu-Cheng Lai
// Last rev. 29 April 2025
//-----------------------------------------------------
package cpu_pkg;
    // CPU parameters
    parameter I_WIDTH = 12;        // Instruction width
    parameter OPCODE_WIDTH = 6;    // OpCode width
    parameter IMM_WIDTH = 8;       // Immediate width

    // ALU functions
    typedef enum logic [1:0] {
        ALU_ADD = 2'b00,
        ALU_MUL = 2'b01
    } aluFunc_t;

    // Opcodes
    localparam MUL = 6'b000001;
    localparam ADD = 6'b000010;
    localparam END = 6'b000011;

    // Gaussian kernel
    localparam logic [7:0] K [0:4] = '{
        8'h11,  // K[0] = 17
        8'h1d,  // K[1] = 29
        8'h23,  // K[2] = 35
        8'h1d,  // K[3] = 29
        8'h11   // K[4] = 17
    };
endpackage