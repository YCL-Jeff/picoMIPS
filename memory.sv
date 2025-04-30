module data_memory (
    input logic clk,            // 時鐘信號
    input logic [7:0] addr,     // 8 位元地址，範圍 0-255
    output logic [7:0] data_out // 8 位元輸出資料
);

    // 定義 256 個 8 位元的 ROM
    logic [7:0] rom [0:255];
    
    // 初始化 ROM 從 wave.hex 檔案載入資料
    initial begin
        $readmemh("wave.hex", rom);
    end
    
    // 同步讀取資料
    always_ff @(posedge clk) begin
        data_out <= rom[addr];
    end
    
endmodule