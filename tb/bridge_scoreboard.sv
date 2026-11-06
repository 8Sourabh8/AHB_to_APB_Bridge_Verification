// AHB-to-APB bridge scoreboard
// Every AHB data transfer (NSEQ or SEQ beat) must turn into exactly one APB transfer,
// in the same order. For each pair the scoreboard checks:
//   Paddr  == Haddr
//   Pwrite == Hwrite
//   Pselx  == the slave that owns Haddr (4 slaves, 1 KB each)
//   write: Pwdata == the active byte lane(s) of Hwdata
//   read : Hrdata == the active byte lane(s) of Prdata
// The bridge moves the active lane down to bit 0 (see the Endianess tasks in
// apb_controller.v), so a byte write to offset 2 puts Hwdata[23:16] on Pwdata[7:0].
class bridge_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(bridge_scoreboard)
	uvm_tlm_analysis_fifo #(ahb_mxtn) ahb_fifo[];
	uvm_tlm_analysis_fifo #(apb_sxtn) apb_fifo[];
	bridge_env_config env_cfg;
	ahb_mxtn ahb_tr;
	apb_sxtn apb_tr;

	int unsigned no_of_compares;
	int unsigned no_of_passes;
	int unsigned no_of_fails;
	int unsigned no_of_writes;
	int unsigned no_of_reads;
	bit waiting_for_apb;	// an AHB transfer has been taken from ahb_fifo and is waiting for its APB transfer

	// Values sampled by the covergroup after every compare
	bit cov_write;
	bit [2:0] cov_size;
	bit [1:0] cov_trans;
	bit [`SLAVES-1:0] cov_sel;

	covergroup bridge_cg;
		option.per_instance = 1;
		RW    : coverpoint cov_write { bins read = {0}; bins write = {1}; }
		SIZE  : coverpoint cov_size  { bins byte_size = {0}; bins halfword = {1}; bins word = {2}; }
		TRANS : coverpoint cov_trans { bins nonseq = {2'b10}; bins seq = {2'b11}; }
		SLAVE : coverpoint cov_sel   { bins slave1 = {4'b0001}; bins slave2 = {4'b0010};
		                               bins slave3 = {4'b0100}; bins slave4 = {4'b1000}; }
		RW_X_SIZE_X_SLAVE : cross RW, SIZE, SLAVE;
	endgroup

	function new(string name = "bridge_scoreboard", uvm_component parent);
		super.new(name,parent);
		bridge_cg = new();
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

	// Reference model 1: which slave owns this address (base addresses from ahb_slave.v)
	function bit [`SLAVES-1:0] expected_psel(bit [`WIDTH-1:0] addr);
		expected_psel = '0;
		if(addr >= 32'h8000_0000 && addr <= 32'h8000_03FF) expected_psel = 4'b0001;
		else if(addr >= 32'h8400_0000 && addr <= 32'h8400_03FF) expected_psel = 4'b0010;
		else if(addr >= 32'h8800_0000 && addr <= 32'h8800_03FF) expected_psel = 4'b0100;
		else if(addr >= 32'h8C00_0000 && addr <= 32'h8C00_03FF) expected_psel = 4'b1000;
	endfunction

	// Reference model 2: pick the active byte lane(s) and move them to bit 0
	function bit [`WIDTH-1:0] active_lane(bit [`WIDTH-1:0] data, bit [2:0] size, bit [1:0] offset);
		case(size)
			3'b000 : active_lane = (data >> (8*offset)) & 32'h0000_00FF;		// byte
			3'b001 : case(offset)						// halfword
					2'b00  : active_lane = data[15:0];
					2'b10  : active_lane = data[31:16];
					default: active_lane = '0;
				 endcase
			3'b010 : active_lane = (offset == 2'b00) ? data : '0;		// word
			default: active_lane = '0;
		endcase
	endfunction

	task run_phase(uvm_phase phase);
		forever begin
			ahb_fifo[0].get(ahb_tr);
			waiting_for_apb = 1'b1;
			apb_fifo[0].get(apb_tr);
			waiting_for_apb = 1'b0;
			compare(ahb_tr, apb_tr);
		end
	endtask

	function void compare(ahb_mxtn ahb, apb_sxtn apb);
		bit pass = 1'b1;
		bit [`SLAVES-1:0] exp_sel = expected_psel(ahb.Haddr);
		bit [`WIDTH-1:0] exp_data;
		no_of_compares++;

		if(apb.Paddr !== ahb.Haddr) begin
			pass = 1'b0;
			`uvm_error(get_type_name(),$sformatf("TRANSFER %0d ADDRESS MISMATCH : Haddr = %8h, Paddr = %8h", no_of_compares, ahb.Haddr, apb.Paddr))
		end
		if(apb.Pwrite !== ahb.Hwrite) begin
			pass = 1'b0;
			`uvm_error(get_type_name(),$sformatf("TRANSFER %0d DIRECTION MISMATCH : Hwrite = %0b, Pwrite = %0b", no_of_compares, ahb.Hwrite, apb.Pwrite))
		end
		if(apb.Pselx !== exp_sel) begin
			pass = 1'b0;
			`uvm_error(get_type_name(),$sformatf("TRANSFER %0d SLAVE SELECT MISMATCH : Haddr = %8h, expected Pselx = %4b, got %4b", no_of_compares, ahb.Haddr, exp_sel, apb.Pselx))
		end

		if(ahb.Hwrite) begin
			no_of_writes++;
			exp_data = active_lane(ahb.Hwdata, ahb.Hsize, ahb.Haddr[1:0]);
			if(apb.Pwdata !== exp_data) begin
				pass = 1'b0;
				`uvm_error(get_type_name(),$sformatf("TRANSFER %0d WRITE DATA MISMATCH : Hwdata = %8h, Hsize = %0d, expected Pwdata = %8h, got %8h", no_of_compares, ahb.Hwdata, ahb.Hsize, exp_data, apb.Pwdata))
			end
		end
		else begin
			no_of_reads++;
			exp_data = active_lane(apb.Prdata, ahb.Hsize, apb.Paddr[1:0]);
			if(ahb.Hrdata !== exp_data) begin
				pass = 1'b0;
				`uvm_error(get_type_name(),$sformatf("TRANSFER %0d READ DATA MISMATCH : Prdata = %8h, Hsize = %0d, expected Hrdata = %8h, got %8h", no_of_compares, apb.Prdata, ahb.Hsize, exp_data, ahb.Hrdata))
			end
		end

		if(pass) begin
			no_of_passes++;
			`uvm_info(get_type_name(),$sformatf("TRANSFER %0d PASSED : %s %s Haddr = %8h, Hsize = %0d, Pselx = %4b",
				no_of_compares, ahb.transfer_type, ahb.Hwrite ? "WRITE" : "READ", ahb.Haddr, ahb.Hsize, apb.Pselx),UVM_LOW)
		end
		else
			no_of_fails++;

		cov_write = ahb.Hwrite;
		cov_size  = ahb.Hsize;
		cov_trans = ahb.Htrans;
		cov_sel   = apb.Pselx;
		bridge_cg.sample();
	endfunction

	// Nothing may be left over: every AHB transfer must have reached the APB side and vice versa
	function void check_phase(uvm_phase phase);
		int unsigned missing = ahb_fifo[0].used() + waiting_for_apb;
		super.check_phase(phase);
		if(missing != 0)
			`uvm_error(get_type_name(),$sformatf("%0d AHB transfer(s) never appeared on the APB side", missing))
		if(apb_fifo[0].used() != 0)
			`uvm_error(get_type_name(),$sformatf("%0d APB transfer(s) had no matching AHB transfer", apb_fifo[0].used()))
	endfunction

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		`uvm_info(get_type_name(),$sformatf("\n---------- BRIDGE SCOREBOARD SUMMARY ----------\n transfers compared : %0d (writes %0d, reads %0d)\n passed             : %0d\n failed             : %0d\n functional coverage: %0.2f %%\n------------------------------------------------",
			no_of_compares, no_of_writes, no_of_reads, no_of_passes, no_of_fails, bridge_cg.get_inst_coverage()),UVM_LOW)
	endfunction
endclass
