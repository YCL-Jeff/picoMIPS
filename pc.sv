// pc.sv
import cpu_pkg::*; // 匯入 package

module pc #(
    parameter PC_WIDTH = 6 // Assuming 6-bit PC based on cpu.sv output
) (
    input logic clk,
    input logic reset,
    input logic PCincr,      // Enable PC increment (usually 1 unless branch taken)
    input logic branch_en,   // Branch enable signal
    input logic [PC_WIDTH-1:0] branch_target, // Branch target address
    output logic [PC_WIDTH-1:0] pc // Program Counter output
);

    logic [PC_WIDTH-1:0] pc_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_reg <= {PC_WIDTH{1'b0}};
            $display("Time: %0t, PC: Reset asserted, pc_reg <= %h", $time, {PC_WIDTH{1'b0}});
        end else if (branch_en) begin
            pc_reg <= branch_target; // Load branch target address
            $display("Time: %0t, PC: Branch enabled, pc_reg <= %h", $time, branch_target);
        end else if (PCincr) begin
            pc_reg <= pc_reg + 1; // Increment PC
            $display("Time: %0t, PC: Incrementing PC, pc_reg <= %h", $time, pc_reg + 1);
        end
        // else: Hold current PC value if PCincr is 0 and branch_en is 0 (e.g., stall)
    end

    assign pc = pc_reg;

endmodule
