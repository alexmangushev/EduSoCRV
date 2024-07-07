import cocotb
from pathlib import Path
from cocotb.triggers import Timer, RisingEdge

program_path = Path(__file__).resolve().parent / "program.txt"
file = open(program_path)
clk_period = 10
program = []

for instruction in file: #write program to list
    hex_instruction = instruction.strip()
    decimal_instruction = int(hex_instruction, 16)
    program.append(decimal_instruction)

#clock generate
async def clk_generate(dut, clk_period):
    for i in range(100):
        dut.clk.value = 0
        await Timer(clk_period/2, units = 'ns')
        dut.clk.value = 1
        await Timer(clk_period / 2, units='ns')

#reset
async def rst_generate(dut, clk_period):
    dut.rst.value = 0
    await Timer(len(program) * clk_period + clk_period/2, units='ns')
    dut.rst.value = 1

#write program to memory
@cocotb.test()
async def memory_initialization(dut):
    cocotb.start_soon(clk_generate(dut, clk_period))
    cocotb.start_soon(rst_generate(dut, clk_period))
    dut.mem_write_addr.value = 0
    for instruction in program:
        dut.mem_write_data.value = instruction
        dut.mem_write_en.value = 1
        await RisingEdge(dut.clk)
        dut.mem_write_addr.value = dut.mem_write_addr.value + 1
    dut.mem_write_en.value = 0
    await Timer(clk_period * 100, units='ns')
