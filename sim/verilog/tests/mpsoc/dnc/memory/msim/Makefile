all: build simulate

build:
	if [ ! -e work ]; then vlib work; fi
	vlog -sv -stats=none -f system.vc

simulate:
	vsim -c -do run.do work.dnc_memory_testbench

clean:
	rm -rf work transcript *.vstf *.wlf
