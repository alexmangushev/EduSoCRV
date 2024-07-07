vlib work
vsim -t 1ns soc_riscv_core_tb
add wave /soc_riscv_core_tb/dut/*
view structure
view signals
run -all
wave zoom full