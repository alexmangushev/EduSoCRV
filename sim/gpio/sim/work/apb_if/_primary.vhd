library verilog;
use verilog.vl_types.all;
entity apb_if is
    generic(
        DATA_WIDTH      : integer := 32;
        ADDR_WIDTH      : integer := 32
    );
    port(
        PCLK            : in     vl_logic;
        PRESETn         : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
end apb_if;
