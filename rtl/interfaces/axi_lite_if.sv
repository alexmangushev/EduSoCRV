// APB3
interface apb_if;
#(
    DATA_WIDTH  = 32,
    ADDR_WIDTH  = 32
)
(
    input ACLK,
    input ARESETn
)

    logic [ADDR_WIDTH - 1:0]            AWADDR;
    logic                               AWVALID;
    logic [2:0]                         AWPROT;
    logic                               AWREADY;

    logic [DATA_WIDTH - 1:0]            WDATA;
    logic [$clog2(DATA_WIDTH) - 1:0]    WSTRB;
    logic                               WVALID;
    logic                               WREADY;

    logic                               BRESP;
    logic                               BVALID;
    logic                               BREADY;


    logic [ADDR_WIDTH - 1:0]            ARADDR;
    logic                               ARVALID;
    logic                               ARREADY;

    logic [DATA_WIDTH - 1:0]            RDATA;
    logic                               RRESP;
    logic                               RVALID;
    logic                               RREADY;

modport master (
    output  AWADDR,
    output  AWVALID,
    output  AWPROT,
    input   AWREADY,

    output  WDATA,
    output  WSTRB,
    output  WVALID,
    input   WREADY,

    input   BRESP,
    input   BVALID,
    output  BREADY,

    output  ARADDR,
    output  ARVALID,
    input   ARREADY,

    input   RDATA,
    input   RRESP,
    input   RVALID,
    output  RREADY
);

modport slave (
    input   AWADDR,
    input   AWVALID,
    input   AWPROT,
    output  AWREADY,

    input   WDATA,
    input   WSTRB,
    input   WVALID,
    output  WREADY,

    output  BRESP,
    output  BVALID,
    input   BREADY,

    input   ARADDR,
    input   ARVALID,
    output  ARREADY,

    output  RDATA,
    output  RRESP,
    output  RVALID,
    input   RREADY
);

endinterface