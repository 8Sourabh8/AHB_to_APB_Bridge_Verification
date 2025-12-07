class ahb_master_driver extends uvm_driver#(ahb_mxtn);
	`uvm_component_utils(ahb_master_driver)
	virtual bridge_if.MS_DRV_MP vif;
	ahb_master_config ahb_mcfg;

	function new(string name = "ahb_master_driver", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(ahb_master_config)::get(this,"","ahb_master_config",ahb_mcfg))
			`uvm_fatal(get_type_name(),"config_db GET() methid failed for ahb_mcfg")
		super.build_phase(phase);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		vif = ahb_mcfg.ahb_vif;
	endfunction

	task reset_dut();
		@(vif.ms_drv_cb);
		vif.ms_drv_cb.Hresetn <= 1'b0;
		@(vif.ms_drv_cb);
		vif.ms_drv_cb.Hresetn <= 1'b1;
	endtask

	task drive_dut(ahb_mxtn tr);
		`uvm_info(get_type_name(),$sformatf(" AHB SEQ received \n %0s",tr.sprint()),UVM_LOW)
		vif.ms_drv_cb.Hreadyin <= 1'b1;
		vif.ms_drv_cb.Htrans <= tr.Htrans;
		vif.ms_drv_cb.Hsize <= tr.Hsize;
		vif.ms_drv_cb.Hwrite <= tr.Hwrite;
		vif.ms_drv_cb.Haddr	<= tr.Haddr;
		//`uvm_info(get_type_name(),"CONTROL SIGNALS DRIVEN",UVM_LOW)
		@(vif.ms_drv_cb);
		if(tr.Htrans == 2'b11 | tr.Htrans == 2'b10)
		begin
		while(vif.ms_drv_cb.Hreadyout !== 1'b1)
			@(vif.ms_drv_cb);
		end
		vif.ms_drv_cb.Hwdata <= tr.Hwdata;
		//`uvm_info(get_type_name(),$sformatf("DATA SIGNALS DRIVEN : %8h",tr.Hwdata),UVM_LOW)
		vif.ms_drv_cb.Hreadyin <= 1'b0;
	endtask

	task run_phase(uvm_phase phase);
		reset_dut();
		forever begin
			seq_item_port.get_next_item(req);
			drive_dut(req);
			seq_item_port.item_done();
		end
	endtask
endclass
