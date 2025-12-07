class apb_slave_agent extends uvm_agent;
	`uvm_component_utils(apb_slave_agent)
	apb_slave_driver apb_sdrv;
	apb_slave_monitor apb_smon;
	apb_slave_sequencer apb_sseqr;
	apb_slave_config apb_scfg;

	function new(string name = "apb_slave_agent", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(apb_slave_config)::get(this,"","apb_slave_config",apb_scfg))
			`uvm_fatal(get_type_name(),"config_db GET() method failed for apb_scfg")
		super.build_phase(phase);
		apb_smon = apb_slave_monitor::type_id::create("apb_smon",this);
		if(apb_scfg.is_active == UVM_ACTIVE)
		begin
			apb_sdrv = apb_slave_driver::type_id::create("apb_sdrv",this);
			apb_sseqr = apb_slave_sequencer::type_id::create("apb_sseqr",this);
		end
	endfunction
endclass
