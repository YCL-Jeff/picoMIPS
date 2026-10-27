# picoMIPS — 高斯平滑處理器

[English](README.md)

以 SystemVerilog 實作的 8-bit 專用 picoMIPS 處理器，對 ROM 中 256 點含雜訊的正弦波做 5 點高斯平滑，並針對 Altera DE1-SoC（Cyclone V, 5CSEMA5F31C6）將 FPGA 資源用量最小化。**硬體成本：131。**

南安普敦大學 ELEC6234 Embedded Processors 課程作業（MSc Internet of Things），指導教授 Dr Tomasz Kazmierski。

## 運作方式

依開關設定的索引 `i` 計算一個平滑後的樣本：

```
S[i] = ( 17·W[i−2] + 29·W[i−1] + 35·W[i] + 29·W[i+1] + 17·W[i+2] ) / 128
```

| 板上 I/O | 功能 |
|---|---|
| `SW[7:0]` | 樣本索引 `i` |
| `SW[8]` | 交握，開始計算 |
| `SW[9]` | 重置 |
| `LED[7:0]` | 結果 `S[i]`（有號 8-bit） |

指令為 12-bit：`[11:6]` 操作碼、`[5:3]` 核心係數索引、`[2:0]` 有號樣本位移。只有 `MUL`、`ADD`、`END` 三個指令，整個濾波器是 11 條指令的程式。

省面積的做法：ALU 以移位加法乘 17 / 29 / 35（不用 DSP block），乘積取 `[14:7]` 位元即除以 128；多週期狀態機共用一個 ALU。

模擬步驟、檔案說明與驗證結果請見 [英文 README](README.md)。

## 作者

賴昱誠 Yu-Cheng Lai（[YCL-Jeff](https://github.com/YCL-Jeff)），南安普敦大學
