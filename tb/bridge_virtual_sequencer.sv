class bridge_virtual_sequencer extends uvm_sequencer#(uvm_sequence_item);
	`uvm_component_utils(bridge_virtual_sequencer)

	function new(string name = "bridge_virtual_sequencer", uvm_component parent);
		super.new(name,parent);
	endfunction
endclass
