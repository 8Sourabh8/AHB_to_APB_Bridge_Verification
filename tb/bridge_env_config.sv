class bridge_env_config extends uvm_object;
	`uvm_object_utils(bridge_env_config)
	int no_of_masters;
	int no_of_slaves;
	bit has_virtual_sequencer;
	bit has_scoreboard;
	ahb_master_config ahb_cfg[];
	apb_slave_config apb_cfg[];

	function new(string name = "bridge_env_config");
		super.new(name);
	endfunction
endclass
