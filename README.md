# ALU 8-bit UVM Testbench with Python RL (Gymnasium + stable-baselines3) integration

This repository provides:

- An 8-bit ALU SystemVerilog RTL (`rtl/alu.sv`).
- A fully-structured UVM SystemVerilog testbench skeleton (UVM 1.1 compatible) under `uvm/`.
- cocotb-BSHL bridge stubs and a cocotb test that demonstrates two-way messaging with UVM via the bridge under `cocotb/`.
- A custom OpenAI Gymnasium environment for the ALU and example RL training scripts using `stable-baselines3` under `python_rl/`.
- A `Makefile` tailored for Cadence Xcelium + cocotb integration and options to enable/disable AI-based sampling.
- Docs and diagrams describing architecture, message protocols, and recommended workflows.

**Important:** This repo is a starting point and was generated programmatically. It aims to minimize changes to the original UVM testbench structure (if any) while providing an extensible RL interface.

See `docs/` for architecture diagrams and `Makefile` for simulation / training targets.


## Updates: UVM-side bridge & cocotb BSHL implementation

- Added `uvm/bridge_agent.sv`: a file-based mailbox bridge agent that watches `bshl_mailbox/in` for APPLY files and writes ACK/RESULT files into `bshl_mailbox/out`.
- Updated `cocotb/tests/test_alu_bshl.py`: implements a socket server (port 7777) that receives RL JSON messages, writes APPLY files, waits for ACK/RESULT files from UVM bridge and forwards responses back to the RL client.

Note: This implementation uses the filesystem as an intermediary for portability and to avoid DPI-C. It is a practical, simulator-portable bridge suitable for prototyping. For production, replace the file mailbox with an IPC mechanism (Unix domain sockets, named pipes) or native cocotb-BSHL if available.
