class ahb_master_top extends uvm_env;
	`uvm_component_utils(ahb_master_top)
	ahb_master_agent ahb_magt[];
	bridge_env_config env_cfg;

	function new(string name = "ahb_master_top", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(bridge_env_config)::get(this,"","bridge_env_config",env_cfg))
			`uvm_fatal(get_type_name(),"config_db GET() method failed for env_cfg")
		super.build_phase(phase);
		ahb_magt = new[env_cfg.no_of_masters];
		foreach(ahb_magt[i])
		begin
			ahb_magt[i] = ahb_master_agent::type_id::create($sformatf("ahb_magt[%0d]",i),this);
			uvm_config_db#(ahb_master_config)::set(this,$sformatf("ahb_magt[%0d]*",i),"ahb_master_config",env_cfg.ahb_cfg[i]);
		end
	endfunction
endclass
