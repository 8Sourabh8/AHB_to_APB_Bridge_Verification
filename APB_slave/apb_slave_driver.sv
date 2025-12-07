class apb_slave_driver extends uvm_driver#(apb_sxtn);
	`uvm_component_utils(apb_slave_driver)
	virtual bridge_if.SL_DRV_MP vif;
	apb_slave_config apb_scfg;
	
	function new(string name = "apb_slave_driver", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(apb_slave_config)::get(this,"","apb_slave_config",apb_scfg))
			`uvm_fatal(get_type_name(),"config_db GET() methid failed for apb_scfg")
		super.build_phase(phase);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		vif = apb_scfg.apb_vif;
	endfunction

	task drive_dut();
		while(vif.sl_drv_cb.Pselx !== 1 && vif.sl_drv_cb.Pselx !== 2 && vif.sl_drv_cb.Pselx !== 4 && vif.sl_drv_cb.Pselx !== 8)
			@(vif.sl_drv_cb);
		while(vif.sl_drv_cb.Penable !== 1)
			@(vif.sl_drv_cb);
		if(vif.sl_drv_cb.Pwrite == 0)
			vif.sl_drv_cb.Prdata <= $urandom();
		else 
			vif.sl_drv_cb.Prdata <= 0;
			@(vif.sl_drv_cb);
	endtask
	
	task run_phase(uvm_phase phase);
		forever begin
			drive_dut();
		end
	endtask
endclass
