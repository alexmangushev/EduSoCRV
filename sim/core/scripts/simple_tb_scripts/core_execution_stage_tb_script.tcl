vlib work
vsim -t 1ns core_execution_stage_tb
add wave /core_execution_stage_tb/dut/*
view structure
view signals
run -all
wave zoom full