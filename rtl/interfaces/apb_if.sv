// APB3
interface apb_if
#(
    DATA_WIDTH  = 32,
    ADDR_WIDTH  = 32
)
(
    input PCLK,
    input PRESETn
);

    logic   [ADDR_WIDTH - 1:0]  PADDR;
    logic                       PSEL;
    logic                       PENABLE;
    logic                       PWRITE;
    logic   [DATA_WIDTH - 1:0]  PWDATA;
    logic                       PREADY;
    logic   [DATA_WIDTH - 1:0]  PRDATA;

modport master (
    output  PADDR,
    output  PSEL,
    output  PENABLE,
    output  PWRITE,
    output  PWDATA,
    input   PREADY,
    input   PRDATA
);

modport slave (
    input   PADDR,
    input   PSEL,
    input   PENABLE,
    input   PWRITE,
    input   PWDATA,
    output  PREADY,
    output  PRDATA
);

endinterface
