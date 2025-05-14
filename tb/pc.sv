//-----------------------------------------------------
// File Name   : pc.sv
// Function    : Program Counter for picoMIPS
// Author:  Yu-Cheng Lai
// Last rev. 29 April 2025
//-----------------------------------------------------
module pc (
    input wire clk,
    input wire reset,
    input wire incr,
    output reg [5:0] pc
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
//            $display("Time: %0t, PC: Reset to 0, pc_reset=%b", $time, reset);
        end else if (incr) begin
            pc <= pc + 1;
//            $display("Time: %0t, PC: Incremented to %0d, incr=%b", $time, pc + 1, incr);
        end
    end
endmodule