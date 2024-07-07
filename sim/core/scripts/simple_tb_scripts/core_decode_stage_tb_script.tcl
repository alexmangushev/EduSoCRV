vlib work
vsim -t 1ns core_decode_stage_tb
add wave /core_decode_stage_tb/dut/*
view structure
view signals
run -all
wave zoom full