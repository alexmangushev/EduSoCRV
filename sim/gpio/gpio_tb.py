'''
By default GPIO module testeing with full 32 bit vector for APB 3
'''
import random
import enum
import cocotb
import cocotb.triggers as trigg
from cocotb.clock import Clock


CLK_PERIOD = 10
START_CYCLEC_NUM = 3
SYNC_DEPTH = 3
MIN_BUS_VALUE = int(32 * '0', base=2)
MAX_BUS_VALUE = int(32 * '1', base=2)
RANGES_FOR_RANDOM = (
    MIN_BUS_VALUE,
    MAX_BUS_VALUE
)


class GPIORegAddreses(enum.Enum):
    CONFIG_ADDR = 0
    INPUT_ADDR  = 4
    OUTPUT_ADDR = 8


def init_clk(clk_wire):
    clock = Clock(clk_wire, CLK_PERIOD)
    cocotb.start_soon(clock.start(start_high=False))


class APBMasterToSlaveWrapper:
    '''APB3 master to slave wrapper'''

    def __init__(self, dut, is_stretch_transactions=False):
        # ref for instante of APB interface in module inst
        self._apb_slave = dut 
        self._is_stretch_transactions = is_stretch_transactions
        self.reset_control_signals()
    
    # Setup Phase
    def setup_write_transaction(self, paddr, pwdata):
        # TODO: types for paddr and pwdata
        self._apb_slave.PWRITE.value = 1
        self._apb_slave.PSEL.value = 1
        self._apb_slave.PADDR.value = paddr
        self._apb_slave.PWDATA.value = pwdata # data write immediately


    def setup_read_transaction(self, paddr):
        self._apb_slave.PWRITE.value = 0
        self._apb_slave.PSEL.value = 1
        self._apb_slave.PADDR.value = paddr
        
    # Access Phase
    def access_transaction(self):
        self._apb_slave.PENABLE.value = 1


    def slave_is_ready(self):
        return self._apb_slave.PREADY.value


    def read_data(self):
        return self._apb_slave.PRDATA.value


    def reset_control_signals(self):
        self._apb_slave.PSEL.value = 0
        self._apb_slave.PENABLE.value = 0


    def _check_slave_ready_before_setup(self):
        if not self.slave_is_ready():
            raise RuntimeError(
                "PREADY dont set before transaction, slave is broken"
            )


    def _apb_clock_rising_edge(self):
        return trigg.RisingEdge(self._apb_slave.PCLK)


    async def _wait_slave_for_ready(self):
        while not self.slave_is_ready():   # +- good
            if not self._is_stretch_transactions:
                raise ValueError(
                    "Slave is stretch (PREADY is 0)"
                    ", but it says something else"
                )
            await self._apb_clock_rising_edge()


    async def run_write_transaction(self, paddr, pwdata):
        '''APB  transaction for write reg (paddr) into module'''
        await self._apb_clock_rising_edge()         # first cycle
        self.setup_write_transaction(paddr, pwdata)
        # self._check_slave_ready_before_setup()
        await self._apb_clock_rising_edge()         # second cycle

        self.access_transaction()   # maybe set immidedly
        await self._wait_slave_for_ready()

        self.reset_control_signals()
        await self._apb_clock_rising_edge()         # end transaction


    async def run_read_transaction(self, paddr):
        '''APB  transaction for read reg (paddr) into module'''
        await self._apb_clock_rising_edge()         # first cycle
        self.setup_read_transaction(paddr)
        # self._check_slave_ready_before_setup()
        await self._apb_clock_rising_edge()         # second cycle

        self.access_transaction()   # maybe set immidedly
        await self._wait_slave_for_ready()

        data = self.read_data()
        self.reset_control_signals()
        await self._apb_clock_rising_edge()         # end transaction
        return data


class GPIORegWrapper:

    def __init__(self, apb_dut):
        self._apb_dut = apb_dut
        self.config = 0
        self.write = 0
        self.read = 0


    async def __aenter__(self):
        self.config = await self._apb_dut.run_read_transaction(
            paddr=GPIORegAddreses.CONFIG_ADDR.value
        )
        self.read = await self._apb_dut.run_read_transaction(
            paddr=GPIORegAddreses.INPUT_ADDR.value
        )


    async def __aexit__(self, exc_type, exc_value, traceback):
        if exc_value:
            raise exc_value

        # maybe create csome cheks for property values

        await self._apb_dut.run_write_transaction(
            paddr=GPIORegAddreses.CONFIG_ADDR.value,
            pwdata=self.config
        )
        await self._apb_dut.run_write_transaction(
            paddr=GPIORegAddreses.OUTPUT_ADDR.value,
            pwdata=self.write
        )


@cocotb.test()
async def test_only_configurating_gpio(dut: cocotb.handle.HierarchyObject):
    '''
    test change pins into GPIO port (GPIO configuration),
    test apb transactions
    '''
    clk = dut.PCLK
    rst_n = dut.PRESETn

    rst_n.value = 0
    init_clk(clk)
    for _ in range(START_CYCLEC_NUM):
        await trigg.RisingEdge(clk)
    rst_n.value = 1
    await trigg.RisingEdge(clk)

    my_gpio_apb = APBMasterToSlaveWrapper(
        dut, is_stretch_transactions=True
    )

    for _ in range(12):
        pins_config = random.randint(
            *RANGES_FOR_RANDOM
        )

        await my_gpio_apb.run_write_transaction(
            paddr=GPIORegAddreses.CONFIG_ADDR.value,
            pwdata=pins_config
        )
        assert dut.gpio_en.value == pins_config

        data = await my_gpio_apb.run_read_transaction(
            paddr=GPIORegAddreses.CONFIG_ADDR.value
        )
        assert data == pins_config

        dut._log.info(
            f"APB tranasactions with value {pins_config} done!"
        )

    dut._log.info("PASS!!!")
    

