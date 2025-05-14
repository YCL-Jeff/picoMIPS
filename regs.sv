//-----------------------------------------------------
// File Name   : regs.sv
// Function    : Register File for picoMIPS
// Author:  Yu-Cheng Lai
// Last rev. 29 April 2025
//-----------------------------------------------------
module regs #(
    parameter ADDR_WIDTH = 2,
    parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic reset,
    input logic w,
    input logic [ADDR_WIDTH-1:0] waddr,
    input logic [ADDR_WIDTH-1:0] raddr1,
    input logic [ADDR_WIDTH-1:0] raddr2,
    input logic [DATA_WIDTH-1:0] wdata,
    output logic [DATA_WIDTH-1:0] data1_q,
    output logic [DATA_WIDTH-1:0] data2_q
);
    reg [DATA_WIDTH-1:0] gpr [0:(1<<ADDR_WIDTH)-1];

    initial begin
        for (int i = 0; i < (1<<ADDR_WIDTH); i++) begin
            gpr[i] = 0;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < (1<<ADDR_WIDTH); i++) begin
                gpr[i] <= 0;
            end
        end else if (w) begin
//            $display("Time: %0t, Regs Before Write: waddr=%0d, wdata=%h, gpr[0]=%h, gpr[1]=%h", $time, waddr, wdata, gpr[0], gpr[1]);
            gpr[waddr] <= wdata;
//            $display("Time: %0t, Regs After Write: waddr=%0d, wdata=%h, gpr[0]=%h, gpr[1]=%h", $time, waddr, wdata, gpr[0], gpr[1]);
        end
    end

    assign data1_q = gpr[raddr1];
    assign data2_q = gpr[raddr2];
endmodule