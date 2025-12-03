# Comparison methodology: RL vs Baseline (no-AI)





**To compare verification with and without RL:**



1. Baseline: Use UVM sequences with random stimulus (e.g., alu\_sequence) and measure:

   * Time to achieve a given functional coverage milestone (e.g., cover all ops, exercise edge cases).
   * Number of transactions applied.
   * Coverage progression vs time.



2. RL-enabled:

   * Train an RL policy using the ALUEnv where reward is aligned to improving coverage and minimizing latency.
   * During evaluation, use the trained policy to drive stimuli and measure same metrics as baseline.



Suggested metrics:



* Coverage closure time (seconds or simulation cycles).
* Unique cross-product coverage points covered.
* Average latency per applied transaction.
* Simulation cycles to reach target coverage.



Note: For small DUT like 8-bit ALU, RL gains may be modest, but this repo demonstrates the full end-to-end integration approach and is designed to scale to larger DUTs.

