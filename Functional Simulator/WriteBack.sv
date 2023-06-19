`include "mips_pkg.sv"
module WriteBack(write_back_data, memory_data_o , cntrl, WB_data);
  import mips_pkg::*;
  input logic [DATA-1:0] write_back_data;
  input logic [DATA-1:0] memory_data_o;
  input Control cntrl;
  output logic [DATA-1:0] WB_data;
  
  assign WB_data = (cntrl.WBMux) ? write_back_data : memory_data_o;
  
endmodule