from cocotb.runner import get_runner
from pathlib import Path
import os

if __name__ == "__main__":
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "questa")
    gui = os.getenv("GUI", "True")

    proj_path = Path(__file__).resolve().parent.parent.parent.parent

    verilog_sources = []
    vhdl_sources = []

    if hdl_toplevel_lang == "verilog":
        verilog_sources = [proj_path / "rtl" / "core" / "packages" / "alu_control_pkg.sv",
                           proj_path / "rtl" / "core" / "packages" / "shift_control_pkg.sv",
                           proj_path / "rtl" / "core" / "packages" / "core_pkg.sv",
                           proj_path / "rtl" / "core" / "packages" / "comparator_control_pkg.sv",
                           proj_path / "rtl" / "core" / "packages" / "imm_types_pkg.sv",
                           proj_path / "rtl" / "core" / "soc_riscv_core.sv",
                           proj_path / "sim" / "core" / "try_it" / "main_ram_fetch.sv",
                           proj_path / "rtl" / "core" / "core_decode_stage" / "core_decode_stage.sv",
                           proj_path / "rtl" / "core" / "core_decode_stage" / "instruction_decode_unit.sv",
                           proj_path / "rtl" / "core" / "core_decode_stage" / "core_register_file.sv",
                           proj_path / "rtl" / "core" / "core_execution_stage" / "core_alu.sv",
                           proj_path / "rtl" / "core" / "core_execution_stage" / "core_comparator.sv",
                           proj_path / "rtl" / "core" / "core_execution_stage" / "core_shift.sv",
                           proj_path / "rtl" / "core" / "core_execution_stage" / "core_execution_stage.sv",
                           proj_path / "rtl" / "core" / "core_fetch_stage" / "core_fetch_stage.sv",
                           proj_path / "rtl" / "core" / "core_fetch_stage" / "instruction_fetch_unit.sv",
                           proj_path / "rtl" / "core" / "core_control_unit.sv",
                           proj_path / "rtl" / "core" / "core_memory_stage" / "load_store_unit.sv",
                           proj_path / "sim" / "core" / "try_it" / "soc_riscv_core_test.sv"]

    runner = get_runner(sim)

    runner.build(
    verilog_sources = verilog_sources,
    vhdl_sources = vhdl_sources,
    includes = [proj_path / "packages"],
    hdl_toplevel ="soc_riscv_core_test",
    always = True,
    )

    runner.test(
    hdl_toplevel = "soc_riscv_core_test",
    test_module = "soc_riscv_core_test",
    waves = True,
    gui = gui,
    )
