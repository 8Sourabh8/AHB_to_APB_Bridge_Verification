class bridge_env extends uvm_env;
	`uvm_component_utils(bridge_env)
	ahb_master_top ahb_mtop;
	apb_slave_top apb_stop;
	bridge_scoreboard sco;
	bridge_virtual_sequencer vseqr;
	bridge_env_config env_cfg;

	function new(string name = "bridge_env", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(bridge_env_config)::get(this,"","bridge_env_config",env_cfg))
			`uvm_fatal(get_type_name(),"config_db GET() method failed for env_cfg")
		super.build_phase(phase);
		ahb_mtop = ahb_master_top::type_id::create("ahb_mtop",this);
		apb_stop = apb_slave_top::type_id::create("apb_stop",this);
		if(env_cfg.has_scoreboard)
			sco = bridge_scoreboard::type_id::create("sco",this);
		if(env_cfg.has_virtual_sequencer)
			vseqr = bridge_virtual_sequencer::type_id::create("vseqr",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		foreach(ahb_mtop.ahb_magt[i])
			ahb_mtop.ahb_magt[i].ahb_mmon.ahb2sco.connect(sco.ahb_fifo[i].analysis_export);
		foreach(apb_stop.apb_sagt[i])
			apb_stop.apb_sagt[i].apb_smon.apb2sco.connect(sco.apb_fifo[i].analysis_export);
	endfunction
endclass
