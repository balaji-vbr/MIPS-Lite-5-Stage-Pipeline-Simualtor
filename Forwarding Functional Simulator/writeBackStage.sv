`include "mipspkg.sv"
module WriteBack(clk,write_back_data, mem_data_o , cntrl, wb_data ,halt_signal);
  import TYPES::*;

  input logic clk;
  input logic [DATA-1:0] write_back_data;
  input logic [DATA-1:0] mem_data_o;
  input Control cntrl;
  input logic halt_signal;
  output logic [DATA-1:0] wb_data;
  
  assign wb_data = (cntrl.wbMux) ? write_back_data:mem_data_o;
  
  always_comb
    begin
      if(halt_signal)
        $finish;
  end

endmodule