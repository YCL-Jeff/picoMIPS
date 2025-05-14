# ELEC6234 – Embedded Processors
[中文版 (繁體中文)](README.zh-Hant.md)
## Coursework Report – picoMIPS implementation

**Author:** Yu-Cheng, Lai (YCL1C23)

**Programme:** Internet of Things

**School:** School of Electronics and Computer Science, University of Southampton

**Supervisor:** Dr Tomasz Kazmierski

---

# picoMIPS Processor

This project is an implementation of a basic MIPS Instruction Set Architecture (ISA) processor using SystemVerilog.

## Project Overview

`picoMIPS` aims to implement a compact MIPS processor core capable of executing a subset of fundamental MIPS instructions. This project is suitable for learning computer organization and architecture, digital logic design, and the SystemVerilog hardware description language.

## Project Structure

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
* [*List any other specific compilation tools or environments if required*]

### Simulation Steps (Example)

The following steps are generic examples. Please adapt them according to your chosen simulator and project configuration.

1.  **Prepare Program/Test Data:**
    * Confirm the contents of the `wave.hex` file. If it's your test program, it typically needs to be loaded into `program_memory.sv`. This is often done using SystemVerilog's `$readmemh` system task within `program_memory.sv` or the testbench (`picoMIPS_tb.sv`).
        For example, in `program_memory.sv` or its initialization block, you might have:
        ```systemverilog
        initial begin
            $readmemh("path/to/wave.hex", memory_array_variable); // Replace 'memory_array_variable' with your actual memory array
        end
        ```
        Ensure the path is correct, or that `wave.hex` is accessible via a relative path from the simulation working directory.

2.  **Compile Source Files:**
    The compilation order can be important. Typically, package files (`cpu_pkg.sv`, `opcodes.sv`) are compiled first, followed by lower-level modules, and finally the top-level module and testbench.
    ```bash
    # These are generic example commands. Please adjust for your simulator.
    # Example for ModelSim/QuestaSim (vlog, vsim):
    # vlog cpu_pkg.sv opcodes.sv alu.sv regs.sv decoder.sv pc.sv program_memory.sv counter.sv cpu.sv picoMIPS.sv waveform_rom.sv picoMIPS_tb.sv
    #
    # Example for Vivado XSim (xvlog, xelab):
    # xvlog --sv cpu_pkg.sv opcodes.sv alu.sv regs.sv decoder.sv pc.sv program_memory.sv counter.sv cpu.sv picoMIPS.sv waveform_rom.sv picoMIPS_tb.sv
    # xelab picoMIPS_tb --snapshot picoMIPS_sim -debug typical # (or other debug options)
    ```

3.  **Run Simulation:**
    ```bash
    # Example for ModelSim/QuestaSim:
    # vsim work.picoMIPS_tb -do "run -all; exit" # (batch mode)
    # # Or vsim work.picoMIPS_tb (GUI mode, then add waves and run manually)
    #
    # Example for Vivado XSim:
    # xsim picoMIPS_sim --gui # (GUI mode)
    # # Or xsim picoMIPS_sim --runall (batch mode)
    ```

4.  **Observe Results:**
    * Check the simulator console for output messages (e.g., register states or test results printed using `$display` in the testbench).
    * Use a waveform viewer (like GTKWave, or the built-in viewers in ModelSim/QuestaSim/Vivado) to observe signal changes and verify expected behavior.

***Please provide more detailed, specific instructions for your project and preferred simulator here.***

## Implemented Instruction Set

The `picoMIPS` processor currently supports the following MIPS instructions ([*Please accurately list all implemented instructions based on your design*]):

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
    * [*Other R-Type...*]
* **I-Type:**
    * `addiu`
    * `ori`
    * `lui`
    * `lw`
    * `sw`
    * `beq`
    * `bne`
    * [*Other I-Type...*]
* **J-Type:**
    * `j`
    * `jal`
    * [*Other J-Type...*]

## Future Work (Optional)

* [ ] Support for more MIPS instructions (e.g., multiplication, division).
* [ ] Implementation of a full interrupt and exception handling mechanism.
* [ ] Enhancing the design from single-cycle to multi-cycle or a simple pipeline for improved performance.
* [ ] Writing more comprehensive test cases to increase code coverage.
* [ ] Adding support for memory-mapped I/O.

## Author

* **YCL-Jeff** (Yu-Cheng, Lai)

## License

[*Please choose one option and delete the other. Update [Year] to the current year, e.g., 2025.*]

**Option 1: All Rights Reserved**

Copyright (c) [2025] YCL-Jeff. All Rights Reserved.

**Option 2: MIT License**
(If you choose this, also consider saving the license text below into a file named `LICENSE` or `LICENSE.md` in your repository's root directory.)
