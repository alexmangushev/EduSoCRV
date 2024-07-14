import core_pkg::*;
import mem_control_pkg::*;
module load_store_unit
(
   	input  logic							clk,
	input  logic							rst,

	input  logic                 			mem_op,
	input  logic [ADDR_WIDTH-1:0]			mem_addr,		// Addres for write or read
	input  logic [MEM_WIDTH_CODE-1:0]		mem_control,
	output logic 							mem_op_valid,  // Read/Wrtie transaction is successful 
	input  logic [DATA_WIDTH-1:0]			mem_write_data,

	//AXI_lite Read Address Channel
	output  logic [ADDR_WIDTH-1:0]			ARADDR,
	output  logic							ARVALID,
	input 	logic 							ARREADY,

	//AXI_lite Read Data Channel
	output logic 							RREADY,
	input  logic [DATA_WIDTH-1:0]			RDATA,
	input  logic 							RVALID,

	//AXI_lite Write Address Channel
	output logic [ADDR_WIDTH-1:0]			AWADDR,
	output logic 							AWVALID,
	input  logic							AWREADY,

	//AXI_lite Write Data Channel
	output  logic [DATA_WIDTH-1:0]			WDATA,
	output  logic 							WVALID,
	input 	logic 							WREADY,

	output logic [DATA_WIDTH-1:0]			mem_read_data
);
	always_comb
	begin
		ARADDR 			= 'b0;
		ARVALID 		= 'b0;
		RREADY 			= 'b0;
		AWADDR 			= 'b0;
		AWVALID			= 'b0;
		WVALID 			= 'b0;
		mem_op_valid 	= 'b0;
		if(mem_op) begin
			if(
				mem_control == mem_lb  | 
				mem_control == mem_lbu |
				mem_control == mem_lh  |
				mem_control == mem_lhu |
				mem_control == mem_lw 
			) begin
				ARADDR  		= (mem_addr >> 2);
				ARVALID 		= 1;
				RREADY  		= 1;
				mem_op_valid 	= RVALID;
			end
			if(
				mem_control == mem_sb | 
				mem_control == mem_sh |
				mem_control == mem_sw   
			) begin
				AWADDR  		= (mem_addr >> 2);
				AWVALID 		= 1;
				WVALID  		= 1;
				mem_op_valid 	= WREADY;
			end
		end
	end

	always_comb
	begin
		mem_read_data = 'b0;
		case(mem_control)
			mem_lb:
				begin
					case(mem_addr[1:0])
						2'b00: mem_read_data = RDATA[7]  ? (32'hffffff00 | RDATA[7:0])   : (32'h000000ff & RDATA[7:0]);   // RDATA[7:0] with sign_ext
						2'b01: mem_read_data = RDATA[15] ? (32'hffffff00 | RDATA[15:8])  : (32'h000000ff & RDATA[15:8]);  // RDATA[15:8] with sign_ext
						2'b10: mem_read_data = RDATA[23] ? (32'hffffff00 | RDATA[23:16]) : (32'h000000ff & RDATA[23:16]); // RDATA[23:16] with sign_ext
						2'b11: mem_read_data = RDATA[31] ? (32'hffffff00 | RDATA[31:24]) : (32'h000000ff & RDATA[31:24]); // RDATA[31:24] with sign_ext
					endcase
				end
			mem_lh:
				begin
					case(mem_addr[1:0])
						2'b00: mem_read_data = RDATA[15] ? (32'hffff0000 | RDATA[15:0])  : (32'h0000ffff & RDATA[15:0]);  // RDATA[15:0] with sign_ext
						2'b01: mem_read_data = RDATA[23] ? (32'hffff0000 | RDATA[23:8])  : (32'h0000ffff & RDATA[23:8]);  // RDATA[23:8] with sign_ext
						2'b10: mem_read_data = RDATA[31] ? (32'hffff0000 | RDATA[31:16]) : (32'h0000ffff & RDATA[31:16]); // RDATA[31:16] with sign_ext
						2'b11: mem_read_data = RDATA[31] ? (32'hffffff00 | RDATA[31:24]) : (32'h000000ff & RDATA[31:24]); // RDATA[31:24] with sign_ext
					endcase
				end
			mem_lw:
				begin
					case(mem_addr[1:0])
						2'b00: mem_read_data = RDATA[31:0];
						2'b01: mem_read_data = RDATA[31:8];
						2'b10: mem_read_data = RDATA[31:16];
						2'b11: mem_read_data = RDATA[31:24];
					endcase
				end
			mem_lbu:
				begin
					case(mem_addr[1:0])
						2'b00: mem_read_data = 32'h000000ff & RDATA[7:0]; 		// RDATA[7:0] with zero_ext
						2'b01: mem_read_data = 32'h000000ff & RDATA[15:8];  	// RDATA[15:8] with zero_ext
						2'b10: mem_read_data = 32'h000000ff & RDATA[23:16]; 	// RDATA[23:16] with zero_ext
						2'b11: mem_read_data = 32'h000000ff & RDATA[31:24]; 	// RDATA[31:24] with zero_ext
					endcase
				end
			mem_lhu:
				begin
					case(mem_addr[1:0])
						2'b00: mem_read_data = 32'h0000ffff & RDATA[15:0];  // RDATA[15:0] with sign_ext
						2'b01: mem_read_data = 32'h0000ffff & RDATA[23:8];  // RDATA[15:8] with sign_ext
						2'b10: mem_read_data = 32'h0000ffff & RDATA[31:16]; // RDATA[23:16] with sign_ext
						2'b11: mem_read_data = 32'h000000ff & RDATA[31:24]; // RDATA[31:24] with sign_ext
					endcase
				end
			mem_sb:
				begin
					casez(mem_addr[1:0])
						2'b00: WDATA = {24'h??????, mem_write_data[7:0]}; 
						2'b01: WDATA = {16'h????, mem_write_data[7:0], 8'h??};
						2'b10: WDATA = {8'h??, mem_write_data[7:0], 16'h????};
						2'b11: WDATA = {mem_write_data[7:0], 24'h??????};
					endcase
				end
			mem_sh:
				begin
					casez(mem_addr[1:0])
						2'b00: WDATA = {16'h????, mem_write_data[15:0]}; 
						2'b01: WDATA = {8'h??, mem_write_data[15:0], 8'h??};
						2'b10: WDATA = {mem_write_data[15:0], 16'h????};
						2'b11: WDATA = {mem_write_data[7:0], 24'h??????};
					endcase
				end
			mem_sw:
				begin
					casez(mem_addr[1:0])
						2'b00: WDATA = mem_write_data[31:0]; 
						2'b01: WDATA = {mem_write_data[31:8], 8'h??};
						2'b10: WDATA = {mem_write_data[31:16], 16'h????};
						2'b11: WDATA = {mem_write_data[31:24], 24'h??????};
					endcase
				end
		endcase
	end
endmodule