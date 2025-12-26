# Mini-TPU — A Custom RISC-V Systolic-Array Accelerator

 Mini-TPU is a compact accelerator: a synthesizable Verilog 4×4 systolic array (TPU-style) + host Python data prep, verified with Icarus Verilog and GTKWave.


## Project overview
Mini-TPU demonstrates domain-specific hardware by offloading matrix multiplication to a small systolic array (4×4). The project contains:
- a synthesizable Processing Element (PE) in Verilog that performs MAC and forwards data (West→East, North→South),
- a 4×4 systolic array with skewed dataflow,
- host Python data generator that creates a memory image (`memory_init.hex`) for `$readmemh`,
- testbenches and VCD waveforms for verification.

Designed and implemented Mini-TPU — a Verilog 4×4 systolic array accelerator for matrix multiplication with HW–SW co-design (Python data prep), verified using Icarus Verilog & GTKWave.*

This shows RTL design, dataflow, HW/SW interfacing, verification, and real toolchain experience — all strong for ECE/ASIC/FPGA roles.

Features
- Weight-stationary PE with register pipeline, multiply and accumulate (MAC).
- Forwarding ports a_out (east) and b_out (south) for systolic flow.
- 4×4 systolic array with input skewing so matrix multiply streams in.
- Host Python script `data_prep.py` → produces `memory_init.hex` for SRAM init.
- Testbenches (`tb/`) for PE and full array; waveform outputs (`*.vcd`) for visualization.
- Clear project structure ready for incremental expansion (memory, control FSM, top integration).

Architecture (high level)
