module soc_riscv_core_test(
	input logic                     clk,          // clock
	input logic                     rst,          // reset

	//mem_fetch write channel (NO_AXI)
	input logic  [31:0]             mem_fetch_write_data,
	input logic  [4:0]              mem_fetch_write_addr,
	input logic                     mem_fetch_write_en,

	//mem_data wrtie channel  (NO_AXI)
	input logic  [31:0]				mem_data_write_data,
	input logic  [4:0]				mem_data_write_addr,
	input logic  					mem_data_write_en	

);	 
	//mem_fetch AXI_LITE READ channel
	logic  [31:0]   			mem_fetch_RDATA;
	logic						mem_fetch_RVALID;
	logic						mem_fetch_RREADY;

	//mem_fetch  AXI_lite READ ADDR channel
	logic                     	mem_fetch_ARREADY;
	logic  [4:0]              	mem_fetch_ARADDR;
	logic                     	mem_fetch_ARVALID;

	//Core fetch AXI_lite READ channel
	logic  [31:0]				core_instr_RDATA;
	logic						core_instr_RVALID;
	logic						core_instr_RREADY;

	//Core fetch AXI_lite READ ADDR channel
	logic						core_instr_ARREADY;
	logic  [31:0]				core_instr_ARADDR;
	logic						core_instr_ARVALID;

	//mem_data AXI_lite Read Address Channel
	logic [31:0]					core_data_ARADDR;
	logic  							core_data_ARVALID;
	logic 							core_data_ARREADY;

	//mem_data AXI_lite Read Data Channel
	logic  							core_data_RREADY;
	logic [31:0]					core_data_RDATA;
	logic 							core_data_RVALID;

	//mem_data AXI_lite Write Address Channel
	logic [31:0]					core_data_AWADDR;
	logic 							core_data_AWVALID;
	logic							core_data_AWREADY;

	//mem_data AXI_lite Write Data Channel
	logic [31:0]					core_data_WDATA;
	logic 							core_data_WREADY;
	logic 							core_data_WVALID;

	main_ram_fetch ram_fetch(
		.clk           (clk           		),
		.write_data    (mem_fetch_write_data),
		.write_addr    (mem_fetch_write_addr),
		.write_en      (mem_fetch_write_en  ),
		.RDATA         (mem_fetch_RDATA     ),
		.RVALID        (mem_fetch_RVALID    ),
		.RREADY        (mem_fetch_RREADY    ),
		.ARADDR        (mem_fetch_ARADDR    ),
		.ARREADY       (mem_fetch_ARREADY   ),
		.ARVALID       (mem_fetch_ARVALID   )
	);
	 
	main_ram_data ram_data(
		.clk			(clk					),
		.write_data 	(mem_data_write_data	),
		.write_addr		(mem_data_write_addr	),
		.write_en		(mem_data_write_en		),
		.ARADDR			(core_data_ARADDR		),		
		.ARREADY		(core_data_ARREADY		),
		.ARVALID		(core_data_ARVALID		),
		.AWADDR			(core_data_AWADDR		),
		.AWREADY		(core_data_AWREADY		),
		.AWVALID		(core_data_AWVALID		),
		.RDATA			(core_data_RDATA		),
		.RREADY			(core_data_RREADY		),
		.RVALID			(core_data_RVALID		),
		.WDATA			(core_data_WDATA		),
		.WREADY 		(core_data_WREADY		),
		.WVALID			(core_data_WVALID		)
	);

	assign core_instr_RDATA   	= mem_fetch_RDATA;
	assign core_instr_RVALID 	= mem_fetch_RVALID;
	assign core_instr_ARREADY 	= mem_fetch_ARREADY;
	assign mem_fetch_RREADY		= core_instr_RREADY;
	assign mem_fetch_ARADDR     = core_instr_ARADDR;
	assign mem_fetch_ARVALID	= core_instr_ARVALID;
	 
	soc_riscv_core core (
		.clk				(clk                ),
		.rst				(rst                ),
		.core_instr_RDATA	(core_instr_RDATA   ),
		.core_instr_RVALID	(core_instr_RVALID  ),
		.core_instr_RREADY	(core_instr_RREADY  ),
		.core_instr_ARREADY	(core_instr_ARREADY ),
		.core_instr_ARADDR	(core_instr_ARADDR  ),
		.core_instr_ARVALID	(core_instr_ARVALID ),
		.core_data_ARADDR	(core_data_ARADDR	),		
		.core_data_ARREADY	(core_data_ARREADY	),
		.core_data_ARVALID	(core_data_ARVALID	),
		.core_data_AWADDR	(core_data_AWADDR	),
		.core_data_AWREADY	(core_data_AWREADY	),
		.core_data_AWVALID	(core_data_AWVALID	),
		.core_data_RDATA	(core_data_RDATA	),
		.core_data_RREADY	(core_data_RREADY	),
		.core_data_RVALID	(core_data_RVALID	),
		.core_data_WDATA	(core_data_WDATA	),
		.core_data_WREADY 	(core_data_WREADY	),
		.core_data_WVALID	(core_data_WVALID	)
	);
	 
endmodule

