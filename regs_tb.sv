`timescale 1ns/1ps

module regs_tb;
    logic clk;
    logic reset;
    logic w;
    logic [2:0] waddr;
    logic [2:0] raddr1;
    logic [2:0] raddr2;
    logic [7:0] wdata;
    logic [7:0] data1_q;
    logic [7:0] data2_q;

    regs dut (
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

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period (100MHz)
    end

    initial begin
        // Initialize signals
        reset = 1;
        w = 0;
        waddr = 3'b000;
        raddr1 = 3'b000;
        raddr2 = 3'b000;
        wdata = 8'h00;

        // Reset
        #10;
        reset = 0;
        #10;

        // Test 1: Write to gpr[1] and read from gpr[1]
        w = 1;
        waddr = 3'b001;
        wdata = 8'hA5;
        raddr1 = 3'b001;
        raddr2 = 3'b000;
        #10; // Write
        w = 0;
        #10; // Ensure write is complete
        $display("Test 1: gpr[1] write 0xA5, read data1_q=%h, data2_q=%h", data1_q, data2_q);
        if (data1_q != 8'hA5 || data2_q != 8'h00)
            $display("Test 1 FAILED: Expected data1_q=0xA5, data2_q=0x00");

        // Test 2: Write to gpr[0] (should not write) and read from gpr[0]
        w = 1;
        waddr = 3'b000;
        wdata = 8'hFF;
        raddr1 = 3'b000;
        raddr2 = 3'b001;
        #10; // Write
        w = 0;
        #10; // Ensure write is complete
        $display("Test 2: gpr[0] write 0xFF (should not write), read data1_q=%h, data2_q=%h", data1_q, data2_q);
        if (data1_q != 8'h00 || data2_q != 8'hA5)
            $display("Test 2 FAILED: Expected data1_q=0x00, data2_q=0xA5");

        // Test 3: Write to gpr[2] and read from gpr[1] and gpr[2]
        w = 1;
        waddr = 3'b010;
        wdata = 8'h5A;
        raddr1 = 3'b001;
        raddr2 = 3'b010;
        #10; // Write
        w = 0;
        #10; // Ensure write is complete
        $display("Test 3: gpr[2] write 0x5A, read data1_q=%h, data2_q=%h", data1_q, data2_q);
        if (data1_q != 8'hA5 || data2_q != 8'h5A)
            $display("Test 3 FAILED: Expected data1_q=0xA5, data2_q=0x5A");

        // Test 4: Reset and read from gpr[1] and gpr[2]
        reset = 1;
        #10;
        reset = 0;
        raddr1 = 3'b001;
        raddr2 = 3'b010;
        #10;
        $display("Test 4: After reset, read data1_q=%h, data2_q=%h", data1_q, data2_q);
        if (data1_q != 8'h00 || data2_q != 8'h00)
            $display("Test 4 FAILED: Expected data1_q=0x00, data2_q=0x00");

        $finish;
    end
endmodule