[English Version](README.md)

---
# ELEC6234 – 嵌入式處理器
## 課程作業報告 – picoMIPS 實作

**作者:** 賴**(英文名Yu-Cheng)** (YCL1C23)
**課程:** 物聯網 (Internet of Things)
**學院:** 南安普敦大學電子與計算機科學院 (School of Electronics and Computer Science, University of Southampton)
**指導教授:** Dr Tomasz Kazmierski

---

# picoMIPS 處理器

這是一個使用 SystemVerilog 實作的基礎 MIPS 指令集架構 (ISA) 處理器專案。

## 專案概觀

`picoMIPS` 旨在實作一個小型的 MIPS 處理器核心，能夠執行一部分基礎的 MIPS 指令。此專案適合用於學習計算機組織與結構、數位邏輯設計以及 SystemVerilog 硬體描述語言。

## 專案結構

主要的 SystemVerilog 原始碼檔案及相關文件如下：

* `picoMIPS.sv`: 可能是整個 picoMIPS 處理器的頂層模組。
* `cpu.sv`: MIPS 處理器的核心邏輯，包含控制單元和資料路徑的主要部分。
* `cpu_pkg.sv`: 可能包含專案中共享的參數、資料類型、函式等定義。
* `alu.sv`: 算術邏輯單元 (ALU)，負責執行算術運算 (如加法、減法) 和邏輯運算 (如 AND, OR, XOR)。
* `regs.sv`: 暫存器檔案 (Register File)，儲存 MIPS 處理器的通用暫存器。
* `decoder.sv`: 指令解碼器，負責解析指令並產生控制訊號。
* `pc.sv`: 程式計數器 (Program Counter)，儲存下一個要執行的指令位址。
* `program_memory.sv`: 程式記憶體或指令記憶體，儲存 MIPS 指令。
* `opcodes.sv`: 可能定義了 MIPS 指令的操作碼 (opcodes) 和功能碼 (funct codes)。
* `counter.sv`: 一個通用的計數器模組，可能用於測試或其他輔助功能。
* `picoMIPS_tb.sv` / `picoMIPS4test.sv`: 測試平台 (Testbench)，用於模擬和驗證處理器設計的正確性。
* `waveform_rom.sv`: 可能是一個用於產生或儲存測試波形資料的 ROM 模組，或與測試向量相關。*(這是針對高斯平滑器版本的特定內容；如果您的 picoMIPS 更通用，這部分可能不同或未使用)。*
* `wave.hex`: HEX 檔案，非常可能是載入到 `program_memory.sv` 中作為執行的機器碼程式，或者是測試平台使用的測試資料。
* `README.md`: 英文版說明檔案。
* `README.zh-Hant.md`: 本說明檔案 (繁體中文版)。

## 功能特色

* **架構類型**: [*請根據您的實際實作情況填寫，例如：單週期 (Single-Cycle), 多週期 (Multi-Cycle), 簡單流水線 (Simple Pipeline)*]
* **支援的指令子集**: [*請根據您的實際實作情況準確填寫，例如：MIPS-I 的一個子集，列舉如 `addu`, `subu`, `ori`, `lui`, `lw`, `sw`, `beq`, `j` 等指令*]
* **資料路徑寬度**: [*請根據您的實際實作情況填寫，例如：32位元*]
* **其他顯著功能**: [*請根據您的實際實作情況填寫，例如：是否支援例外處理？是否有特定的設計考量？*]

## 如何使用與模擬

### 前置需求

* 一個支援 SystemVerilog 的模擬器，例如：
    * ModelSim / QuestaSim
    * Synopsys VCS
    * Cadence Xcelium / Incisive
    * Vivado Simulator (XSim) (Xilinx Vivado 設計套件內建)
    * Icarus Verilog (開源) + GTKWave (波形檢視)
    * Verilator (開源，將 Verilog/SystemVerilog 轉換為 C++/SystemC)
* [*若需要其他特定的編譯工具或環境，請在此列出*]

### 模擬步驟 (範例)

以下步驟為通用範例。請根據您選擇的模擬器和專案配置進行調整。

