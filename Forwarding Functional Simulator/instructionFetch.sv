`include "mipspkg.sv"

module InstrFetch(clk,rst, halt_signal, hazard_detected,branch_addr, branch_taken, pc_added4,instruction,pc);
  import TYPES::*;
  
  input logic clk;
  input logic rst;
  input logic halt_signal;
  input logic [ADDRESS_WIDTH-1:0] branch_addr;
  input logic branch_taken;
  input logic hazard_detected;
  output Instruct instruction;
  output logic [ADDRESS_WIDTH-1:0] pc;
  output logic [ADDRESS_WIDTH-1:0] pc_added4;
  
  logic [ADDRESS_WIDTH-1:0] mux_branching_o;
  logic [ADDRESS_WIDTH-1:0] pcNext; 
  logic invalid_addr;
  logic [MEM_WIDTH-1:0] instructMem [MEM_DEPTH-1:0];
  
  parameter FILENAME = "ece586_sample_memory_image.mem";
  
  assign {invalid_addr,pc_added4} = pc + 32'h4;
  assign mux_branching_o = (branch_taken) ? branch_addr : pc_added4;

  initial 
    begin
      logic [INSTRUCTION_WIDTH-1:0] tempMem [(MEM_DEPTH/BPI)-1:0];
      $readmemh(FILENAME,tempMem);
      instructMem ={>>MEM_WIDTH{tempMem}};
  end

  always_ff@(posedge clk, posedge rst)
    begin
      if(rst)
        pc <= 0;
      else if(hazard_detected!='1 && halt_signal!='1)
        pc <= mux_branching_o;
  end

  
  generate
    always_comb begin
      if (pc[$clog2(BPI)-1:0]==0) begin
        instruction = {>>MEM_WIDTH{instructMem[pc +: BPI]}};
      end
      else begin
        instruction = 'hDEADBEEF;
      end
    end
  endgenerate  
  
endmodule