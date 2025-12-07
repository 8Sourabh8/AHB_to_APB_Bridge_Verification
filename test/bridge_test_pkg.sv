package bridge_test_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	`include "definitions.v"

	`include "ahb_master_config.sv"
	`include "apb_slave_config.sv"
	`include "bridge_env_config.sv"

	`include "ahb_mxtn.sv"
	`include "apb_sxtn.sv"

	`include "ahb_master_seqs.sv"
	`include "ahb_master_driver.sv"
	`include "ahb_master_monitor.sv"
	`include "ahb_master_sequencer.sv"
	`include "ahb_master_agent.sv"
	`include "ahb_master_top.sv"

	`include "apb_slave_driver.sv"
	`include "apb_slave_monitor.sv"
	`include "apb_slave_sequencer.sv"
	`include "apb_slave_agent.sv"
	`include "apb_slave_top.sv"

	`include "bridge_scoreboard.sv"	
	`include "bridge_virtual_sequencer.sv"
	`include "bridge_env.sv"

	`include "bridge_vtest_lib.sv"
endpackage