1.  **準備程式/測試資料：**
    * 確認 `wave.hex` 檔案的內容。如果它是您的測試程式，通常需要被載入到 `program_memory.sv` 中。這通常是透過在 `program_memory.sv` 或測試平台 (`picoMIPS_tb.sv`) 中使用 SystemVerilog 的 `$readmemh` 系統任務來完成的。
        例如，在 `program_memory.sv` 或其初始化區塊中，您可能會有：
        ```systemverilog
        initial begin
            $readmemh("path/to/wave.hex", memory_array_variable); // 請將 'memory_array_variable' 替換為您實際的記憶體陣列變數名稱
        end
        ```
        請確保路徑正確，或者 `wave.hex` 檔案相對於模擬工作目錄的路徑是可存取的。

2.  **編譯原始碼檔案：**
    編譯順序可能很重要。通常，套件檔案 (`cpu_pkg.sv`, `opcodes.sv`) 會先編譯，然後是較低層級的模組，最後是頂層模組和測試平台。
    ```bash
    # 以下為通用範例指令。請針對您的模擬器進行調整。
    # ModelSim/QuestaSim 範例 (vlog, vsim):
    # vlog cpu_pkg.sv opcodes.sv alu.sv regs.sv decoder.sv pc.sv program_memory.sv counter.sv cpu.sv picoMIPS.sv waveform_rom.sv picoMIPS_tb.sv
    #
    # Vivado XSim 範例 (xvlog, xelab):
    # xvlog --sv cpu_pkg.sv opcodes.sv alu.sv regs.sv decoder.sv pc.sv program_memory.sv counter.sv cpu.sv picoMIPS.sv waveform_rom.sv picoMIPS_tb.sv
    # xelab picoMIPS_tb --snapshot picoMIPS_sim -debug typical # (或其他偵錯選項)
    ```

3.  **執行模擬：**
    ```bash
    # ModelSim/QuestaSim 範例:
    # vsim work.picoMIPS_tb -do "run -all; exit" # (批次模式)
    # # 或 vsim work.picoMIPS_tb (GUI 模式，然後手動加入波形並執行)
    #
    # Vivado XSim 範例:
    # xsim picoMIPS_sim --gui # (GUI 模式)
    # # 或 xsim picoMIPS_sim --runall (批次模式)
    ```

4.  **觀察結果：**
    * 檢查模擬器控制台的輸出訊息（例如，在測試平台中使用 `$display` 顯示的暫存器狀態或測試結果）。
    * 使用波形檢視器（如 GTKWave，或 ModelSim/QuestaSim/Vivado 的內建檢視器）觀察訊號變化是否符合預期。

***請在此提供更詳細、針對您專案和偏好模擬器的具體指令和說明。***

## 已實作指令集

`picoMIPS` 處理器目前支援以下 MIPS 指令 ([*請根據您的實際設計，準確列出所有已實作的指令*])：

* **R-Type:**
    * `addu`
    * `subu`
    * `and`
    * `or`
    * `xor`
    * `slt`
    * `sll`
    * `srl`
    * `jr`
    * [*其他 R-Type 指令...*]
* **I-Type:**
    * `addiu`
    * `ori`
    * `lui`
    * `lw`
    * `sw`
    * `beq`
    * `bne`
    * [*其他 I-Type 指令...*]
* **J-Type:**
    * `j`
    * `jal`
    * [*其他 J-Type 指令...*]

## 未來工作 (可選)

* [ ] 支援更多 MIPS 指令 (例如：乘法、除法指令)。
* [ ] 實作完整的中斷與例外處理機制。
* [ ] 將設計從單週期改進為多週期或簡單流水線以提高效能。
* [ ] 撰寫更全面的測試案例，增加程式覆蓋率。
* [ ] 增加對記憶體映射 I/O 的支援。

## 作者

* **YCL-Jeff** (賴 **(英文名Yu-Cheng)**)

## 授權條款

[*請選擇一個選項並刪除另一個。請將 [年份] 更新為當前年份，例如 2025。*]

**選項 1: 保留所有權利**

Copyright (c) [2025] YCL-Jeff. All Rights Reserved.

**選項 2: MIT 授權條款**
(如果您選擇此項，建議同時將以下授權文字儲存為一個名為 `LICENSE` 或 `LICENSE.md` 的檔案放在儲存庫的根目錄。)