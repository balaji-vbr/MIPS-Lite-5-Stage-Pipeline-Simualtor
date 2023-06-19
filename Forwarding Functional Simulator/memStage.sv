`include "mipspkg.sv"

module MemAccess(clk,rst,instruction, address, data_write, wb_data, cntrl, memory_data_o, write_back_data, instrMem );
  import TYPES::*;
  input logic clk;
  input logic rst;
  input Instruct instruction;
  input logic[ADDRESS_WIDTH-1 :0 ] address;
  input Control cntrl;
  input logic[DATA-1:0] data_write;
  input logic [DATA-1:0]wb_data;
  output logic[DATA-1:0] memory_data_o;
  output Instruct instrMem;
  output logic [DATA-1:0] write_back_data;

  parameter FILENAME = "ece586_sample_memory_image.mem";
  
  logic [DATA-1:0] dataOut;
  logic [MEM_WIDTH-1:0] dataMem [MEM_DEPTH-1:0];
  logic [7:0] data [3:0];
  logic [INSTRUCTION_WIDTH-1:0] tempMem [(MEM_DEPTH/BPI)-1:0];

  assign instrMem = instruction;
  assign write_back_data = wb_data;
  assign memory_data_o = dataOut;

  initial 
    begin
      $readmemh(FILENAME,tempMem);
  end

  always_ff@(posedge clk)
    begin
      if(rst)
        begin
          for (int i=0; i< MEM_DEPTH ;i++);
          begin
            dataMem ={>>MEM_WIDTH{tempMem}};
          end
      end
        
      if(cntrl.memWriteEnable)
        begin
        dataMem[address +: BPI] <= data;
          memWriteStatus[address]='1;
      end
  end

  always_comb
    begin
      {>>MEM_WIDTH{data[0 +: BPI]}} = data_write;
  end

  always_comb
    begin
      dataOut = {>>MEM_WIDTH{dataMem[address +: BPI]}};
  end  
   
endmodule 