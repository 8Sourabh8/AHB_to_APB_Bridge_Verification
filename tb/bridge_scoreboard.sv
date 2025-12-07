class bridge_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(bridge_scoreboard)
	uvm_tlm_analysis_fifo #(ahb_mxtn) ahb_fifo[];
	uvm_tlm_analysis_fifo #(apb_sxtn) apb_fifo[];
	bridge_env_config env_cfg;
	ahb_mxtn ahb_tr;
	apb_sxtn apb_tr;
	
	function new(string name = "bridge_scoreboard", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(bridge_env_config)::get(this,"","bridge_env_config",env_cfg))
			`uvm_fatal(get_type_name(),"config_db GET() method failed for env_cfg")
		ahb_fifo = new[env_cfg.no_of_masters];
		apb_fifo = new[env_cfg.no_of_slaves];
		foreach(ahb_fifo[i])
			ahb_fifo[i] = new($sformatf("ahb_fifo[%0d]",i),this);
		foreach(apb_fifo[i])
			apb_fifo[i] = new($sformatf("apb_fifo[%0d]",i),this);
	endfunction

	task run_phase(uvm_phase phase);
		forever begin
			fork
				begin
					ahb_fifo[0].get(ahb_tr);
				end
				begin
					apb_fifo[0].get(apb_tr);
				end
			join
			`uvm_info(get_type_name(),$sformatf("AHB packet received \n %0s",ahb_tr.sprint()),UVM_LOW)
			`uvm_info(get_type_name(),$sformatf("APB packet received \n %0s",apb_tr.sprint()),UVM_LOW)
		end
	endtask
endclass
