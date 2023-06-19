`include "mips_pkg.sv"
module InstrDecode(clk, reset, write_en, instruction, write_data, cntrl, read_data_1, read_data_2, imm_data);
import mips_pkg::*;

input Instr instruction;
input logic clk;
input logic reset;
input logic [DATA-1:0] write_data;
input logic write_en;
output Control cntrl;
output logic [DATA-1:0] imm_data;
output logic [DATA-1:0] read_data_1;
output logic [DATA-1:0] read_data_2;
  
logic [REGISTER_WIDTH-1:0] rs1, rs2, rd;
logic [DATA-1:0] RegisterFile [REGISTER_NUMBER-1:0];
    
assign read_data_1 = (rs1==0) ? '0 : RegisterFile[rs1];
assign read_data_2 = (rs2==0) ? '0 : RegisterFile[rs2];

always_ff@(posedge clk)
    begin
      if(reset)
        begin
          for(int i=0; i < REGISTER_NUMBER; i++)
            begin
              RegisterFile[i] <= '0;
            end
        end
      else if(cntrl.RegWriteEnable)
        RegisterFile[rd] <= write_data;
      else
        begin
        RegisterFile[rd] <= RegisterFile[rd];
        end
    end

always_comb
    begin
      unique case(instruction.opcode)
        6'b000001: imm_data = {{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}}, instruction.Type.I.imm};
        6'b000011: imm_data = {{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}}, instruction.Type.I.imm};
        6'b000101: imm_data = {{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}}, instruction.Type.I.imm};
        6'b000111: imm_data = {{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}}, instruction.Type.I.imm};
        6'b001001: imm_data = {{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}}, instruction.Type.I.imm};
        6'b001011: imm_data = {{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}}, instruction.Type.I.imm};
        6'b001100: imm_data = {{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}}, instruction.Type.I.imm};
        6'b001101: imm_data = {{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}}, instruction.Type.I.imm};
        6'b001110: imm_data = {{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}}, instruction.Type.I.imm};
        6'b001111: imm_data = {{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}}, instruction.Type.I.imm};
        default : imm_data = 'x;
      endcase
    end
  

always_comb
    begin
      case(instruction.opcode)
        6'h00 : 
	begin				//add operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='1;
          cntrl.WriteBack = '1;
          cntrl.WBMux = '1;
          cntrl.srcReg2 = '1;
          cntrl.jump = '0;
          cntrl.ALU_op=3'b000;
        end
        
	6'h01 : 
	begin				//addi operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='1;
          cntrl.WriteBack = '1;
          cntrl.WBMux = '1;
          cntrl.srcReg2 = '0;
          cntrl.jump = '0;
          cntrl.ALU_op =3'b000;
        end

        6'h02 : 
	begin				//sub operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='1;
          cntrl.WriteBack = '1;
          cntrl.WBMux = '1;
          cntrl.srcReg2 = '1;
          cntrl.jump = '0;
          cntrl.ALU_op = 3'b001;
        end
        
	6'h03 :
	begin				//subi operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='1;
          cntrl.WriteBack = '1;
          cntrl.WBMux = '1;
          cntrl.srcReg2 = '0;
          cntrl.jump = '0;
          cntrl.ALU_op = 3'b001;
        end
        
	6'h04 :
	begin				//mul operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='1;
          cntrl.WriteBack = '1;
          cntrl.WBMux = '1;
          cntrl.srcReg2 = '1;
          cntrl.jump = '0;
          cntrl.ALU_op=3'b010;
        end

        6'h05 : 
	begin				//muli operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='1;
          cntrl.WriteBack = '1;
          cntrl.WBMux = '1;
          cntrl.srcReg2 = '0;
          cntrl.jump = '0;
          cntrl.ALU_op =3'b010;
          end
       
	6'h06 : 
	begin				//or operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='1;
          cntrl.WriteBack = '1;
          cntrl.WBMux= '1;
          cntrl.srcReg2 = '1;
          cntrl.jump = '0;
          cntrl.ALU_op= 3'b011;
        end
        
	6'h07 : 
	begin				//ori operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='1;
          cntrl.WriteBack = '1;
          cntrl.WBMux = '1;
          cntrl.srcReg2 = '0;
          cntrl.jump = '0;
          cntrl.ALU_op = 3'b011;
          end

	6'h08 : 
	begin				//and operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='1;
          cntrl.WriteBack = '1;
          cntrl.WBMux = '1;
          cntrl.srcReg2 = '1;
          cntrl.jump = '0;
          cntrl.ALU_op = 3'b100;
        end

        6'h09 :
	begin				//andi operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='1;
          cntrl.WriteBack = '1;
          cntrl.WBMux = '1;
          cntrl.srcReg2 = '0;
          cntrl.jump = '0;
          cntrl.ALU_op = 3'b100;
        end

	6'h0A : 
	begin				//xor operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='1;
          cntrl.WriteBack = '1;
          cntrl.WBMux = '1;
          cntrl.srcReg2 = '1;
          cntrl.jump = '0;
          cntrl.ALU_op = 3'b101;
        end

	6'h0B : 
	begin				//xori operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='1;
          cntrl.WriteBack = '1;
          cntrl.WBMux = '1;
          cntrl.srcReg2 = '0;
          cntrl.jump = '0;
          cntrl.ALU_op = 3'b101;
        end

        6'h0C : 
	begin				//ldw operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='1;
          cntrl.WriteBack = '1;
          cntrl.WBMux= '0;
          cntrl.srcReg2 = '0;
          cntrl.ALU_op = 3'b000;
        end

        6'h0D : 
	begin				//stw operation
          cntrl.ALU_op = 3'b000;
          cntrl.MemWriteEnable ='1;
          cntrl.srcReg2 = '0;
          cntrl.jump = '0;
          cntrl.RegWriteEnable='0;
        end

        6'h0E : 
	begin				//bz operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='0;
          cntrl.srcReg2 = '0;
          cntrl.jump = '0;
          cntrl.ALU_op = 3'b110;
        end

        6'h0F : 
	begin				// BEQ operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='0;
          cntrl.srcReg2 = '1;
          cntrl.jump = '0;
          cntrl.ALU_op = 3'b111;
        end

        6'h10 : 
	begin				//JR operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='0;
          cntrl.srcReg2 = '0;
          cntrl.jump = '1;
          cntrl.ALU_op = 3'b000;
        end

        6'h11 : 
	begin				//HALT operation
          cntrl.MemWriteEnable ='0;
          cntrl.RegWriteEnable='0;
                   
          cntrl.srcReg2 = '1;
          cntrl.jump = '0;
          cntrl.ALU_op = 3'b000;
        end

	default: cntrl.RegWriteEnable='0;
        endcase
end


always_comb
    begin
      
      unique case(instruction.opcode) 
        6'b000000: 
	begin				//add operation
          CountInstruction();
          CountArithmeticInstruction();
          rs1 = instruction.Type.R.rs;
          rs2 = instruction.Type.R.rt;
          rd = instruction.Type.R.rd;
        end

        6'b000001: 
	begin				//addi operation
          CountInstruction();
          CountArithmeticInstruction();
          rs1 = instruction.Type.I.rs;
          rd =  instruction.Type.I.rt;
        end

        6'b000010: 
	begin				//sub operation
          CountInstruction();
          CountArithmeticInstruction();
          rs1 = instruction.Type.R.rs;
          rs2 = instruction.Type.R.rt;
          rd  = instruction.Type.R.rd;
        end

        6'b000011: 
	begin				//subi operation
          CountInstruction();
          CountArithmeticInstruction();
          rs1 = instruction.Type.I.rs;
          rd  = instruction.Type.I.rt;
        end

        6'b000100: 
	begin				//Mul operation
          CountInstruction();
          CountArithmeticInstruction();
          rs1 = instruction.Type.R.rs;
          rs2 = instruction.Type.R.rt;
          rd = instruction.Type.R.rd;
        end

        6'b000101: 
	begin				//Muli operation
          CountInstruction();
          CountArithmeticInstruction();
          rs1 = instruction.Type.I.rs;
          rd = instruction.Type.I.rt;
        end

        6'b000110: 
	begin				//or operation
          CountInstruction();
          CountLogicalInstruction();
          rs1 = instruction.Type.R.rs;
          rs2 = instruction.Type.R.rt;
          rd = instruction.Type.R.rd;
        end

        6'b000111: 
	begin				//ori operation
          CountInstruction();
          CountLogicalInstruction();
          rs1 = instruction.Type.I.rs;
          rd = instruction.Type.I.rt;
        end

        6'b001000: 
	begin				//and operation
          CountInstruction();
          CountLogicalInstruction();
          rs1 = instruction.Type.R.rs;
          rs2 = instruction.Type.R.rt;
          rd = instruction.Type.R.rd;
        end

        6'b001001: 
	begin				//andi operation
          CountInstruction();
          CountLogicalInstruction();
          rs1 = instruction.Type.I.rs;
          rd = instruction.Type.I.rt;
        end

        6'b001010: 
	begin				//xor operation
          CountInstruction();
          CountLogicalInstruction();
          rs1 = instruction.Type.R.rs;
          rs2 = instruction.Type.R.rt;
          rd = instruction.Type.R.rd;
        end

        6'b001011: 
	begin				//xori operation
          CountInstruction();
          CountLogicalInstruction();
          rs1 = instruction.Type.I.rs;
          rd = instruction.Type.I.rt;
        end

        6'b001100: 
	begin				//ldw operation
          CountInstruction(); 
          CountMemoryInstruction();
          rs1 = instruction.Type.I.rs;
          rd= instruction.Type.I.rt;
        end

        6'b001101: 
	begin				//stw operation
          CountInstruction();
          CountMemoryInstruction();
          rs1 = instruction.Type.I.rs;
          rs2 = instruction.Type.I.rt;
        end

        6'b001110: 
	begin				//BZ operation
          CountInstruction();
          CountBranchInstruction();
          rs1 = instruction.Type.I.rs;
        end

        6'b001111: 
	begin				//BEQ operation
          CountInstruction();
          CountBranchInstruction();
          rs1 =  instruction.Type.I.rs;
          rs2 = instruction.Type.I.rt;
        end

        6'b010000: 
	begin				//JR operation
          CountInstruction();
          CountBranchInstruction();
          rs1 = instruction.Type.I.rs;
        end

        6'b010001: 
	begin				//HALT operation
          CountInstruction();
          CountBranchInstruction();
          $finish;
        end
        default: begin
          rs1 = 'x;
          rs2 = 'x;
          rd = 'x;
        end

      endcase
    end
endmodule
