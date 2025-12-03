`include "uvm_macros.svh"
import seq_pkg::*;
class alu_driver extends uvm_driver #(alu_seq_item);
  `uvm_component_utils(alu_driver)
  virtual alu_if.TB vif;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    alu_seq_item req;
    forever begin
      seq_item_port.get_next_item(req);
      // Drive DUT signals
      @(posedge vif.clk);
      vif.a <= req.a;
      vif.b <= req.b;
      vif.op <= req.op;
      @(posedge vif.clk);
      // handshake finish
      seq_item_port.item_done();
    end
  endtask
endclass
