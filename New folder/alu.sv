`include "cpu_pkg.sv"
import cpu_pkg::*;

module alu (
    input wire [7:0] a,
    input wire [7:0] b,
    input aluFunc_t func,
    output reg [7:0] result
);
    logic signed [15:0] full_product;

    always @(*) begin
        case (func)
            ALU_ADD: begin
                result = a + b;
                $display("Time: %0t, ALU: ADD, a=%h, b=%h, result=%h", $time, a, b, result);
            end
            ALU_MUL: begin
                full_product = signed'(a) * signed'(b);
                result = full_product[14:7];
                $display("Time: %0t, ALU: MUL, a=%h, b=%h, full_product=%h, result=%h", $time, a, b, full_product, result);
            end
            default: result = 0;
        endcase
    end
endmodule