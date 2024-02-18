library verilog;
use verilog.vl_types.all;
entity gpio is
    generic(
        DATA_WIDTH      : integer := 32;
        ADDR_WIDTH      : integer := 32;
        CONFIG_ADDR     : integer := 0;
        INPUT_ADDR      : integer := 4;
        OUTPUT_ADDR     : integer := 8
    );
    port(
        gpio_in         : in     vl_logic_vector;
        gpio_out        : out    vl_logic_vector;
        gpio_en         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of CONFIG_ADDR : constant is 1;
    attribute mti_svvh_generic_type of INPUT_ADDR : constant is 1;
    attribute mti_svvh_generic_type of OUTPUT_ADDR : constant is 1;
end gpio;
