// regs.sv
import cpu_pkg::*;

module regs #(
    parameter DATA_WIDTH = cpu_pkg::IMM_WIDTH, // 使用 package 中的數據寬度
    parameter ADDR_WIDTH = cpu_pkg::REG_ADDR_WIDTH // 使用 package 中的地址寬度
) (
    input logic clk,
    input logic reset,
    input logic w,                       // Write enable
    input logic [ADDR_WIDTH-1:0] waddr,  // Write address
    input logic [ADDR_WIDTH-1:0] raddr1, // Read address 1
    input logic [ADDR_WIDTH-1:0] raddr2, // Read address 2
    input logic [DATA_WIDTH-1:0] wdata,  // Write data
    output logic [DATA_WIDTH-1:0] data1_q, // Read data 1
    output logic [DATA_WIDTH-1:0] data2_q  // Read data 2
);

    localparam NUM_REGS = 1 << ADDR_WIDTH; // 計算暫存器數量 (e.g., 2^3 = 8)

    // Register storage array (R0 is often hardwired to 0)
    logic [DATA_WIDTH-1:0] gpr [NUM_REGS-1:0];

    // Write operation (synchronous)
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers to 0
            for (int i = 0; i < NUM_REGS; i++) begin
                gpr[i] <= {DATA_WIDTH{1'b0}};
            end
            $display("Time: %0t, regs: Reset all registers to 0", $time);
        end else if (w && (waddr != 0)) begin // Write enable is high, and not writing to R0
            gpr[waddr] <= wdata;
            $display("Time: %0t, regs: Writing gpr[%d] = %h, w=%b, waddr=%d", $time, waddr, wdata, w, waddr);
        end else if (w && (waddr == 0)) begin
             $display("Time: %0t, regs: Write to R0 ignored, w=%b, waddr=%d", $time, w, waddr);
        end else begin
             $display("Time: %0t, regs: No write, w=%b, waddr=%d", $time, w, waddr);
        end
    end

    // Read operations (combinational)
    // R0 always reads 0
    assign data1_q = (raddr1 == 0) ? {DATA_WIDTH{1'b0}} : gpr[raddr1];
    assign data2_q = (raddr2 == 0) ? {DATA_WIDTH{1'b0}} : gpr[raddr2];

endmodule
