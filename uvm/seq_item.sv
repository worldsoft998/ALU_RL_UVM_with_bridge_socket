`ifndef SEQ_ITEM_SV
`define SEQ_ITEM_SV
`include "uvm_macros.svh"
package seq_pkg;
  import uvm_pkg::*;
  class alu_seq_item extends uvm_sequence_item;
    rand bit [7:0] a;
    rand bit [7:0] b;
    rand bit [2:0] op;
    `uvm_object_utils(alu_seq_item)
    function new(string name = "alu_seq_item");
      super.new(name);
    endfunction
    function string convert2string();
      return $sformatf("a=%0d b=%0d op=%0d", a,b,op);
    endfunction
  endclass
endpackage
`endif
