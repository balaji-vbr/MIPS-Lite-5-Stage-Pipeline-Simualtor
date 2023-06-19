`include "mipspkg.sv"

module WriteBack(clock, instruction, memory_read, write_back_data, memory_data_o , cntrl, wb_data ,halt_detected, wb_read);
  import Types::*;
  
  input logic clock;
  input Instruct instruction;
  input logic [REG_WIDTH-1:0] memory_read;
  input logic [DATA-1:0] write_back_data;
  input logic [DATA-1:0] memory_data_o;
  input Control cntrl;
  input logic halt_detected;
  output logic [DATA-1:0] wb_data;
  output logic [REG_WIDTH-1:0] wb_read;
  
  always_comb
  begin 
  if(cntrl.wbMux)
  wb_data = write_back_data;
  else
  wb_data = memory_data_o;
  end

  assign wb_read = memory_read;
  
  always_comb
    begin
      if(halt_detected)
        $finish;  
    end
	
endmodule
