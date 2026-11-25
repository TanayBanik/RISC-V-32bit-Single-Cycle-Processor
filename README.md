# 32-Bit RISC-V (RV32I) Pipelined Processor

Synthesizable 32-bit RISC-V (`RV32I`) processor implemented in **SystemVerilog**, featuring a 5-stage pipelined microarchitecture (`IF`, `ID`, `EX`, `MEM`, `WB`), full control/branch handling, self-checking simulation testbenches, and Xilinx Vivado FPGA synthesis and static timing analysis.

---

## Microarchitecture Overview

The processor follows a modular 5-stage RISC-V pipeline separated by inter-stage pipeline registers (`ID/EX`, `EX/MEM`, `MEM/WB`):

1. **Instruction Fetch (`IF`):** 32-bit Program Counter (`pc`), sequential `pc + 4` adder (`pc_next`), instruction memory interface, and branch/jump target selection.
2. **Instruction Decode (`ID`):** Instruction field extraction (`rs1`, `rs2`, `rd`), 32×32-bit dual-read/single-write Register File, sign-extended Immediate Generator, and Main Control Unit decoding `reg_write`, `mem_read`, `mem_write`, `mem_to_reg`, `alu_src`, `alu_control[2:0]`, `branch`, `bne`, `jal`, `jalr`, `lui`, and `auipc`.
3. **Execute (`EX`):** 32-bit ALU (`alu_input_a`, `alu_input_b`, `alu_result`, `zero_flag`), branch condition evaluator (`branch_taken_ex`), and dedicated target address calculators for conditional branches (`branch_target_normal`), `JAL` (`jal_target`), and `JALR` (`jalr_target`).
4. **Memory Access (`MEM`):** Data memory (`dmem`) load/store interface controlled by `ex_mem_mem_read` and `ex_mem_mem_write`.
5. **Write-Back (`WB`):** Result multiplexer selecting between ALU/jump results (`mem_wb_alu_result`) and loaded memory data (`mem_wb_memory_data`) to update register `mem_wb_rd`.

---

## Repository Structure

```text
RISC-V-32bit-Single-Cycle-Processor/
├── rtl/            # Synthesizable SystemVerilog RTL modules (datapath, ALU, control, pipeline registers)
├── tb/             # Self-checking SystemVerilog simulation testbench (tb_riscv_pipeline)
├── scripts/        # Vivado Tcl project recreation script
├── docs/           # Simulation waveforms and timing/utilization reports
└── README.md       # Project documentation
