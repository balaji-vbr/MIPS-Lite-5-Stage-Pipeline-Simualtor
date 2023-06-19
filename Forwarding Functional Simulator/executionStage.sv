`include "mipspkg.sv"

module Execute(clk, instruction, read_data1, read_data2, imm_o, pc_added4 ,cntrl,alu_o,addr_new, branch_taken, write_data, Forward_1, Forward_2,mem_Forward_1, mem_Forward_2,wb_Forward_1, wb_Forward_2, mem_data_o,wb_data, instr);
  import TYPES::*;

  input logic clk;
  input Instruct instruction;
  input logic [DATA-1:0] read_data1;
  input logic [DATA-1:0] read_data2;
  input logic [DATA-1:0] imm_o;
  input logic [ADDRESS_WIDTH-1:0] pc_added4;
  input Control cntrl;
  input logic Forward_1, Forward_2, mem_Forward_1, mem_Forward_2,wb_Forward_1,wb_Forward_2;
  input logic[DATA-1:0] mem_data_o;
  input logic [DATA-1:0] wb_data;
  output logic branch_taken;
  output logic [DATA-1:0] alu_o;
  output logic [DATA-1:0] addr_new;
  output logic [DATA-1:0] write_data;
  output Instruct instr;
  
  logic [DATA-1:0] branch_addr;
  logic zero;
  logic [4:0] testrd;
  
  logic [DATA-1:0] ALU_IN_1;
  logic invalid_addr;
  logic [DATA-1:0] ALU_IN_2;
  logic [DATA-1:0] Shift_Left_Imm;
  logic [DATA-1:0] Src1,Src2,EX1_Forward,EX2_Forward, Mem1_Forward, Mem2_Forward, WB1_Forward, WB2_Forward;
  
  Instruct testInstr;

  assign write_data = read_data2;
  assign testrd = Read_Buffer[0].rd;
  assign testInstr = Instr_Buffer[0].instruction;
  assign instr = instruction;
  assign ALU_IN_2 = (cntrl.rs2) ? read_data2 : imm_o;
  assign Src1 = (Forward_1) ? Execution_Buffer.aluOut : read_data1;
  assign Mem1_Forward = (mem_Forward_1) ? mem_data_o : Src1;
  assign WB1_Forward = (wb_Forward_1) ? wb_data : Mem1_Forward;
  assign {invalid_addr,branch_addr} = $signed(pc_added4) + $signed(imm_o<<2);
  assign addr_new = (cntrl.jump) ? read_data1 : branch_addr;
  assign Src2 = (Forward_2) ? Execution_Buffer.aluOut : ALU_IN_2;
  assign Mem2_Forward = (mem_Forward_2) ? mem_data_o : Src2;
  assign WB2_Forward = (wb_Forward_2) ? wb_data : Mem2_Forward;

  always_comb
    begin
      //cntrl.jump ='0;
      branch_taken ='0;
      zero= '0;
      case(cntrl.aluop)
        3'b000: begin
          alu_o = $signed(read_data1) + $signed(ALU_IN_2);
          if(cntrl.jump)
            branch_taken='1;
        end
        3'b001:begin
          alu_o = $signed(read_data1) - $signed(ALU_IN_2);
        end
        3'b010: begin
          alu_o = $signed(read_data1)* $signed(ALU_IN_2) ;
        end
        3'b011: begin
          alu_o = read_data1 | ALU_IN_2;
        end
        3'b100: begin
          alu_o =  read_data1 & ALU_IN_2;
        end
        3'b101: begin
          alu_o = read_data1 ^ ALU_IN_2 ;
        end
        3'b110: begin
          alu_o = (read_data1=='0) ? 1 : '0;
          branch_taken = (read_data1=='0) ? 1 : '0;
        end
        3'b111 : begin
          alu_o = (read_data1==ALU_IN_2) ? 1 : '0;
          branch_taken = (read_data1==ALU_IN_2) ? 1 : '0;
        end
        default : begin
          branch_taken='0;
          cntrl.jump ='0;
        end
      endcase
    end
endmodule