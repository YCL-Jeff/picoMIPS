// cpu_pkg.sv: Package for CPU definitions

package cpu_pkg;

    // --- Instruction Format Parameters (Example - Adjust if needed) ---
    parameter I_WIDTH = 16;
    parameter OPCODE_WIDTH = 6;
    parameter REG_ADDR_WIDTH = 3;
    parameter IMM_WIDTH = 8;
    parameter IMM5_WIDTH = 5;

    // --- Opcodes (Defined as parameters) ---
    parameter logic [OPCODE_WIDTH-1:0] P_NOP                   = 6'h00;
    parameter logic [OPCODE_WIDTH-1:0] P_ADDI                  = 6'h01;
    parameter logic [OPCODE_WIDTH-1:0] P_BRANCH_IF_SW8_CLEAR   = 6'h02;
    parameter logic [OPCODE_WIDTH-1:0] P_OUTPUT                = 6'h04;
    parameter logic [OPCODE_WIDTH-1:0] P_BRANCH_IF_SW8_SET     = 6'h08;
    parameter logic [OPCODE_WIDTH-1:0] P_LOAD                  = 6'h12;
    parameter logic [OPCODE_WIDTH-1:0] P_IN                    = 6'h21; // Assuming this is the opcode for IN
    parameter logic [OPCODE_WIDTH-1:0] P_ADD                   = 6'h2E;
    parameter logic [OPCODE_WIDTH-1:0] P_MUL                   = 6'h2F; // MUL rd, rs, imm5
    parameter logic [OPCODE_WIDTH-1:0] P_MUL_RR                = 6'h30; // MUL rd, rs, rt

    // --- ALU Function Codes ---
    typedef enum logic [2:0] {
        ALU_PASS_A = 3'b000,
        ALU_PASS_B = 3'b001,
        ALU_ADD    = 3'b010,
        ALU_MUL    = 3'b011,
        ALU_AND    = 3'b100, // Assuming these exist if needed
        ALU_OR     = 3'b101,
        ALU_XOR    = 3'b110,
        ALU_NOT_A  = 3'b111
        // No ALU_DEFAULT needed here
    } aluFunc_t;

endpackage : cpu_pkg
