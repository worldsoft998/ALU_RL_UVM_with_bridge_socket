`include "uvm_macros.svh"
import seq_pkg::*;
class alu_scoreboard extends uvm_component;
  `uvm_component_utils(alu_scoreboard)
  uvm_analysis_imp #(alu_seq_item, alu_scoreboard) analysis_if;
  function new(string name, uvm_component parent);
    super.new(name, parent);
    analysis_if = new("analysis_if", this);
  endfunction
  function void write(alu_seq_item t);
    // Reference model
    logic [7:0] ref;
    case (t.op)
      3'b000: ref = t.a + t.b;
      3'b001: ref = t.a - t.b;
      3'b010: ref = t.a & t.b;
      3'b011: ref = t.a | t.b;
      3'b100: ref = t.a ^ t.b;
      3'b101: ref = (t.a < t.b) ? 8'd1 : 8'd0;
      3'b110: ref = t.a << 1;
      3'b111: ref = t.a >> 1;
      default: ref = 8'h00;
    endcase
    // Compare - in real TB we'd compare to DUT result captured by monitor; simplified here.
    `uvm_info("SCORE", $sformatf("Scoreboard sample: a=%0d b=%0d op=%0d ref=%0d", t.a, t.b, t.op, ref), UVM_LOW)
  endfunction
endclass
