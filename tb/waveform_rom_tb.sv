`timescale 1ns / 1ps

module waveform_rom_tb;
    // Inputs
    logic clk;
    logic [7:0] address;

    // Outputs
    logic [7:0] data;

    // Instantiate the Unit Under Test (UUT)
    waveform_rom uut (
        .clk(clk),
        .address(address),
        .data(data)
    );

    // Clock generation
    parameter CLK_PERIOD = 2;
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        $display("Starting waveform_rom simulation...");

        // Initialize inputs
        address = 0;

        // Test case 1: Read W[0] to W[4]
        for (int i = 0; i < 5; i++) begin
            address = i;
            #10;
            $display("Time: %0t, address=%0d, data=%h", $time, address, data);
        end

        $finish;
    end
endmodule