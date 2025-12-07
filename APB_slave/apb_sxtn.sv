class apb_sxtn extends uvm_sequence_item;
	bit [`SLAVES-1:0]Pselx;
	bit Pwrite;
	bit Penable;
	bit [`WIDTH-1:0]Paddr;
	bit [`WIDTH-1:0]Prdata;
	bit [`WIDTH-1:0]Pwdata;

	`uvm_object_utils_begin(apb_sxtn)
	`uvm_field_int(Pselx,UVM_ALL_ON|UVM_BIN)
	`uvm_field_int(Pwrite,UVM_ALL_ON|UVM_BIN)
	`uvm_field_int(Penable,UVM_ALL_ON|UVM_BIN)
	`uvm_field_int(Paddr,UVM_ALL_ON|UVM_HEX)
	`uvm_field_int(Prdata,UVM_ALL_ON|UVM_HEX)
	`uvm_field_int(Pwdata,UVM_ALL_ON|UVM_HEX)
	`uvm_object_utils_end

	function new(string name = "apb_sxtn");
		super.new(name);
	endfunction
endclass
