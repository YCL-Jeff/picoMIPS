// File Name    : opcodes.sv
// Function     : picoMIPS/Southampton Lab opcode and type definitions
// Author       : tjk, ycl (modified)
// Last rev.    : April 2025

// Include guard
`ifndef OPCODES_SV
`define OPCODES_SV

// --- Opcodes (Macro Definitions) ---
`define NOP                   6'h00
`define ADDI                  6'h01
`define BRANCH_IF_SW8_CLEAR   6'h02
`define OUTPUT                6'h04
`define BRANCH_IF_SW8_SET     6'h08
`define LOAD                  6'h12
`define IN                    6'h21
`define ADD                   6'h2E
`define MUL                   6'h2F // MUL rd, rs, imm5
`define MUL_RR                6'h30 // MUL rd, rs, rt

// --- Package for Type Definitions ---
package opcodes_pkg;

    // --- ALU Function Codes ---
    typedef enum logic [2:0] {
        ALU_PASS_A = 3'b000,
        ALU_PASS_B = 3'b001,
        ALU_ADD    = 3'b010,
        ALU_MUL    = 3'b011,
        ALU_AND    = 3'b100,
        ALU_OR     = 3'b101,
        ALU_XOR    = 3'b110,
        ALU_NOT_A  = 3'b111
    } aluFunc_t;

endpackage

`endif // OPCODES_SV