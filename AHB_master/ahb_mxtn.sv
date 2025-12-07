class ahb_mxtn extends uvm_sequence_item;
	bit Hresetn;
   	rand bit [1:0] Htrans;
	rand bit [2:0]Hsize; 
	bit Hreadyin;
	rand bit [`WIDTH-1:0]Hwdata; 
	rand bit [`WIDTH-1:0]Haddr;
	rand bit Hwrite;
	bit [`WIDTH-1:0]Hrdata;
	bit [1:0]Hresp;
	bit Hreadyout;
	rand bit[2:0]Hburst;
	rand bit [9:0]no_of_transfers;
	string transfer_type;

	`uvm_object_utils_begin(ahb_mxtn)
	`uvm_field_int(Hresetn,UVM_ALL_ON|UVM_BIN)
	`uvm_field_int(Htrans,UVM_ALL_ON|UVM_BIN)
	`uvm_field_string(transfer_type,UVM_ALL_ON)
	`uvm_field_int(Hsize,UVM_ALL_ON|UVM_DEC)
	`uvm_field_int(Hreadyin,UVM_ALL_ON|UVM_BIN)
	`uvm_field_int(Haddr,UVM_ALL_ON|UVM_HEX)
	`uvm_field_int(Hwdata,UVM_ALL_ON|UVM_HEX)
	`uvm_field_int(Hwrite,UVM_ALL_ON|UVM_BIN)
	`uvm_field_int(Hrdata,UVM_ALL_ON|UVM_HEX)
	`uvm_field_int(Hresp,UVM_ALL_ON|UVM_DEC)
	`uvm_field_int(Hreadyout,UVM_ALL_ON|UVM_BIN)
	`uvm_field_int(Hburst,UVM_ALL_ON|UVM_DEC)
	`uvm_field_int(no_of_transfers,UVM_ALL_ON|UVM_DEC)
	`uvm_object_utils_end

	function new(string name = "ahb_mxtn");
		super.new(name);
	endfunction

	constraint valid_size {
			Hsize inside {[0:2]};
			}

	constraint addr_range {
			Haddr inside {[32'h80000000:32'h800003ff],
					[32'h84000000:32'h840003ff],
					[32'h88000000:32'h880003ff],
					[32'h8c000000:32'h8c0003ff]};
			}

	constraint valid_addr {
			(Hsize == 1) -> (Haddr%2 == 0);
			(Hsize == 2) -> (Haddr%4 == 0);
			}

	constraint transfer_size {
			(Hburst == 0) -> (no_of_transfers == 1);
			(Hburst == 2) -> (no_of_transfers == 4);
			(Hburst == 3) -> (no_of_transfers == 4);
			(Hburst == 4) -> (no_of_transfers == 8);
			(Hburst == 5) -> (no_of_transfers == 8);
			(Hburst == 6) -> (no_of_transfers == 16);
			(Hburst == 7) -> (no_of_transfers == 16);
			}
	constraint min_transfer {
			(Hburst == 1) -> (no_of_transfers > 1);
			}

	constraint addr_limit {
			(no_of_transfers*(2**Hsize))+(Haddr)%1024 <= 1023;
			}
endclass
