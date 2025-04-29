// alu.sv
import cpu_pkg::*;

module alu #(
    parameter N = cpu_pkg::IMM_WIDTH // package WIDTH
    // parameter A_SIZE = ... // aluFunc_t
) (
    input logic signed [N-1:0] a, b, // 輸入操作數
    input aluFunc_t func,           // ALU 功能選擇 (來自 package)
    output logic signed [N-1:0] result // ALU 結果
    // output logic flags, carry_out // 可選的標誌位
);

    logic signed [(2*N)-1:0] multiplyResult;

    // 執行乘法 (總是計算，即使未使用)
    assign multiplyResult = a * b;

    always_comb begin
        // 預設輸出 (例如 PASS A)
        result = a;
        unique case (func) // 使用 unique case 增加檢查
            ALU_PASS_A: result = a;
            ALU_PASS_B: result = b;
            ALU_ADD:    result = a + b;
            ALU_MUL:    result = multiplyResult[(2*N)-2 : N-1]; // 取 [14:7] for N=8
            ALU_AND:    result = a & b; // 假設實現
            ALU_OR:     result = a | b; // 假設實現
            ALU_XOR:    result = a ^ b; // 假設實現
            ALU_NOT_A:  result = ~a;    // 假設實現
            // 不需要 default，因為 enum 涵蓋所有情況，
            // 或者可以加 default: result = 'x; 來捕捉未定義的 func 值
        endcase
    end

endmodule
