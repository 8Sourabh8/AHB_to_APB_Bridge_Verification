class bridge_base_test extends uvm_test;
	`uvm_component_utils(bridge_base_test)
	int no_of_masters = 1;
	int no_of_slaves = 1;
	bit has_virtual_sequencer = 1;
	bit has_scoreboard = 1;
	ahb_master_config ahb_cfg[];
	apb_slave_config apb_cfg[];
	bridge_env_config env_cfg;
	bridge_env env;
	ahb_split_seqs seq1; // split transfer seq
	ahb_dincr_seqs seq2; // Definite length incr burst
	ahb_idincr_seqs seq3; // Indefinite length incr burst
	ahb_wrap_seqs seq4;

	function new(string name = "bridge_base_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		env_cfg = bridge_env_config::type_id::create("env_cfg");
		env_cfg.ahb_cfg = new[no_of_masters];
		ahb_cfg = new[no_of_masters];
		foreach(ahb_cfg[i])
		begin
			ahb_cfg[i] = ahb_master_config::type_id::create($sformatf("ahb_cfg[%0d]",i));
			if(!uvm_config_db#(virtual bridge_if)::get(this,"",$sformatf("master_if%0d",i),ahb_cfg[i].ahb_vif))
				`uvm_fatal(get_type_name,"config_db GET() method failed for ahb_if")
			ahb_cfg[i].is_active = UVM_ACTIVE;
			env_cfg.ahb_cfg[i] = ahb_cfg[i];
		end
		env_cfg.apb_cfg = new[no_of_slaves];
		apb_cfg = new[no_of_slaves];
		foreach(apb_cfg[i])
		begin
			apb_cfg[i] = apb_slave_config::type_id::create($sformatf("apb_cfg[%0d]",i));
			if(!uvm_config_db#(virtual bridge_if)::get(this,"",$sformatf("slave_if%0d",i),apb_cfg[i].apb_vif))
				`uvm_fatal(get_type_name,"config_db GET() method failed for apb_if")
			apb_cfg[i].is_active = UVM_ACTIVE;
			env_cfg.apb_cfg[i] = apb_cfg[i];
		end
		env_cfg.no_of_masters = no_of_masters;
		env_cfg.no_of_slaves = no_of_slaves;
		env_cfg.has_virtual_sequencer = has_virtual_sequencer;
		env_cfg.has_scoreboard = has_scoreboard;
		uvm_config_db#(bridge_env_config)::set(this,"*","bridge_env_config",env_cfg);

		super.build_phase(phase);
		env = bridge_env::type_id::create("env",this);
		seq1 = ahb_split_seqs::type_id::create("seq1");
		seq2 = ahb_dincr_seqs::type_id::create("seq2");
		seq3 = ahb_idincr_seqs::type_id::create("seq3");
		seq4 = ahb_wrap_seqs::type_id::create("req");
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction

	function void start_of_simulation_phase(uvm_phase phase);
		super.start_of_simulation_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		repeat(1)
			seq2.start(env.ahb_mtop.ahb_magt[0].ahb_mseqr);
		#50;
		phase.drop_objection(this);
	endtask
endclass
