# ELEC6234 – Embedded Processors
[中文版 (繁體中文)](README.zh-Hant.md)
## Coursework Report – picoMIPS implementation

**Author:** Yu-Cheng, Lai (YCL1C23)

**Programme:** Internet of Things

**School:** School of Electronics and Computer Science, University of Southampton

**Supervisor:** Dr Tomasz Kazmierski

---

# picoMIPS Processor

This project implemen
ts an 8-bit application-specific picoMIPS processor in SystemVerilog, designed to perform one-dimensional Gaussian smoothing convolution on a noisy waveform. The processor is optimized for minimal FPGA resource usage on the Altera Cyclone V SoC (5CSEMA5F31C6) and is synthesized for the Altera DE1 development board.

## Project Overview

The `picoMIPS` processor is a compact, custom-designed processor tailored to execute the Gaussian smoothing algorithm, processing 256 samples of a noisy waveform stored in ROM. It interfaces with external switches (SW0–SW9) for input and LEDs (LED0–LED7) for output, adhering to the coursework specifications. The design prioritizes low cost. A key achievement was the minimal hardware cost of 131, defined as:
Cost = ALMs + 500 × max(0, DSP Blocks in 9×9 mode – 2) + 30 × Kbits of RAM

## Project Structure
![Screenshot 2025-05-14 215935](https://github.com/user-attachments/assets/18de506d-fe4a-4807-8c47-95fce7af6d35)
Figure 1. picoMIPS general architecture(Kazmierski and Leech, 2014)

Key SystemVerilog source files and related documents include:

* `picoMIPS.sv`: Likely the top-level module for the entire picoMIPS processor.
* `cpu.sv`: The core logic of the MIPS processor, containing the main parts of the control unit and datapath.
* `cpu_pkg.sv`: May contain shared parameters, data types, functions, etc., used across the project.
* `alu.sv`: Arithmetic Logic Unit (ALU), responsible for executing arithmetic operations (like addition, subtraction) and logical operations (like AND, OR, XOR).
* `regs.sv`: Register File, storing the general-purpose registers of the MIPS processor.
* `decoder.sv`: Instruction Decoder, responsible for parsing instructions and generating control signals.
* `pc.sv`: Program Counter, storing the address of the next instruction to be executed.
* `program_memory.sv`: Program Memory or Instruction Memory, storing MIPS instructions.
* `opcodes.sv`: May define MIPS instruction opcodes and function codes (funct).
* `counter.sv`: A general-purpose counter module, possibly used for testing or other auxiliary functions.
* `picoMIPS_tb.sv` / `picoMIPS4test.sv`: Testbench, used for simulating and verifying the correctness of the processor design.
* `waveform_rom.sv`: Possibly a ROM module for generating or storing test waveform data, or related to test vectors. *(This was specific to the Gaussian smoother version; if your picoMIPS is more general, this might be different or not used).*
* `wave.hex`: A HEX file, very likely the machine code program to be loaded into `program_memory.sv` for execution, or test data used by the testbench.
* `README.md`: This documentation file.

## Features

* **Architecture Type**: [*Please fill this in, e.g., Single-Cycle, Multi-Cycle, Simple Pipeline*]
* **Supported Instruction Subset**: [*Please fill this in accurately, e.g., A subset of MIPS-I, listing instructions like `addu`, `subu`, `ori`, `lui`, `lw`, `sw`, `beq`, `j`*]
* **Data Path Width**: [*Please fill this in, e.g., 32-bit*]
* **Other Notable Features**: [*Please fill this in, e.g., Exception handling support? Specific design considerations?*]

## How to Use and Simulate

### Prerequisites

* A SystemVerilog compatible simulator, such as:
    * ModelSim / QuestaSim
    * Synopsys VCS
    * Cadence Xcelium / Incisive
    * Vivado Simulator (XSim) (built into Xilinx Vivado Design Suite)
    * Icarus Verilog (open-source) + GTKWave (for waveform viewing)
    * Verilator (open-source, converts Verilog/SystemVerilog to C++/SystemC)


## Future Work

*  Support for more MIPS instructions (e.g., multiplication, division).
*  Implementation of a full interrupt and exception handling mechanism.
*  Enhancing the design from single-cycle to multi-cycle or a simple pipeline for improved performance.
*  Writing more comprehensive test cases to increase code coverage.
*  Adding support for memory-mapped I/O.

## Author

* **YCL-Jeff** (Yu-Cheng, Lai)

## Reference
Leech, C. and Kazmierski, T.J. (2014) 'Energy Efficient Multi-Core Processing', ELECTRONICS, 18(1).
