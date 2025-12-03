package alu_uvm_pkg;
  import uvm_pkg::*;
  // Minimal types
  typedef struct packed {
    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op;
  } alu_item_t;
endpackage : alu_uvm_pkg
