# Architecture





This project connects a Python RL agent (trainer \& policy) to a SystemVerilog UVM testbench via the cocotb-BSHL bridge.





Components:



* UVM testbench: drives DUT and provides a "bridge agent" that can accept incoming APPLY commands and emit RESULT messages.
* cocotb-side BSHL: when enabled, cocotb attaches to the DUT and acts as a lightweight bridge process that speaks JSON messages to Python RL agents.
* RL Trainer: Uses Gymnasium environment (ALUEnv) which communicates over sockets to simulator bridge. Policy is trained in Python (stable-baselines3).





Parallelization:





* Use multiple simulator workers (each on its own port) and a central policy server to distribute sampling and accelerate training.
