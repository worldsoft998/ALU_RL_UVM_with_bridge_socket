`include "uvm_macros.svh"
import seq_pkg::*;
class alu_env extends uvm_env;
  `uvm_component_utils(alu_env)
  alu_driver driver;
  alu_monitor monitor;
  alu_scoreboard scoreboard;
  bshl_bridge_agent bridge;
  virtual alu_if.TB vif_h;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver = alu_driver::type_id::create("driver", this);
    monitor = alu_monitor::type_id::create("monitor", this);
    scoreboard = alu_scoreboard::type_id::create("scoreboard", this);
    bridge = bshl_bridge_agent::type_id::create("bridge", this);
    // set virtual interface for components (we expect testbench_top to set the virtual interface via config_db)
    if (!uvm_config_db#(virtual alu_if.TB)::get(this, "","vif", vif_h)) begin
      `uvm_info("ENV", "Virtual interface 'vif' not set in config_db. Ensure tb_top sets it.", UVM_LOW)
    end else begin
      driver.vif = vif_h;
      monitor.vif = vif_h;
      bridge.vif = vif_h;
    end
  endfunction
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    monitor.item_port.connect(scoreboard.analysis_if);
  endfunction
endclass
