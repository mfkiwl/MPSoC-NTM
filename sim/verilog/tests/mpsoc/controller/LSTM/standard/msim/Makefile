all: build simulate

build:
	if [ ! -e work ]; then vlib work; fi
	vlog -sv -stats=none -f system.vc

simulate:
	vsim -c -do run.do work.ntm_standard_lstm_testbench

clean:
	rm -rf work transcript *.vstf *.wlf
