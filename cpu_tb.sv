`timescale 1ns / 1ps
import cpu_pkg::*; // 匯入 package

module cpu_tb;

    // --- Parameters ---
    parameter CLK_PERIOD = 10; // Clock period in ns
    parameter RESET_DURATION = CLK_PERIOD * 5;

    // --- Testbench Signals ---
    logic clk;
    logic reset;
    logic [8:0] switches_in; // SW8 + SW7-0
    logic [7:0] leds_out;    // LED output from CPU (IMM_WIDTH wide)
    logic [5:0] cpu_pc;      // PC output from CPU

    // --- Instantiate the CPU (DUT) ---
    cpu dut (
        .clk(clk),
        .reset(reset),
        .SW(switches_in),
        .LED(leds_out),
        .pc(cpu_pc)
    );

    // --- Clock Generation ---
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // --- Reset Generation ---
    initial begin
        reset = 1;
        $display("[%0t] Reset Asserted.", $time);
        #(RESET_DURATION);
        reset = 0;
        $display("[%0t] Reset Deasserted.", $time);
    end

    // --- Test Sequence ---
    initial begin
        $display("Starting CPU Simple Testbench...");
        switches_in = 9'b0_00000000; // SW8=0 initially

        // Wait for reset to finish
        wait (reset === 0);
        @(posedge clk);

        $display("[%0t] === Running Simple Test Program (test2_ldi_out.hex) ===", $time);

        // Wait for LDI R1, LDI R2, OUT R1 to complete (approximate timing)
        // LDI R1 finishes WB around cycle 0+4 = 4
        // LDI R2 finishes WB around cycle 1+4 = 5
        // OUT R1 finishes WB around cycle 2+4 = 6
        // We need to check LED after OUT R1 completes WB. Wait until ~cycle 7.
        #(CLK_PERIOD * 7); // Wait 7 cycles (70 ns)
        $display("[%0t] PC = %h. Checking LED after OUT R1.", $time, cpu_pc);
        assert (leds_out === 8'haa) else $error("ERROR: Expected LED output AA, got %h", leds_out);

        // Wait for OUT R2 to complete (finishes WB around cycle 3+4 = 7)
        // Check LED after OUT R2 completes WB. Wait until ~cycle 8.
        #(CLK_PERIOD * 1); // Wait 1 more cycle (Total 8 cycles, 80 ns)
        $display("[%0t] PC = %h. Checking LED after OUT R2.", $time, cpu_pc);
        assert (leds_out === 8'hbb) else $error("ERROR: Expected LED output BB, got %h", leds_out);

        // Wait for BRANCH to reach EX stage (cycle 4+2 = 6) and affect PC
        // PC should jump back to 04 around cycle 7.
        // Let's check PC around cycle 8.
        // #(CLK_PERIOD * 1); // Already at cycle 8
        $display("[%0t] PC = %h. Checking PC after BRANCH (SW8=0).", $time, cpu_pc);
        assert (cpu_pc === 6'h04) else $error("ERROR: Branch (SW8=0) failed! PC is %h, expected 04", cpu_pc);

        // Now set SW8=1 and check if the loop continues at 04
        $display("[%0t] Setting SW8 = 1.", $time);
        switches_in[8] = 1'b1;

        // Wait a few cycles to see if PC increments past 04
        #(CLK_PERIOD * 5);
        $display("[%0t] PC = %h. Checking PC after BRANCH (SW8=1).", $time, cpu_pc);
        // Since branch is not taken, PC should have incremented from 04
        assert (cpu_pc === 6'h05) else $error("ERROR: Branch (SW8=1) not taken failed! PC is %h, expected 05", cpu_pc);


        // End Simulation
        $display("[%0t] Simple Testbench finished.", $time);
        $finish;
    end

endmodule
