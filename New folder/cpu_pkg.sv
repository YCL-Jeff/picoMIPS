package cpu_pkg;
    // CPU parameters
    parameter I_WIDTH = 16;        // Instruction width
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
    localparam [7:0] K [0:4] = '{17, 29, 35, 29, 17}; // K=[17,29,35,29,17]
endpackage