@cocotb.test()
async def test_gpio_output(dut):
    '''test configurating GPIO to output and write value'''
    clk = dut.PCLK
    rst_n = dut.PRESETn

    rst_n.value = 0
    init_clk(clk)
    for _ in range(START_CYCLEC_NUM):
        await trigg.RisingEdge(clk)
    rst_n.value = 1
    await trigg.RisingEdge(clk)

    my_gpio_apb = APBMasterToSlaveWrapper(
        dut, is_stretch_transactions=True
    )

    set_all_pins_to_output = MAX_BUS_VALUE
    await my_gpio_apb.run_write_transaction(
        paddr=GPIORegAddreses.CONFIG_ADDR.value,
        pwdata=set_all_pins_to_output
    )
    assert dut.gpio_en.value == set_all_pins_to_output
    dut._log.info("Succes config GPIO an output1")

    for _ in range(12):
        set_to_output = random.randint(
            *RANGES_FOR_RANDOM
        )
        await my_gpio_apb.run_write_transaction(
            paddr=GPIORegAddreses.OUTPUT_ADDR.value,
            pwdata=set_to_output
        )
        assert dut.gpio_out.value == set_to_output
        dut._log.info(f"Succes value {set_to_output} set an output")
    
    dut._log.info("PASS!!!")


@cocotb.test()
async def test_gpio_input(dut):
    '''test configurating GPIO to input and read value'''
    clk = dut.PCLK
    rst_n = dut.PRESETn

    rst_n.value = 0
    init_clk(clk)
    for _ in range(START_CYCLEC_NUM):
        await trigg.RisingEdge(clk)
    rst_n.value = 1
    await trigg.RisingEdge(clk)

    my_gpio_apb = APBMasterToSlaveWrapper(
        dut, is_stretch_transactions=True
    )

    set_all_pins_to_input = MIN_BUS_VALUE
    await my_gpio_apb.run_write_transaction(
        paddr=GPIORegAddreses.CONFIG_ADDR.value,
        pwdata=set_all_pins_to_input
    )
    assert dut.gpio_en.value == set_all_pins_to_input
    dut._log.info("Succes config GPIO to input")

    for _ in range(12):
        set_to_input = random.randint(
            *RANGES_FOR_RANDOM
        )
        dut.gpio_in.value = set_to_input
        
        for _ in range(SYNC_DEPTH):     # test synchronaizer in GPIO
            await trigg.RisingEdge(clk)

        data = await my_gpio_apb.run_read_transaction(
            paddr=GPIORegAddreses.INPUT_ADDR.value
        )
        assert data == set_to_input 
        dut._log.info(f"Succes value {set_to_input} set an input")
    
    dut._log.info("PASS!!!")


@cocotb.test()
async def test_some_real_gpio(dut):
    '''
    test as if we had connected one LED and one button 
    to different GPIO pins of the module in real conditions
    TODO: add randomaised in values
    '''
    clk = dut.PCLK
    rst_n = dut.PRESETn

    rst_n.value = 0
    init_clk(clk)
    for _ in range(START_CYCLEC_NUM):
        await trigg.RisingEdge(clk)
    rst_n.value = 1
    await trigg.RisingEdge(clk)

    duti = GPIORegWrapper(
        APBMasterToSlaveWrapper(
            dut, is_stretch_transactions=True
        )
    )

    async with duti:
        duti.config = 0
        duti.config |= ((1 << 2) | (1 << 8))
        duti.config &= ~(1 << 4)

        duti.write |= (1 << 8)

    assert dut.gpio_en.value == duti.config
    dut._log.info("Success config GPIO")

    assert dut.gpio_out.value == duti.write
    dut._log.info("Success writing to output")

    dut.gpio_in.value == (1 << 4)
    for _ in range(SYNC_DEPTH):
        await trigg.RisingEdge(clk)

    async with duti:
        assert duti.read == dut.gpio_in.value
    dut._log.info("Success read from GPIO")

    dut._log.info("PASS!!!")


if __name__ == '__main__':
    import sys
    from cocotb.runner import get_runner
    from pathlib import Path

    SIMS = ("icarus", "questa")
    sim = "questa"
    hdl_toplevel = "gpio_wrapped"

    proj_path = Path(__file__).resolve().parent.parent.parent
    # print(proj_path)

    try:
        sim = sys.argv[-1]
        print(sys.argv)
        if not sim in SIMS:
            raise ValueError
    except:
        sim = "questa"
        print("questa default")
        
    runner = get_runner(sim)
    runner.build(
        verilog_sources=[
            "gpio_wrapped.sv",
            proj_path / "rtl" / "gpio" / "gpio.sv",
            proj_path / "rtl" / "gpio" / "gpio_bit_slice.sv",
            proj_path / "rtl" / "interfaces" / "apb_if.sv",
        ],
        hdl_toplevel=hdl_toplevel,
        always=True,
    )

    runner.test(
        hdl_toplevel=hdl_toplevel, 
        test_module="gpio_tb",
        waves=True,
    )