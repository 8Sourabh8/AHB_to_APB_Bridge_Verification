class apb_slave_config extends uvm_object;
	`uvm_object_utils(apb_slave_config)

	uvm_active_passive_enum is_active;
	virtual bridge_if apb_vif;

	function new(string name = "apb_slave_config");
		super.new(name);
	endfunction
endclass 
