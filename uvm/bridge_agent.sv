`include "uvm_macros.svh"
import seq_pkg::*;
class bshl_bridge_agent extends uvm_component;
  `uvm_component_utils(bshl_bridge_agent)
  virtual alu_if.TB vif;
  string in_dir;
  string out_dir;
  function new(string name, uvm_component parent);
    super.new(name, parent);
    in_dir = {"bshl_mailbox/in"};
    out_dir = {"bshl_mailbox/out"};
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    // Ensure mailbox dirs exist (simulator working directory)
    // In SV we cannot reliably create directories portably, assume test script created them.
    while (!uvm_top.get_full_name()) begin
      // wait for simulation to settle
      #1ns;
    end
    forever begin
      // poll for apply files in in_dir
      string cmd;
      string filename;
      integer fh;
      // Using simulator system task to read directory listing would be simulator-specific.
      // Instead we attempt to open files with predictable names apply_*.txt (simple incremental scanning)
      // We'll scan indices 0..999 for files
      int i;
      for (i=0; i<1000; i++) begin
        filename = {in_dir, "/apply_", $sformatf("%0d", i), ".txt"};
        fh = $fopen(filename, "r");
        if (fh != 0) begin
          string line;
          string req_id_s;
          int a_int, b_int, op_int;
          void'($fgets(line, fh));
          // line expected: req_id a b op (space-separated)
          int num = $sscanf(line, "%s %d %d %d", req_id_s, a_int, b_int, op_int);
          $fclose(fh);
          // drive DUT via virtual interface (synchronous)
          uvm_info("BSHL", $sformatf("Bridge got APPLY: %s a=%0d b=%0d op=%0d", req_id_s, a_int, b_int, op_int), UVM_MEDIUM);
          // Apply transaction
          @(posedge vif.clk);
          vif.a <= a_int;
          vif.b <= b_int;
          vif.op <= op_int;
          @(posedge vif.clk);
          // Send ACK file
          string ackfile = {out_dir, "/ack_", req_id_s, ".txt"};
          integer ackfh = $fopen(ackfile, "w");
          if (ackfh) begin
            $fwrite(ackfh, "accepted\n");
            $fclose(ackfh);
          end
          // Wait one clock then sample result and write result file
          @(posedge vif.clk);
          int result_int = vif.result;
          int carry_int = vif.carry;
          int zero_int  = vif.zero;
          string resfile = {out_dir, "/result_", req_id_s, ".txt"};
          integer resfh = $fopen(resfile, "w");
          if (resfh) begin
            $fwrite(resfh, "%0d %0d %0d %0d\n", result_int, carry_int, zero_int, 10); // latency placeholder
            $fclose(resfh);
          end
          // remove the apply file to indicate processed (best-effort; file deletion may be simulator/OS-specific)
          // Use system call rm (may not work on all simulators/environments)
          string rmcmd = {"rm -f ", filename};
          $system(rmcmd);
        end // fh
      end // for i
      // small delay
      #100ns;
    end // forever
    phase.drop_objection(this);
  endtask
endclass
