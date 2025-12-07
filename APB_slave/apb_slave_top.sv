class apb_slave_top extends uvm_env;
	`uvm_component_utils(apb_slave_top)
	apb_slave_agent apb_sagt[];
	bridge_env_config env_cfg;
		
	function new(string name = "apb_slave_top", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(bridge_env_config)::get(this,"","bridge_env_config",env_cfg))
			`uvm_fatal(get_type_name(),"config_db GET() method failed for env_cfg")
		super.build_phase(phase);
		apb_sagt= new[env_cfg.no_of_slaves];
		foreach(apb_sagt[i])
		begin
			apb_sagt[i] = apb_slave_agent::type_id::create($sformatf("apb_sagt[%0d]",i),this);
			uvm_config_db#(apb_slave_config)::set(this,$sformatf("apb_sagt[%0d]*",i),"apb_slave_config",env_cfg.apb_cfg[i]);
		end
	endfunction
endclass
