`include "uvm_macros.svh"
import seq_pkg::*;
class alu_sequence extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_sequence)
  function new(string name="alu_sequence");
    super.new(name);
  endfunction
  task body();
    alu_seq_item req;
    repeat (100) begin
      req = alu_seq_item::type_id::create("req");
      assert(req.randomize());
      start_item(req);
      finish_item(req);
    end
  endtask
endclass
