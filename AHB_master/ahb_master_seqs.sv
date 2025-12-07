class ahb_base_seqs extends uvm_sequence#(ahb_mxtn);
	`uvm_object_utils(ahb_base_seqs)

	function new(string name = "ahb_master_seqs");
		super.new(name);
	endfunction

	function void trans_type(ref ahb_mxtn tr);
		case(tr.Htrans)
			2'b00 : tr.transfer_type = "IDLE";
			2'b01 : tr.transfer_type = "BUSY";
			2'b10 : tr.transfer_type = "NSEQ";
			2'b11 : tr.transfer_type = "SEQ";
		endcase	
	endfunction
endclass

class ahb_split_seqs extends ahb_base_seqs;
	`uvm_object_utils(ahb_split_seqs)

	function new(string name = "ahb_split_seqs");
		super.new(name);
	endfunction

	task body();
		req = ahb_mxtn::type_id::create("req");
		start_item(req);
		assert(req.randomize() with {Htrans == 2'b10; Hburst == 0;}) else
			`uvm_error(get_type_name(),"RANDOMIZATION FAILED")
		trans_type(req);
		finish_item(req);
	endtask
endclass

class ahb_dincr_seqs extends ahb_base_seqs;
	`uvm_object_utils(ahb_dincr_seqs)
	bit [`WIDTH-1:0] loc_Haddr;
	bit loc_Hwrite;
	bit [2:0] loc_Hsize;
	bit [2:0] loc_Hburst;
	bit [1:0] loc_Htrans;
	int loc_transfer;
	int i;	

	function new (string name = "ahb_dincr_seqs");
		super.new(name);
	endfunction

	task body();
		req = ahb_mxtn::type_id::create("req");
		start_item(req);
		assert(req.randomize() with {Htrans == 2'b10; Hburst inside {3,5,7}; Hwrite == 1;}) else
			`uvm_error(get_type_name(),"RANDOMIZATION FAILED")
		trans_type(req);
		finish_item(req);

		loc_Haddr = req.Haddr;
		loc_Hwrite = req.Hwrite;
		loc_Hsize = req.Hsize;
		loc_Hburst = req.Hburst;
		loc_Htrans = req.Htrans;
		loc_transfer = req.no_of_transfers;
		i =0;

		while(i< loc_transfer-1)
		begin
			start_item(req);
			assert(req.randomize() with {
						Htrans dist {2'b01:=1, 2'b11:=1};
						Htrans inside {2'b01,2'b11}; 
						Hburst == loc_Hburst;
						Hsize == loc_Hsize;
						Hwrite == loc_Hwrite;
						Haddr == loc_Haddr + (2**loc_Hsize);
						}) else
				`uvm_error(get_type_name(),"RANDOMIZATION FAILED")

			if(loc_Htrans == 2'b01)
			begin
				req.Htrans = 2'b11;
				req.Haddr = loc_Haddr;
			end
			trans_type(req);
			finish_item(req);
			loc_Haddr = req.Haddr;
			loc_Htrans = req.Htrans;
			if(req.Htrans == 2'b11)
				i++;
		end
	endtask
endclass

class ahb_idincr_seqs extends ahb_base_seqs;
	`uvm_object_utils(ahb_idincr_seqs)
	bit [`WIDTH-1:0] loc_Haddr;
	bit loc_Hwrite;
	bit [2:0] loc_Hsize;
	bit [2:0] loc_Hburst;
	bit [1:0] loc_Htrans;
	int loc_transfer;
	int i;

	function new(string name = "ahb_idincr_seqs");
		super.new(name);
	endfunction

	task body();
		req = ahb_mxtn::type_id::create("req");
		start_item(req);
		assert(req.randomize() with {Htrans == 2'b10; Hburst == 1;}) else
			`uvm_error(get_type_name(),"RANDOMIZATION FAILED")
		trans_type(req);
		finish_item(req);
		loc_Haddr = req.Haddr;
		loc_Hwrite = req.Hwrite;
		loc_Hsize = req.Hsize;
		loc_Hburst = req.Hburst;
		loc_Htrans = req.Htrans;
		loc_transfer = req.no_of_transfers;
		i = 0;

		while(i < loc_transfer-1)
		begin
			start_item(req);
			req.addr_limit.constraint_mode(0);
			assert(req.randomize() with {
						Htrans dist {2'b01:=1, 2'b11:=10};
						Htrans inside {2'b01,2'b11};
						Hburst == loc_Hburst;
						Hsize == loc_Hsize;
						Hwrite == loc_Hwrite;
						Haddr == loc_Haddr + (2**loc_Hsize);
						}) else
				`uvm_fatal(get_type_name(),"RANDOMIZATION FAILED")

			if(loc_Htrans == 2'b01)
			begin
				req.Htrans = 2'b11;
				req.Haddr = loc_Haddr;
			end
			trans_type(req);
			req.no_of_transfers = loc_transfer;
			finish_item(req);
			loc_Haddr = req.Haddr;
			loc_Htrans = req.Htrans;
			if(req.Htrans == 2'b11)
				i++;
		end
	endtask
endclass

class ahb_wrap_seqs extends ahb_base_seqs;
	`uvm_object_utils(ahb_wrap_seqs)
	bit [`WIDTH-1:0] loc_Haddr;
	bit loc_Hwrite;
	bit [2:0] loc_Hsize;
	bit [2:0] loc_Hburst;
	bit [1:0] loc_Htrans;
	int loc_transfer;
	int i;
	bit [`WIDTH-1:0] start_addr;
	bit [`WIDTH-1:0] wrap_addr;

	function new(string name = "ahb_wrap_seqs");
		super.new(name);
	endfunction

	task body();
		req = ahb_mxtn::type_id::create("req");
		start_item(req);
		assert(req.randomize() with {Htrans == 2'b10; Hburst inside {2,4,6};}) else
			`uvm_error(get_type_name(),"RANDOMIZATION FAILED")
		trans_type(req);
		finish_item(req);

		loc_Haddr = req.Haddr;
		loc_Hwrite = req.Hwrite;
		loc_Hsize = req.Hsize;
		loc_Hburst = req.Hburst;
		loc_Htrans = req.Htrans;
		loc_transfer = req.no_of_transfers;
		i = 0;

		start_addr = int'(loc_Haddr/(loc_transfer*(2**loc_Hsize)))*(loc_transfer*(2**loc_Hsize));
		wrap_addr = start_addr+(loc_transfer*(2**loc_Hsize));

		$display("HADDR : %8h",loc_Haddr%1024);
		$display("START ADDR : %8h",start_addr%1024);
		$display("WRAP ADDR : %8h",wrap_addr%1024);
		
		while(i < loc_transfer-1)
		begin
			start_item(req);
			assert(req.randomize() with {
						Htrans dist {2'b01:=1, 2'b11:=2};
						Htrans inside {2'b01,2'b11}; 
						Hburst == loc_Hburst;
						Hsize == loc_Hsize;
						Hwrite == loc_Hwrite;
						Haddr == loc_Haddr + (2**loc_Hsize);
						}) else
				`uvm_error(get_type_name(),"RANDOMIZATION FAILED")

			if(req.Haddr >= wrap_addr)
				req.Haddr = start_addr;

			if(loc_Htrans == 2'b01)
			begin
				req.Htrans = 2'b11;
				req.Haddr = loc_Haddr;
			end
			trans_type(req);
			finish_item(req);
			loc_Haddr = req.Haddr;
			loc_Htrans = req.Htrans;
			if(req.Htrans == 2'b11)
				i++;
		end
	endtask
endclass


