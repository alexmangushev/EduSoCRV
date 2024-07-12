import cocotb
from pathlib import Path
from cocotb.triggers import Timer, RisingEdge

program_path = Path(__file__).resolve().parent / "program.mem"
memory_path = Path(__file__).resolve().parent / "memory.mem"
file_program = open(program_path)
file_memory = open(memory_path)

memory_list_path = Path(__file__).resolve().parent / "core_state" / "memory_list.mem"
gpr_list_path = Path(__file__).resolve().parent / "core_state" / "gpr_list.mem"

clk_period = 10
program = []
memory = []

#write program to list
for instruction in file_program: 
    hex_instruction = instruction.strip()
    decimal_instruction = int(hex_instruction, 16)
    program.append(decimal_instruction)

#write memory file to main memory
for data in file_memory: 
    hex_data = data.strip()
    decimal_data = int(hex_data, 16)
    memory.append(decimal_data)

#clock generate
async def clk_generate(dut, clk_period):
    for _ in range(100):
        dut.clk.value = 0
        await Timer(clk_period/2, units = 'ns')
        dut.clk.value = 1
        await Timer(clk_period / 2, units='ns')

#reset
async def rst_generate(dut, clk_period):
    dut.rst.value = 0
    await Timer(max(len(program), len(memory)) * clk_period + clk_period/2, units='ns')
    dut.rst.value = 1

#write program to memory fetch
async def memory_fetch_initialization(dut):
    cocotb.start_soon(clk_generate(dut, clk_period))
    cocotb.start_soon(rst_generate(dut, clk_period))
    dut.mem_fetch_write_addr.value = 0
    for instruction in program:
        dut.mem_fetch_write_data.value = instruction
        dut.mem_fetch_write_en.value = 1
        await RisingEdge(dut.clk)
        dut.mem_fetch_write_addr.value = dut.mem_fetch_write_addr.value + 1
    dut.mem_fetch_write_en.value = 0

#write memory file to main memory
async def memory_data_initialization(dut):
    cocotb.start_soon(clk_generate(dut, clk_period))
    cocotb.start_soon(rst_generate(dut, clk_period))
    dut.mem_data_write_addr.value = 0
    for data in memory:
        dut.mem_data_write_data.value = data
        dut.mem_data_write_en.value = 1
        await RisingEdge(dut.clk)
        dut.mem_data_write_addr.value = dut.mem_data_write_addr.value + 1
    dut.mem_data_write_en.value = 0

# create memory list
async def create_memory_list(dut):
    with open(memory_list_path, 'w') as file:
        for i in range(32):
            file.write(str(dut.ram_data.mem[i]) + '\n')

# create gpr list
async def create_gpr_list(dut):
    with open(gpr_list_path, 'w') as file:
        file.write("00000000000000000000000000000000" + '\n')
        for i in range(1, 32):
            file.write(str(dut.core.ID.GPR.register_memory[i]) + '\n')

# full memory initialization
async def full_initialization(dut):
    cocotb.start_soon(clk_generate(dut, clk_period))
    cocotb.start_soon(rst_generate(dut, clk_period))
    cocotb.start_soon(memory_fetch_initialization(dut))
    cocotb.start_soon(memory_data_initialization(dut))

@cocotb.test()
async def system_test(dut):
    await full_initialization(dut)
    await Timer(100 * clk_period, units='ns')
    await create_memory_list(dut)
    await create_gpr_list(dut)