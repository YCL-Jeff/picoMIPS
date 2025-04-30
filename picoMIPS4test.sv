// picoMIPS4test.sv (V8.1 - Handles Active Low Reset from SW[9])
// Assumes a 'counter' module exists, e.g., counter #(parameter n=4) c (...)

// Include necessary definitions if counter module requires them
`include "counter.sv"

module picoMIPS4test (
    input logic fastclk,     // High-speed clock input (e.g., 100MHz from testbench)
    input logic [9:0] SW,    // 10 Switches: SW[9] is active-low reset, SW[8:0] for core
    output logic [7:0] LED   // 8 LEDs connected to picoMIPS output
);
    // Internal signals
    logic clk;         // Slower clock for the picoMIPS core
    logic core_reset;  // Active-high reset signal for the core

    // Reset generation: Invert SW[9] (active-low) to create active-high reset
    assign core_reset = ~SW[9];

    // Clock Divider: Instantiate a counter to generate the core clock 'clk' from 'fastclk'
    // Parameter 'n' likely controls the division ratio (e.g., divides by 2^n or n?)
    // Assuming it divides by 4 based on typical usage (n=4 might mean divide by 16, check counter code)
    // Let's assume #(.n(4)) means divide by 4 for a 25MHz core clock from 100MHz fastclk.
    // The counter should also be reset by the core_reset signal.
    counter #(.n(4)) c (
        .fastclk(fastclk),
        .reset(core_reset), // Pass the active-high reset to the counter
        .clk(clk)           // Output the divided clock
    );

    // Instantiate the picoMIPS Core
    // Connect the generated clock, reset, relevant switches, and LEDs
    picoMIPS myDesign (
        .clk(clk),             // Use the divided clock
        .reset(core_reset),    // Use the generated active-high reset
        .SW(SW[8:0]),          // Pass SW[8:0] to the core (SW[8] for branch, SW[7:0] for IN)
        .LED(LED),             // Connect LED output
        .pc()                  // Leave the pc output unconnected at this level
    );

endmodule