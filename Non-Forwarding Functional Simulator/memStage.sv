`include "mipspkg.sv"

module MemAccess(clock,rst,address, writeData, wbData, cntrl, memDataOut, writeBackData );
  import Types::*;
  input logic clock;
  input logic rst;
  input logic[ADD_WIDTH-1 :0 ] address;
  input Control cntrl;
  input logic[DATA-1:0] writeData;
  input logic [DATA-1:0]wbData;
  output logic[DATA-1:0] memDataOut;
  output logic [DATA-1:0] writeBackData;
  
  parameter FILENAME = "ece586_sample_memory_image.mem";
  
  logic [DATA-1:0] dataOut;
  logic [MEM_WIDTH-1:0] dataMem [MEM_DEPTH-1:0];
  logic [7:0] data [3:0];
  logic [INSTRUCTION_WIDTH-1:0] tempMem [(MEM_DEPTH/BPI)-1:0];

  always_comb
  begin
  writeBackData = wbData;
  memDataOut = dataOut;
  end
	
  initial begin
      $readmemh(FILENAME,tempMem);
  end

  always_ff@(posedge clock)
    begin
		if(rst)
			begin
				for (int i=0; i< MEM_DEPTH ;i++);
				begin
					dataMem ={>>MEM_WIDTH{tempMem}};
				end
		end
        
		if(cntrl.memWriteEnable)
			dataMem[address +: BPI] <= data;
    end
	
	
	
	assign  {>>MEM_WIDTH{data[0 +: BPI]}} = writeData;  
    
	
    
	assign	dataOut = {>>MEM_WIDTH{dataMem[address +: BPI]}};
     
   
endmodule 
