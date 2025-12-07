class ahb_master_monitor extends uvm_monitor;
	`uvm_component_utils(ahb_master_monitor)
	virtual bridge_if.MS_MON_MP vif;
	ahb_master_config ahb_mcfg;
	ahb_mxtn tr;
	uvm_analysis_port #(ahb_mxtn) ahb2sco; 

	function new(string name = "ahb_master_monitor", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(ahb_master_config)::get(this,"","ahb_master_config",ahb_mcfg))
			`uvm_fatal(get_type_name(),"config_db GET() methid failed for ahb_mcfg")
		super.build_phase(phase);
		ahb2sco = new("ahb2sco",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		vif = ahb_mcfg.ahb_vif;
	endfunction

	function void trans_type(ref ahb_mxtn tr);
		case(tr.Htrans)
			2'b00 : tr.transfer_type = "IDLE";
			2'b01 : tr.transfer_type = "BUSY";
			2'b10 : tr.transfer_type = "NSEQ";
			2'b11 : tr.transfer_type = "SEQ";
		endcase	
	endfunction


	task collect_data();
		tr = ahb_mxtn::type_id::create("tr");
		while(vif.ms_mon_cb.Hreadyin !== 1)
			@(vif.ms_mon_cb);
		while(vif.ms_mon_cb.Htrans !== 2'b10 && vif.ms_mon_cb.Htrans !== 2'b11)
			@(vif.ms_mon_cb);
		//while(vif.ms_mon_cb.Hreadyout !== 1)
		//	@(vif.ms_mon_cb);
		tr.Hresetn = vif.ms_mon_cb.Hresetn;
		tr.Htrans = vif.ms_mon_cb.Htrans;
		tr.Hsize = vif.ms_mon_cb.Hsize;
		tr.Hreadyin = vif.ms_mon_cb.Hreadyin;
		tr.Hwrite = vif.ms_mon_cb.Hwrite;
		tr.Hreadyout = vif.ms_mon_cb.Hreadyout;
		tr.Haddr = vif.ms_mon_cb.Haddr;
		tr.Hresp = vif.ms_mon_cb.Hresp;
		trans_type(tr);

		@(vif.ms_mon_cb);
		//while(vif.ms_mon_cb.Htrans !== 2'b10 && vif.ms_mon_cb.Htrans !== 2'b11)
		//	@(vif.ms_mon_cb);
		/*if(vif.ms_mon_cb.Htrans == 2'b11 | vif.ms_mon_cb.Htrans == 2'b10)
			while(vif.ms_mon_cb.Hreadyout !== 1)
				@(vif.ms_mon_cb);*/
		if(tr.Hwrite == 1'b1)
		begin
			if(vif.ms_mon_cb.Htrans == 2'b11 | vif.ms_mon_cb.Htrans == 2'b10)
				while(vif.ms_mon_cb.Hreadyout !== 1)
					@(vif.ms_mon_cb);
						tr.Hwdata = vif.ms_mon_cb.Hwdata;
		end
		else 
			while(vif.ms_mon_cb.Hreadyout !== 1)
					@(vif.ms_mon_cb);
						tr.Hrdata = vif.ms_mon_cb.Hrdata;
		//`uvm_info(get_type_name(),$sformatf(" AHB Data Sampled : \n %0s",tr.sprint()),UVM_LOW)
		ahb2sco.write(tr);
				
	endtask

	task run_phase(uvm_phase phase);
		forever begin
			collect_data();
		end
	endtask
endclass
