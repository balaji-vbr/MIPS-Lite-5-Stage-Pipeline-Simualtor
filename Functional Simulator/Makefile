# Makefile
RTL= mips_pkg.sv Design.sv
TB= tb.sv
work= work #library name  
VSIMBATCH= -c -do "run -all; exit"

lib: 
	vlib $(work)

compile:
	vlog  $(RTL) $(TB)
	
sim:
	vsim $(VSIMBATCH) work.tb

		
clean:
	clear

all: clean lib compile sim



