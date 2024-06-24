module gpio_wrapped #(
    DATA_WIDTH  = 32,
    ADDR_WIDTH  = 32
) (
    input   PCLK,
    input   PRESETn,
    input   PSEL,
    input   PENABLE,
    input   PWRITE,
    input [ADDR_WIDTH - 1:0]  PADDR,
    input [DATA_WIDTH - 1:0]  PWDATA,
    output  PREADY,
    output [DATA_WIDTH - 1 : 0] PRDATA,

    input logic [DATA_WIDTH - 1 : 0] gpio_in,
    output logic [DATA_WIDTH - 1 : 0] gpio_out,
    output logic [DATA_WIDTH - 1 : 0] gpio_en
);
    apb_if apb(PCLK, PRESETn);

    assign apb.PCLK = PCLK;
    assign apb.PRESETn = PRESETn;
    assign apb.PADDR = PADDR;
    assign apb.PSEL = PSEL;
    assign apb.PENABLE = PENABLE;
    assign apb.PWRITE = PWRITE;
    assign apb.PWDATA = PWDATA;
    assign PREADY = apb.PREADY;
    assign PRDATA = apb.PRDATA;

    gpio dut
    (
        .apb_in      (   apb         ),
        .gpio_in     (   gpio_in     ),
        .gpio_out    (   gpio_out    ),
        .gpio_en     (   gpio_en     )
    );
endmodule
