class ahb_master_agent extends uvm_agent;
	`uvm_component_utils(ahb_master_agent)
	ahb_master_driver ahb_mdrv;
	ahb_master_monitor ahb_mmon;
	ahb_master_sequencer ahb_mseqr;
	ahb_master_config ahb_mcfg;	
	
	function new(string name = "ahb_master_agent", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(ahb_master_config)::get(this,"","ahb_master_config",ahb_mcfg))
			`uvm_fatal(get_type_name(),"config_db GET() method failed for ahb_mcfg")
		super.build_phase(phase);
		ahb_mmon = ahb_master_monitor::type_id::create("ahb_mmon",this);
		if(ahb_mcfg.is_active == UVM_ACTIVE)
		begin
			ahb_mdrv = ahb_master_driver::type_id::create("ahb_mdrv",this);
			ahb_mseqr = ahb_master_sequencer::type_id::create("ahb_mseqr",this);
		end
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		ahb_mdrv.seq_item_port.connect(ahb_mseqr.seq_item_export);
	endfunction
endclass
