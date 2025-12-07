class apb_slave_monitor extends uvm_monitor;
	`uvm_component_utils(apb_slave_monitor)
	virtual bridge_if.SL_MON_MP vif;
	apb_slave_config apb_scfg;
	apb_sxtn tr;
	uvm_analysis_port #(apb_sxtn) apb2sco; 

	function new(string name = "apb_slave_monitor", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(apb_slave_config)::get(this,"","apb_slave_config",apb_scfg))
			`uvm_fatal(get_type_name(),"config_db GET() methid failed for apb_scfg")
		super.build_phase(phase);
		apb2sco = new("apb2sco",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		vif = apb_scfg.apb_vif;
	endfunction

	task collect_data();
		tr = apb_sxtn::type_id::create("tr");
		while(vif.sl_mon_cb.Pselx !== 1 && vif.sl_mon_cb.Pselx !== 2 && vif.sl_mon_cb.Pselx !== 4 && vif.sl_mon_cb.Pselx !== 8)
			@(vif.sl_mon_cb);
		while(vif.sl_mon_cb.Penable !== 1)
			@(vif.sl_mon_cb);
		tr.Pselx = vif.sl_mon_cb.Pselx;
		tr.Pwrite = vif.sl_mon_cb.Pwrite;
		tr.Penable = vif.sl_mon_cb.Penable;
		tr.Paddr = vif.sl_mon_cb.Paddr;
		if(vif.sl_mon_cb.Pwrite == 1)
			tr.Pwdata = vif.sl_mon_cb.Pwdata;
		else
			tr.Prdata = vif.sl_mon_cb.Prdata;
		//`uvm_info(get_type_name(),$sformatf(" APB Data Sampled : \n %0s",tr.sprint()),UVM_LOW)
		apb2sco.write(tr);
		@(vif.sl_mon_cb);
	endtask

	task run_phase(uvm_phase phase);
		forever begin
			collect_data();
		end
	endtask
endclass
