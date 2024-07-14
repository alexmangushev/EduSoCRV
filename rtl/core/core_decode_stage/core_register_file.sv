import core_pkg::*;
module core_register_file (
    input logic         		  clk,			// clock 
	
	// input read port
	input  logic [ 4:0] 		  read_addr1, 	// read address port 0
	input  logic [ 4:0] 		  read_addr2, 	// read address port 1
	 
	// output read port
	output logic [DATA_WIDTH-1:0] read_data1, 	// read data port 0
	output logic [DATA_WIDTH-1:0] read_data2, 	// read data port 1
	 
	// input write port
	input  logic [DATA_WIDTH-1:0] write_data,  // write data
    input  logic [ 4:0]			  write_addr,  // write address
	 
	// control signal for write
	input logic         we					   // write enable
);
    logic [31:0] register_memory[31:0];
	always_ff @(posedge clk)
		if (we) register_memory[write_addr] <= write_data;
		
	assign read_data1 = (read_addr1 != 0) ? register_memory[read_addr1] : 0;
	assign read_data2 = (read_addr2 != 0) ? register_memory[read_addr2] : 0;
endmodule
