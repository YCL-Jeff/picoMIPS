//-----------------------------------------------------
// File Name   : picoMIPS_tb.sv
// Function    : Testbench for picoMIPS
// Author:  Yu-Cheng Lai
// Last rev. 29 April 2025
//-----------------------------------------------------
`timescale 1ns / 1ps

module picoMIPS_tb;
    logic fastclk;
    logic [9:0] SW;
    logic [7:0] LED;

    picoMIPS4test uut (
        .fastclk(fastclk),
        .SW(SW),
        .LED(LED)
    );

    parameter CLK_PERIOD = 2; // 50MHz clock period (2 ns)
    parameter FAST_CLK_CYCLES = 4096;

    initial begin
        $display("Starting picoMIPS simulation...");
        fastclk = 0;
        forever #(CLK_PERIOD/2) begin
            fastclk = ~fastclk;
        end
    end

    initial begin
        // Initialize signals
        fastclk = 0;
        SW[9] = 0;   // 確保 reset 為 0
        SW[8] = 1'b0;
        SW[7:0] = 8'd2; // 初始值

        $display("Time: %0t, TB: Initial state - SW[8]=%b, SW[7:0]=%d", $time, SW[8], SW[7:0]);

        // --- Test 1: i = 2 ---
        $display("\n--- Test 1: i = 2 ---");
        SW[7:0] = 8'd2;
        #(FAST_CLK_CYCLES*CLK_PERIOD);
        SW[8] = 1'b1;
        $display("Time: %0t, TB: SW[8]=%b (Enable)", $time, SW[8]);
        #(FAST_CLK_CYCLES*100*CLK_PERIOD);
        $display("Time: %0t, TB: Index i=2, LED=%d (0x%h)", $time, LED, LED);

        // Reset
        SW[9] = 1'b1;
        $display("Time: %0t, TB: SW[9]=%b (Reset)", $time, SW[9]);
        #(FAST_CLK_CYCLES*10*CLK_PERIOD);
        SW[9] = 1'b0;
        $display("Time: %0t, TB: SW[9]=%b (Reset released)", $time, SW[9]);
        #(FAST_CLK_CYCLES*100*CLK_PERIOD);

        // --- Test 2: i = 80 ---
        $display("\n--- Test 2: i = 80 ---");
        SW[7:0] = 8'd50;
        #(FAST_CLK_CYCLES*CLK_PERIOD);
        SW[8] = 1'b1;
        $display("Time: %0t, TB: SW[8]=%b (Enable)", $time, SW[8]);
        #(FAST_CLK_CYCLES*100*CLK_PERIOD);
        $display("Time: %0t, TB: Index i=80, LED=%d (0x%h)", $time, LED, LED);

        // Reset
        SW[9] = 1'b1;
        $display("Time: %0t, TB: SW[9]=%b (Reset)", $time, SW[9]);
        #(FAST_CLK_CYCLES*100*CLK_PERIOD);
        SW[9] = 1'b0;
        $display("Time: %0t, TB: SW[9]=%b (Reset released)", $time, SW[9]);
        #(FAST_CLK_CYCLES*100*CLK_PERIOD);

        // --- Test 3: i = 128 ---
        $display("\n--- Test 3: i = 128 ---");
        SW[7:0] = 8'd128;
        #(FAST_CLK_CYCLES*CLK_PERIOD);
        SW[8] = 1'b1;
        $display("Time: %0t, TB: SW[8]=%b (Enable)", $time, SW[8]);
        #(FAST_CLK_CYCLES*100*CLK_PERIOD);
        $display("Time: %0t, TB: Index i=128, LED=%d (0x%h)", $time, LED, LED);

        // Reset
        SW[9] = 1'b1;
        $display("Time: %0t, TB: SW[9]=%b (Reset)", $time, SW[9]);
        #(FAST_CLK_CYCLES*100*CLK_PERIOD);
        SW[9] = 1'b0;
        $display("Time: %0t, TB: SW[9]=%b (Reset released)", $time, SW[9]);
        #(FAST_CLK_CYCLES*100*CLK_PERIOD);

        // --- Test 4: i = 190 ---
        $display("\n--- Test 4: i = 190 ---");
        SW[7:0] = 8'd190;
        #(FAST_CLK_CYCLES*CLK_PERIOD);
        SW[8] = 1'b1;
        $display("Time: %0t, TB: SW[8]=%b (Enable)", $time, SW[8]);
        #(FAST_CLK_CYCLES*100*CLK_PERIOD);
        $display("Time: %0t, TB: Index i=190, LED=%d (0x%h)", $time, LED, LED);

        // Reset
        SW[9] = 1'b1;
        $display("Time: %0t, TB: SW[9]=%b (Reset)", $time, SW[9]);
        #(FAST_CLK_CYCLES*100*CLK_PERIOD);
        SW[9] = 1'b0;
        $display("Time: %0t, TB: SW[9]=%b (Reset released)", $time, SW[9]);
        #(FAST_CLK_CYCLES*100*CLK_PERIOD);

        // --- Test 5: i = 254 ---
        $display("\n--- Test 5: i = 254 ---");
        SW[7:0] = 8'd254;
        #(FAST_CLK_CYCLES*CLK_PERIOD);
        SW[8] = 1'b1;
        $display("Time: %0t, TB: SW[8]=%b (Enable)", $time, SW[8]);
        #(FAST_CLK_CYCLES*100*CLK_PERIOD);
        $display("Time: %0t, TB: Index i=254, LED=%d (0x%h)", $time, LED, LED);

        $finish;
    end

    // Waves
    initial begin
        $dumpfile("picoMIPS.vcd");
        $dumpvars(0, picoMIPS_tb);
        $dumpvars(1, uut.u_picoMIPS.u_cpu.state);  // cpu/state
        $dumpvars(1, uut.u_picoMIPS.u_cpu.acc_val);  // cpu/acc_val
    end
endmodule