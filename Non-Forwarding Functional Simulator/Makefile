# Makefile
RTL= mipspkg.sv design.sv
TB= testbench.sv
work= work #library name  
VSIMBATCH= -c -do "run -all; exit"

lib: 
	vlib $(work)

compile:
	vlog  $(RTL) $(TB)
	
sim:
	vsim $(VSIMBATCH) work.top

		
clean:
	clear

all: clean lib compile sim



