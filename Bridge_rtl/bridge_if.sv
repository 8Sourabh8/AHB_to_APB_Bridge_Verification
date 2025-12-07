`include "definitions.v"

interface bridge_if (input bit clock);
        logic Hresetn;
        logic [1:0] Htrans;
	logic [2:0]Hsize; 
	logic Hreadyin;
	logic [`WIDTH-1:0]Hwdata; 
	logic [`WIDTH-1:0]Haddr;
	logic Hwrite;
        logic [`WIDTH-1:0]Prdata;
	logic [`WIDTH-1:0]Hrdata;
	logic [1:0]Hresp;
	logic Hreadyout;
	logic [`SLAVES-1:0]Pselx;
	logic Pwrite;
	logic Penable; 
	logic [`WIDTH-1:0]Paddr;
	logic [`WIDTH-1:0]Pwdata;
	
	parameter Tsetup_AHB_drv = 1;
	parameter Tsetup_APB_drv = 0;
	parameter Tsetup_mon = 1;
	parameter Thold = 1;
	
	clocking ms_drv_cb @(posedge clock);
		default input #(Tsetup_AHB_drv) output #(Thold);
		output Hresetn, Htrans, Hsize, Hreadyin, Hwdata, Haddr, Hwrite;
		input Hreadyout;
	endclocking
	
	clocking ms_mon_cb @(posedge clock);
		default input #(Tsetup_mon) output #(Thold);
		input Hresetn, Htrans, Hsize, Hreadyin, Hwdata, Haddr, Hwrite;
		input Hreadyout, Hrdata, Hresp;
	endclocking
	
	clocking sl_drv_cb @(posedge clock);
		default input #(Tsetup_APB_drv) output #0;
		output Prdata;
		input Pselx, Pwrite, Penable, Paddr;
	endclocking
	
	clocking sl_mon_cb @(posedge clock);
		default input #(Tsetup_mon) output #(Thold);
		input Pwdata, Prdata;
		input Pselx, Pwrite, Penable, Paddr;
	endclocking	

	modport MS_DRV_MP (clocking ms_drv_cb);
	modport MS_MON_MP (clocking ms_mon_cb);
	modport SL_DRV_MP (clocking sl_drv_cb);
	modport SL_MON_MP (clocking sl_mon_cb);
endinterface
