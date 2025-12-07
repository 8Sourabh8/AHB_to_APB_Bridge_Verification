module bridge_top;
	import uvm_pkg::*;
	import bridge_test_pkg::*;
	`include "uvm_macros.svh"

	bit clock;
	always #5 clock = ~clock;

	bridge_if ms_if(clock);
	bridge_if sl_if(clock);

	rtl_top DUT (clock,ms_if.Hresetn,ms_if.Htrans,ms_if.Hsize,ms_if.Hreadyin,ms_if.Hwdata,ms_if.Haddr,ms_if.Hwrite,sl_if.Prdata,ms_if.Hrdata,ms_if.Hresp,ms_if.Hreadyout,sl_if.Pselx,sl_if.Pwrite,sl_if.Penable,sl_if.Paddr,sl_if.Pwdata);
	
	initial begin
		uvm_config_db#(virtual bridge_if)::set(null,"*","master_if0",ms_if);
		uvm_config_db#(virtual bridge_if)::set(null,"*","slave_if0",sl_if);

		run_test();
	end

	initial begin
		`ifdef VCS
		$fsdbDumpvars(0, bridge_top);
        	`endif	
	end
endmodule
