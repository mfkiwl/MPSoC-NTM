onerror {resume}

quietly WaveActivateNextPane {} 0

add wave -noupdate /ntm_calculus_pkg/MONITOR_TEST
add wave -noupdate /ntm_calculus_pkg/MONITOR_CASE

add wave -noupdate -divider {=========================================}
add wave -noupdate -divider {NTM VECTOR INTEGRATION TEST}
add wave -noupdate -divider {=========================================}

add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/CLK
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/RST
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/START
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/SIZE_IN
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/LENGTH_IN
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/DATA_IN_ENABLE
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/DATA_IN
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/DATA_ENABLE
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/READY
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/DATA_OUT_ENABLE
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/DATA_OUT

add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/integration_ctrl_fsm_int

add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/index_loop

add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/start_scalar_float_adder
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/operation_scalar_float_adder
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/data_a_in_scalar_float_adder
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/data_b_in_scalar_float_adder
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/ready_scalar_float_adder
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/data_out_scalar_float_adder
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/overflow_out_scalar_float_adder

add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/start_scalar_float_multiplier
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/data_a_in_scalar_float_multiplier
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/data_b_in_scalar_float_multiplier
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/ready_scalar_float_multiplier
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/data_out_scalar_float_multiplier
add wave -noupdate /ntm_calculus_testbench/ntm_vector_integration_test/vector_integration/overflow_out_scalar_float_multiplier

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1042309203 ps} 0} {{Cursor 2} {7446987402 ps} 0}
configure wave -namecolwidth 305
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {1134027470 ps} {1150214364 ps}
