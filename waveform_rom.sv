// waveform_rom.sv
import cpu_pkg::*;

module waveform_rom #(
    parameter DATA_WIDTH = cpu_pkg::IMM_WIDTH, // Data width
    parameter ADDR_WIDTH = cpu_pkg::IMM_WIDTH  // Address width
) (
    input logic [ADDR_WIDTH-1:0] address,
    output logic signed [DATA_WIDTH-1:0] data // Output signed data
);
    localparam MEM_DEPTH = 1 << ADDR_WIDTH; // e.g., 2^8 = 256 locations

    logic signed [DATA_WIDTH-1:0] rom [0:MEM_DEPTH-1]; // Use signed logic

    initial begin
        // Load Kernel at 0x00-0x04
        rom[8'h00] = 8'sh11; // K[0]=17
        rom[8'h01] = 8'sh1D; // K[1]=29
        rom[8'h02] = 8'sh23; // K[2]=35
        rom[8'h03] = 8'sh1D; // K[3]=29
        rom[8'h04] = 8'sh11; // K[4]=17
        $display("Time: %0t, waveform_rom: Kernel initialized.", $time);

        // Load waveform data starting at 0x10
        $display("Initializing Waveform ROM with wave.hex...");
        // *** Ensure wave.hex exists in the simulation directory ***
        $readmemh("wave.hex", rom, 8'h10); // Load starting at address 0x10
        $display("Time: %0t, waveform_rom: wave.hex loaded, rom[0]=%h", $time, rom[0]); // Display K[0]
        $display("Time: %0t, waveform_rom: rom[0x10]=%h", $time, rom[8'h10]); // Display first wave sample
    end

    // Combinational read
    assign data = rom[address];

    // Optional: Display read operation
    // always @(address) begin
    //     $display("Time: %0t, waveform_rom: address=%h, data=%h (%d)", $time, address, data, data);
    // end
endmodule
