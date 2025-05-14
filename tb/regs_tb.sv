`timescale 1ns / 1ps

module regs_tb;
    // Inputs
    logic clk;
    logic reset;
    logic w;
    logic [0:0] waddr, raddr1, raddr2;
    logic [7:0] wdata;

    // Outputs
    logic [7:0] data1_q, data2_q;

    // Instantiate the Unit Under Test (UUT)
    regs #(.ADDR_WIDTH(1)) uut (
        .clk(clk),
        .reset(reset),
        .w(w),
        .waddr(waddr),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .wdata(wdata),
        .data1_q(data1_q),
        .data2_q(data2_q)
    );

    // Clock generation
    parameter CLK_PERIOD = 2;
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        $display("Starting regs simulation...");

        // Initialize inputs
        reset = 0; // Active low reset
        w = 0;
        waddr = 0;
        raddr1 = 0; // acc
        raddr2 = 1; // regfile
        wdata = 0;

        // Reset pulse
        #10;
        reset = 1; // Deassert reset
        #10;

        // Test case 1: Write to acc (gpr[0])
        @(negedge clk); // Align with clock edge
        w = 1;
        waddr = 0;
        wdata = 8'h0A;
        @(posedge clk); // Wait for write to happen
        w = 0;
        @(posedge clk); // Wait for data to stabilize
        $display("Test 1: acc_val=%h, regfile_val=%h", data1_q, data2_q);

        // Test case 2: Write to regfile (gpr[1])
        @(negedge clk); // Align with clock edge
        w = 1;
        waddr = 1;
        wdata = 8'h05;
        @(posedge clk); // Wait for write to happen
        w = 0;
        @(posedge clk); // Wait for data to stabilize
        $display("Test 2: acc_val=%h, regfile_val=%h", data1_q, data2_q);

        $finish;
    end
endmodule