`include "uvm_macros.svh"
import seq_pkg::*;
class alu_monitor extends uvm_monitor;
  `uvm_component_utils(alu_monitor)
  virtual alu_if.TB vif;
  uvm_analysis_port #(alu_seq_item) item_port;
  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_port = new("item_port", this);
  endfunction
  task run_phase(uvm_phase phase);
    alu_seq_item item;
    forever begin
      @(posedge vif.clk);
      // sample result
      item = alu_seq_item::type_id::create("mon_item");
      item.a = vif.a;
      item.b = vif.b;
      item.op = vif.op;
      item_port.write(item);
    end
  endtask
endclass
