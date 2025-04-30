// program_memory.sv
import cpu_pkg::*;

module program_memory #(
    parameter ADDR_WIDTH = 6, // PC width
    parameter DATA_WIDTH = cpu_pkg::I_WIDTH // Instruction width
) (
    input logic reset,
    input logic [ADDR_WIDTH-1:0] address,
    output logic [DATA_WIDTH-1:0] instruction
);
    localparam MEM_DEPTH = 1 << ADDR_WIDTH; // e.g., 2^6 = 64 locations

    logic [DATA_WIDTH-1:0] prog_mem [0:MEM_DEPTH-1];

    initial begin
        // *** IMPORTANT: Change filename to the hex file you want to load ***
        // Use "test2_ldi_out.hex" for the simple test
        // Use "convolution.hex" for the convolution test
        string program_file = "test2_ldi_out.hex"; // Default to simple test
        $display("Initializing Program ROM with %s...", program_file);
        $readmemh(program_file, prog_mem);
        $display("Time: %0t, program_memory: %s loaded, mem[0]=%h", $time, program_file, prog_mem[0]);
    end

    // Combinational read, reset handled by PC providing address 0
    assign instruction = prog_mem[address];

    // Optional: Display read operation
    // always_comb begin
    //     if (reset) begin
    //         // Instruction will be prog_mem[0] because address is 0
    //         $display("Time: %0t, program_memory: RESET, address=%h, instruction=%h", $time, address, prog_mem[0]);
    //     end else begin
    //         $display("Time: %0t, program_memory: PC=%h, read instruction = %h", $time, address, instruction);
    //     end
    // end

endmodule
