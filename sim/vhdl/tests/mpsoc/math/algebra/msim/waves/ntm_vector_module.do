onerror {resume}

quietly WaveActivateNextPane {} 0

add wave -noupdate /ntm_algebra_pkg/MONITOR_TEST
add wave -noupdate /ntm_algebra_pkg/MONITOR_CASE

add wave -noupdate -divider {=========================================}
add wave -noupdate -divider {NTM VECTOR MODULE TEST}
add wave -noupdate -divider {=========================================}

add wave -noupdate /ntm_algebra_testbench/ntm_vector_module_test/vector_module/CLK
add wave -noupdate /ntm_algebra_testbench/ntm_vector_module_test/vector_module/RST
add wave -noupdate /ntm_algebra_testbench/ntm_vector_module_test/vector_module/START
add wave -noupdate /ntm_algebra_testbench/ntm_vector_module_test/vector_module/LENGTH_IN
add wave -noupdate /ntm_algebra_testbench/ntm_vector_module_test/vector_module/DATA_IN_ENABLE
add wave -noupdate /ntm_algebra_testbench/ntm_vector_module_test/vector_module/DATA_IN
add wave -noupdate /ntm_algebra_testbench/ntm_vector_module_test/vector_module/DATA_ENABLE
add wave -noupdate /ntm_algebra_testbench/ntm_vector_module_test/vector_module/READY
add wave -noupdate /ntm_algebra_testbench/ntm_vector_module_test/vector_module/DATA_OUT_ENABLE
add wave -noupdate /ntm_algebra_testbench/ntm_vector_module_test/vector_module/DATA_OUT

add wave -noupdate /ntm_algebra_testbench/ntm_vector_module_test/vector_module/module_ctrl_fsm_int

add wave -noupdate /ntm_algebra_testbench/ntm_vector_module_test/vector_module/index_loop

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
