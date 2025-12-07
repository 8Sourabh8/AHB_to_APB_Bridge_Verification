class ahb_master_config extends uvm_object;
	`uvm_object_utils(ahb_master_config)

	uvm_active_passive_enum is_active;
	virtual bridge_if ahb_vif;

	function new(string name = "ahb_master_config");
		super.new(name);
	endfunction
endclass
