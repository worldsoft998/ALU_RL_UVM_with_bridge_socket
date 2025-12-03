`timescale 1ns/1ps
module tb_top;
  import alu_uvm_pkg::*;
  bit clk;
  alu_if if0(.clk(clk));
  // DUT
  alu8 dut (
    .a(if0.a),
    .b(if0.b),
    .op(if0.op),
    .result(if0.result),
    .carry(if0.carry),
    .zero(if0.zero)
  );
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  // Create mailbox directories before run_test (best-effort via system calls)
  initial begin
    $system("mkdir -p bshl_mailbox/in bshl_mailbox/out");
  end
  initial begin
    // Set virtual interface into config DB
    uvm_config_db#(virtual alu_if.TB)::set(0, "", "vif", if0);
    run_test("alu_test");
  end
endmodule
