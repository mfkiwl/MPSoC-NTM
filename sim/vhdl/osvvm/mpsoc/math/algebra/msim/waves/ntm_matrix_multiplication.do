onerror {resume}

quietly WaveActivateNextPane {} 0

add wave -noupdate /ntm_algebra_pkg/MONITOR_TEST
add wave -noupdate /ntm_algebra_pkg/MONITOR_CASE

add wave -noupdate -divider {=========================================}
add wave -noupdate -divider {NTM MATRIX MULTIPLICATION TEST}
add wave -noupdate -divider {=========================================}

add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/CLK
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/RST
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/START
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/SIZE_I_IN
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/SIZE_J_IN
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/DATA_IN_I_ENABLE
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/DATA_IN_J_ENABLE
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/DATA_IN
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/DATA_I_ENABLE
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/DATA_J_ENABLE
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/READY
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/DATA_OUT_I_ENABLE
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/DATA_OUT_J_ENABLE
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/DATA_OUT

add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/multiplication_ctrl_fsm_int

add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/index_i_loop
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/index_j_loop

add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/start_scalar_integer_multiplier
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/data_a_in_scalar_integer_multiplier
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/data_b_in_scalar_integer_multiplier
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/ready_scalar_integer_multiplier
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/data_out_scalar_integer_multiplier
add wave -noupdate /ntm_algebra_testbench/ntm_matrix_multiplication_test/matrix_multiplication/overflow_out_scalar_integer_multiplier

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
