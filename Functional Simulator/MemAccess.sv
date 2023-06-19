`include "mips_pkg.sv"
module MemAccess(clk, reset, address, write_data, WB_data, cntrl, memory_data_o, write_back_data );
  import mips_pkg::*;
  input logic clk;
  input logic reset;
  input logic[ADDRESS_WIDTH-1 :0 ] address;
  input Control cntrl;
  input logic[DATA-1:0] write_data;
  input logic [DATA-1:0] WB_data;
  output logic[DATA-1:0] memory_data_o;
  
  logic [DATA-1:0] data_o;
  output logic [DATA-1:0] write_back_data;
  
  parameter FILE_NAME = "ece586_sample_memory_image.mem";
    
  logic [MEMWIDTH-1:0] data_memory [MEMDEPTH-1:0];
  
  logic [7:0] data [3:0];
  logic [INSTRUCTION_WIDTH-1:0] temp_memory [(MEMDEPTH/BPI)-1:0];
  
  assign write_back_data = WB_data;
  assign memory_data_o = data_o;
  
   initial 
    begin
      $readmemh(FILE_NAME,temp_memory);
      
    end

    always_comb
    begin
      {>>MEMWIDTH{data[0 +: BPI]}} = write_data;
    end

    always_ff@(posedge clk)
    begin
      if(reset)
        begin
          for (int i=0; i< MEMDEPTH ;i++);
          begin
            data_memory ={>>MEMWIDTH{temp_memory}};
          end
          
        end
        
      if(cntrl.MemWriteEnable)
        begin
        data_memory[address +: BPI] <= data;
          MemWriteStatus[address]='1;
        end
        
    end

    always_comb
    begin
      data_o = {>>MEMWIDTH{data_memory[address +: BPI]}};
    end
endmodule 
