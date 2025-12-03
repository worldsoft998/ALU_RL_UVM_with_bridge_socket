`include "uvm_macros.svh"
import seq_pkg::*;
class alu_test extends uvm_test;
  `uvm_component_utils(alu_test)
  alu_env env;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = alu_env::type_id::create("env", this);
  endfunction
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    alu_sequence seq = alu_sequence::type_id::create("seq");
    seq.start(env.driver);
    #1000ns;
    phase.drop_objection(this);
  endtask
endclass
