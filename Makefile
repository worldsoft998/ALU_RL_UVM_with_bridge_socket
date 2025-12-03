# Makefile for running Xcelium simulation with/without RL, and for training RL agents.
# Usage:
#   make sim          # run baseline UVM sim (no RL)
#   make sim RL=1     # run sim in RL-enabled mode (starts cocotb bridge server)
#   make train        # run RL training (requires gymnasium + stable-baselines3)
#   make zip          # create zip of repo (already provided)
# Note: This Makefile contains placeholders. Edit paths for your Xcelium installation.

SIM = xrun
TOP = tb_top
SRC = $(wildcard rtl/*.sv) $(wildcard uvm/*.sv)
COCOTB = cocotb
PYTHON = python3

.PHONY: sim train zip

sim:
	@echo "Starting baseline UVM + Xcelium simulation (no RL)"
	# Example xrun invocation (customize for your environment)
	$(SIM) -sv -top $(TOP) -f filelist.f +UVM_NO_RUN_TEST=0

sim-rl:
	@echo "Starting Xcelium simulation with RL bridge enabled (BSHL) -- placeholder"
	@echo "Start cocotb bridge server separately: $(PYTHON) -m python_rl.bridge_server --port 7777"
	$(SIM) -sv -top $(TOP) -f filelist.f +UVM_RUN_RL=1

train:
	@echo "Starting RL training (ensure virtualenv with gymnasium and stable-baselines3 installed)"
	$(PYTHON) python_rl/agents/train.py

zip:
	@echo "Repo located at: ALU_RL_UVM_Repo (already zipped in deliverable)"
