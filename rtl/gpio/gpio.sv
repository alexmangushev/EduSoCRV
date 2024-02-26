module gpio
#(
    DATA_WIDTH  = 32,
    ADDR_WIDTH  = 32,
    CONFIG_ADDR = 0,
    INPUT_ADDR  = 4,
    OUTPUT_ADDR = 8
)
(
    apb_if.slave                        apb_in,
    input   logic [DATA_WIDTH - 1 : 0]  gpio_in,
    output  logic [DATA_WIDTH - 1 : 0]  gpio_out,
    output  logic [DATA_WIDTH - 1 : 0]  gpio_en
);

localparam REGISTER_COUNT       = 3;

//-------------------------------------
//              Signals
//-------------------------------------

logic apb_wait; // set when apb master wait answer;
logic clk;
logic arstn;

logic [REGISTER_COUNT * DATA_WIDTH - 1 : 0] apb_registers; // registers
logic [DATA_WIDTH - 1 : 0]                  apb_prdata;

//-------------------------------------
//              Assigns
//-------------------------------------


assign apb_wait = apb_in.PSEL & apb_in.PENABLE;

assign gpio_out = apb_registers[OUTPUT_ADDR * 8 +: DATA_WIDTH];
assign gpio_en  = apb_registers[DATA_WIDTH - 1 : 0];

assign clk      = apb_in.PCLK;
assign arstn    = apb_in.PRESETn;

//-------------------------------------
//              Always
//-------------------------------------


// Work with registers
always_ff @(posedge clk or negedge arstn) begin
    if (!arstn) begin
        apb_registers <= '0;
    end
    else if (apb_wait & apb_in.PWRITE) begin
        apb_registers[apb_in.PADDR[7:0] << 3 +: DATA_WIDTH] <= apb_in.PWDATA;
    end
end

// Set data for read transaction
always_comb
case (apb_in.PADDR[2:0])
    CONFIG_ADDR:    apb_prdata = apb_registers[DATA_WIDTH - 1 : 0];
    INPUT_ADDR:     apb_prdata = apb_registers[INPUT_ADDR << 3 +: DATA_WIDTH];
    OUTPUT_ADDR:    apb_prdata = apb_registers[OUTPUT_ADDR << 3 +: DATA_WIDTH];
    default:        apb_prdata = '0;
endcase

// Set data and ready to APB
always_ff @(posedge clk or negedge arstn) begin
    if (!arstn) begin
        apb_in.PREADY <= '0;
        apb_in.PRDATA <= '0;
    end
    else if (apb_wait) begin
        apb_in.PREADY <= '1;
        apb_in.PRDATA <= apb_prdata;
    end
    else begin
        apb_in.PREADY <= '0;
        apb_in.PRDATA <= '0;
    end
end

endmodule
