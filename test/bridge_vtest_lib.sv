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

	// Each test overrides this to choose its stimulus
	virtual task run_seqs();
		seq2.start(env.ahb_mtop.ahb_magt[0].ahb_mseqr);
	endtask

	// After the last AHB transfer the bridge still needs a few clocks to finish on APB.
	// Wait until the scoreboard has matched everything and stayed idle for 20 clocks.
	task wait_for_bridge_idle();
		int unsigned idle_clocks = 0;
		int unsigned clocks = 0;
		while(idle_clocks < 20 && clocks < 2000) begin
			#10ns;
			clocks++;
			if(env.sco.ahb_fifo[0].used() == 0 && env.sco.apb_fifo[0].used() == 0 && !env.sco.waiting_for_apb)
				idle_clocks++;
			else
				idle_clocks = 0;
		end
		if(idle_clocks < 20)
			`uvm_error(get_type_name(),"TIMEOUT : bridge did not finish its APB transfers")
	endtask

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		run_seqs();
		wait_for_bridge_idle();
		phase.drop_objection(this);
	endtask
endclass

// Ten single transfers (Hburst = SINGLE), random read or write, random size and slave
class bridge_single_test extends bridge_base_test;
	`uvm_component_utils(bridge_single_test)

	function new(string name = "bridge_single_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	task run_seqs();
		repeat(10) begin
			seq1 = ahb_split_seqs::type_id::create("seq1");
			seq1.start(env.ahb_mtop.ahb_magt[0].ahb_mseqr);
		end
	endtask
endclass

// Incrementing bursts: defined length (INCR4/8/16) and undefined length (INCR)
class bridge_incr_test extends bridge_base_test;
	`uvm_component_utils(bridge_incr_test)

	function new(string name = "bridge_incr_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	task run_seqs();
		repeat(2) begin
			seq2 = ahb_dincr_seqs::type_id::create("seq2");
			seq2.start(env.ahb_mtop.ahb_magt[0].ahb_mseqr);
			seq3 = ahb_idincr_seqs::type_id::create("seq3");
			seq3.start(env.ahb_mtop.ahb_magt[0].ahb_mseqr);
		end
	endtask
endclass

// Wrapping bursts: WRAP4, WRAP8, WRAP16
class bridge_wrap_test extends bridge_base_test;
	`uvm_component_utils(bridge_wrap_test)

	function new(string name = "bridge_wrap_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	task run_seqs();
		repeat(3) begin
			seq4 = ahb_wrap_seqs::type_id::create("seq4");
			seq4.start(env.ahb_mtop.ahb_magt[0].ahb_mseqr);
		end
	endtask
endclass
