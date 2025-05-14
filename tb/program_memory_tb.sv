`timescale 1ns / 1ps

module program_memory_tb;
    // Inputs
    logic reset;
    logic [5:0] address;

    // Outputs
    logic [15:0] instruction;

    // Instantiate the Unit Under Test (UUT)
    program_memory uut (
        .reset(reset),
        .address(address),
        .instruction(instruction)
    );

    initial begin
        $display("Starting program_memory simulation...");

        // Initialize inputs
        reset = 0;
        address = 0;

        // Test case 1: Read first 5 instructions
        for (int i = 0; i < 5; i++) begin
            address = i;
            #10;
            $display("Time: %0t, address=%0d, instruction=%b", $time, address, instruction);
        end

        $finish;
    end
endmodule