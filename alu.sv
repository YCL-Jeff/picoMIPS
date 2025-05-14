//-----------------------------------------------------
// File Name   : alu.sv
// Function    : Arithmetic Logic Unit for picoMIPS Gaussian convolution
// Author:  Yu-Cheng Lai
// Last rev. 29 April 2025
//-----------------------------------------------------
import cpu_pkg::*;

module alu #(
    parameter WIDTH = 8
)(
    input logic signed [WIDTH-1:0] a,        // First signed input operand
    input logic signed [WIDTH-1:0] b,        // Second signed input operand
    input aluFunc_t func,                    // ALU function select (e.g., ALU_ADD, ALU_MUL)
    output logic [WIDTH-1:0] result,         // ALU result
    output logic [3:0] flags                 // Flags output for overflow detection and status
);
    always_comb begin
        flags = 4'b0;  // Initialize flags to 0
        case (func)
            ALU_ADD: begin
                automatic logic signed [WIDTH:0] sum = a + b;  // Compute sum with extra bit for overflow
                result = sum[WIDTH-1:0];                       // Truncate to WIDTH bits
                // Overflow detection: Check if signs of inputs match but differ from result
                flags[0] = (a[WIDTH-1] == b[WIDTH-1]) && (a[WIDTH-1] != result[WIDTH-1]);
                // Zero flag: Set if result is zero
                flags[2] = (result == 0);
                // Sign flag: Set to the sign bit of the result
                flags[3] = result[WIDTH-1];
            end
            ALU_MUL: begin
                automatic logic signed [(2*WIDTH)-1:0] full_product;  // 16-bit product for 8-bit inputs
                automatic logic signed [WIDTH-1:0] temp_result;       // Temporary result for bits 14..7

                // Optimized multiplication for K = [17, 29, 35]
                if (b == 8'd17) begin
                    full_product = ($signed(a) << 4) + $signed(a);  // 17*x = x*16 + x
                end else if (b == 8'd29) begin
                    full_product = ($signed(a) << 5) - ($signed(a) << 2) + $signed(a);  // 29*x = x*32 - x*4 + x
                end else if (b == 8'd35) begin
                    full_product = ($signed(a) << 5) + ($signed(a) << 2) - $signed(a);  // 35*x = x*32 + x*4 - x
                end else begin
                    full_product = $signed(a) * $signed(b);  // General multiplication
                end

                // Extract bits 14..7 from the 16-bit product
                temp_result = full_product[14:7];

                // Rounding logic: If the result is negative and (bit 6 or bit 5 is 1), round up
                if (full_product[15] && (full_product[6] || full_product[5])) begin
                    result = temp_result + 1;
                end else begin
                    result = temp_result;
                end

                // Overflow detection: Check if full_product[15:8] matches the sign bit (full_product[15])
                flags[0] = !((full_product[15:8] == 8'hFF && full_product[15]) || 
                             (full_product[15:8] == 8'h00 && !full_product[15]));
                // Zero flag: Set if result is zero
                flags[2] = (result == 0);
                // Sign flag: Set to the sign bit of the result
                flags[3] = result[WIDTH-1];


            end
            default: begin
                result = 0;      // Default result: 0
                flags = 4'b0;    // Default flags: 0
            end
        endcase
    end
endmodule