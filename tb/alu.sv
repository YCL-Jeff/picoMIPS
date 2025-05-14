import cpu_pkg::*;

module alu #(
    parameter WIDTH = 8
)(
    input logic signed [WIDTH-1:0] a,
    input logic signed [WIDTH-1:0] b,
    input aluFunc_t func,
    output logic [WIDTH-1:0] result,
    output logic [3:0] flags  // 添加 flags 輸出，用於溢出檢測
);
    always_comb begin
        flags = 4'b0;  // 初始化 flags
        case (func)
            ALU_ADD: begin
                automatic logic signed [WIDTH:0] sum = a + b;
                result = sum[WIDTH-1:0];
                // 溢出檢測：檢查符號位是否一致
                flags[0] = (a[WIDTH-1] == b[WIDTH-1]) && (a[WIDTH-1] != result[WIDTH-1]);
                // 零標誌和符號標誌
                flags[2] = (result == 0);
                flags[3] = result[WIDTH-1];
            end
            ALU_MUL: begin
                automatic logic signed [(2*WIDTH)-1:0] full_product;
                automatic logic signed [WIDTH-1:0] temp_result;

                // 針對 K = [17, 29, 35] 的乘法優化
                if (b == 8'd17) begin
                    full_product = ($signed(a) << 4) + $signed(a);  // 17*x = x*16 + x
                end else if (b == 8'd29) begin
                    full_product = ($signed(a) << 5) - ($signed(a) << 2) + $signed(a);  // 29*x = x*32 - x*4 + x
                end else if (b == 8'd35) begin
                    full_product = ($signed(a) << 5) + ($signed(a) << 2) - $signed(a);  // 35*x = x*32 + x*4 - x
                end else begin
                    full_product = $signed(a) * $signed(b);  // 通用乘法
                end

                // 提取 bits 14..7
                temp_result = full_product[14:7];

                // 舍入邏輯：如果結果為負且 (bit 6 或 bit 5 為 1)，則向上舍入
                if (full_product[15] && (full_product[6] || full_product[5])) begin
                    result = temp_result + 1;
                end else begin
                    result = temp_result;
                end

                // 溢出檢測：檢查 full_product[15:8] 是否全為 full_product[15]
                flags[0] = !((full_product[15:8] == 8'hFF && full_product[15]) || 
                             (full_product[15:8] == 8'h00 && !full_product[15]));
                // 零標誌和符號標誌
                flags[2] = (result == 0);
                flags[3] = result[WIDTH-1];


                // Debug log: Display multiplication details
                $display("Time=%0t, ALU MUL: a=%h, b=%h, full_product=%h, temp_result=%h, result=%h", $time, a, b, full_product, temp_result, result);


            end
            default: begin
                result = 0;
                flags = 4'b0;
            end
        endcase
    end
endmodule