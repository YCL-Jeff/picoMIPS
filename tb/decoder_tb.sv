`timescale 1ns / 1ps

module decoder_tb;
    // Inputs
    logic [15:0] instruction;

    // Outputs
    logic [5:0] opcode;
    logic signed [4:0] offset;
    logic [4:0] imm;

    // Instantiate the Unit Under Test (UUT)
    decoder uut (
        .instruction(instruction),
        .opcode(opcode),
        .offset(offset),
        .imm(imm)
    );

    initial begin
        $display("Starting decoder simulation...");

        // Test case 1: MUL [i-2], K[0]
        instruction = 16'b000001_11110_00000; // opcode=000001, offset=11110 (-2), imm=00000 (0)
        #10;
        $display("Test 1: instruction=%b, opcode=%b, offset=%0d, imm=%0d", instruction, opcode, offset, imm);

        // Test case 2: MUL [i-1], K[1]
        instruction = 16'b000001_11111_00001; // opcode=000001, offset=11111 (-1), imm=00001 (1)
        #10;
        $display("Test 2: instruction=%b, opcode=%b, offset=%0d, imm=%0d", instruction, opcode, offset, imm);

        // Test case 3: ADD acc, regfile
        instruction = 16'b000010_00000_00000; // opcode=000010, offset=00000 (0), imm=00000 (0)
        #10;
        $display("Test 3: instruction=%b, opcode=%b, offset=%0d, imm=%0d", instruction, opcode, offset, imm);

        $finish;
    end
endmodule