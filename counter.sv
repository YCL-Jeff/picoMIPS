// counter.sv (Reduced display)
module counter #(
    parameter n = 4
) (
    input logic fastclk,
    input logic reset,
    output logic clk
);
    logic [n-1:0] count;

    always_ff @(posedge fastclk or posedge reset) begin
        if (reset) begin
            count <= 0;
        end else begin
            count <= count + 1;
        end
    end

    assign clk = count[n-1];
endmodule