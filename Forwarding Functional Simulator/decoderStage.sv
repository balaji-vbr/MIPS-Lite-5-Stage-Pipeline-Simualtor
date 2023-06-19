`include "mipspkg.sv"

module InstrDecode(clk,rst,branch_taken,pc,inputCntrl,inputRd, en_write, instruction, data_write, cntrl, imm_o, read_data1, read_data2,pcOut, rs1,rs2,rd, hazard_detected,halt_signal, Forward_1, Forward_2,mem_Forward_1, mem_Forward_2,wb_Forward_1, wb_Forward_2,dec_instr);
  import TYPES::*;
  
  input Instruct instruction;
  input logic clk;
  input logic rst;
  input logic branch_taken;
  input logic [ADDRESS_WIDTH-1:0] pc;
  input logic [DATA-1:0] data_write;
  input logic en_write;
  output logic [REGISTER_WIDTH-1:0] rs1, rs2;
  output logic hazard_detected;
  output logic halt_signal;
  output logic Forward_1, Forward_2, mem_Forward_1, mem_Forward_2, wb_Forward_1, wb_Forward_2;
  output Instruct dec_instr;
  
  input Control inputCntrl;
  input logic [REGISTER_WIDTH-1:0] inputRd;
  output logic [DATA-1:0] imm_o;
  output logic [DATA-1:0] read_data1;
  output logic [DATA-1:0] read_data2;
  output logic [ADDRESS_WIDTH-1:0] pcOut;
  output Control cntrl;
  output logic [REGISTER_WIDTH-1:0] rd;
  
  
  logic [1:0] count;
  logic hazard;
  logic [1:0] wait_count;
  logic set;
	logic[DATA-1:0] registerFile [REGISTER_NUMBER-1:0];

  assign pcOut = pc;
  assign dec_instr = instruction;

  always_ff@(posedge clk)
    begin
      if(rst)
        begin
          for(int i=0; i < REGISTER_NUMBER; i++)
            begin
             registerFile[i] <= '0;
          end
      end
      else if(inputCntrl.regWrite)
        begin
        registerFile[inputRd] <= data_write;
      end
      else
        begin
          registerFile[inputRd] <= registerFile[inputRd];
      end
  end

  always_ff@(negedge clk)
    begin
      read_data1 <= registerFile[rs1];
      read_data2 <= registerFile[rs2];
  end

  always_ff@(posedge clk)
  begin
    if(hazard && set=='0)
      begin
      wait_count <='0;
      set <='1;
      end
    else if( set=='1 && wait_count!==count)
      begin
        wait_count <= wait_count + 1'b1;
      end
    else 
      begin
      set<=0;
      wait_count <='0;
    end

    if(set=='1 && wait_count!==count && (Forward_1 =='0 && Forward_2 =='0) && hazard_detected=='1)
      begin
        stalls <= stalls +1;
      end
  end

  always_comb
    begin
      if(Forward_1=='0 && Forward_2=='0 && hazard =='1)
        begin
          Data_Hazards = Data_Hazards + 1;
        end
    end

  always_comb
    begin
      if(!branch_taken)
        begin
        unique case(instruction.opcode) 
          6'b000000: begin
            
            if(!halt_signal)
            begin
              Count_Instruction();
              Count_Arithmetic_Instruction();
            end
            rs1 = instruction.Type.R.rs;
            rs2 = instruction.Type.R.rt;
            rd = instruction.Type.R.rd;
          end
          6'b000001: begin
          
            if(!halt_signal)
            begin
              Count_Instruction();
              Count_Arithmetic_Instruction();
            end
            rs1 = instruction.Type.I.rs;
            rs2 = 'x;
            rd =  instruction.Type.I.rt;
          end
          6'b000010: begin
          
            if(!halt_signal)
            begin
              Count_Instruction();
              Count_Arithmetic_Instruction();
            end
            rs1 = instruction.Type.R.rs;
            rs2 = instruction.Type.R.rt;
            rd  = instruction.Type.R.rd;
          end

          6'b000011: begin
          
            if(!halt_signal)
            begin
              Count_Instruction();
              Count_Arithmetic_Instruction();
            end
            rs1 = instruction.Type.I.rs;
            rs2 ='x;
            rd  = instruction.Type.I.rt;
          end

          6'b000100: begin
          
            if(!halt_signal)
            begin
              Count_Instruction();
              Count_Arithmetic_Instruction();
            end
            rs1 = instruction.Type.R.rs;
            rs2 = instruction.Type.R.rt;
            rd = instruction.Type.R.rd;
          end

          6'b000101: begin
          
            if(!halt_signal)
            begin
              Count_Instruction();
              Count_Arithmetic_Instruction();
            end
            rs1 = instruction.Type.I.rs;
            rs2 = 'x;
            rd = instruction.Type.I.rt;
          end
          6'b000110: begin
          
            if(!halt_signal)
            begin
              Count_Instruction();
              Count_Logical_Instruction();
            end
            rs1 = instruction.Type.R.rs;
            rs2 = instruction.Type.R.rt;
            rd = instruction.Type.R.rd;
          end
          6'b000111: begin
          
            if(!halt_signal)
            begin
              Count_Instruction();
              Count_Logical_Instruction();
            end
            rs1 = instruction.Type.I.rs;
            rs2 = 'x;
            rd = instruction.Type.I.rt;
          end
          6'b001000: begin
          
            if(!halt_signal)
            begin
              Count_Instruction();
              Count_Logical_Instruction();
            end
            rs1 = instruction.Type.R.rs;
            rs2 = instruction.Type.R.rt;
            rd = instruction.Type.R.rd;
          end
          6'b001001: begin
          
            if(!halt_signal)
            begin
              Count_Instruction();
              Count_Logical_Instruction();
            end
            rs1 = instruction.Type.I.rs;
            rs2='x;
            rd = instruction.Type.I.rt;
          end
          6'b001010: begin
          
            if(!halt_signal)
            begin
              Count_Instruction();
              Count_Logical_Instruction();
            end
            rs1 = instruction.Type.R.rs;
            rs2 = instruction.Type.R.rt;
            rd = instruction.Type.R.rd;
          end
          6'b001011: begin
          
            if(!halt_signal)
            begin
              Count_Instruction();
              Count_Logical_Instruction();
            end
            rs1 = instruction.Type.I.rs;
            rs2 = 'x;
            rd = instruction.Type.I.rt;
          end
          6'b001100: begin
          
            if(!halt_signal)
            begin
              Count_Instruction();
              Count_Memory_Instruction();
            end
            rs1 = instruction.Type.I.rs;
            rs2 = 'x;
            rd = instruction.Type.I.rt;
          end
          6'b001101: begin
          
            if(!halt_signal)
            begin
              Count_Instruction();
              Count_Memory_Instruction();
            end
            rs1 = instruction.Type.I.rs;
            rs2 = instruction.Type.I.rt;
            rd='x;
          end
          6'b001110: begin
          
            if(!halt_signal)
            begin
              Count_Instruction();
              Count_Branch_Instruction();
            end
            rs1 = instruction.Type.I.rs;
            rs2 = 'x;
            rd='x;
          end
          6'b001111: begin
          
            if(!halt_signal)
            begin
              Count_Instruction();
              Count_Branch_Instruction();
            end
            rs1 =  instruction.Type.I.rs;
            rs2 = instruction.Type.I.rt;
            rd='x;
          end
          6'b010000: begin
          
            if(!halt_signal)
              begin
              Count_Instruction();
              Count_Branch_Instruction();
            end
            rs1 = instruction.Type.I.rs;
            rs2 = 'x;
            rd='x;
          end
          6'b010001: begin
          
            if(!halt_signal)
              begin
              Count_Instruction();
              Count_Branch_Instruction();
              rs1='x;
              rs2 ='x;
              rd='x;
            end
          
          end
          default: begin
            rs1 = 'x;
            rs2 = 'x;
            rd = 'x;
          end
        endcase
      end
      else 
        begin
          rs1 = 'x;
          rs2 = 'x;
          rd = 'x;
      end
  end
  
  always_comb
    begin
     
     
      case(instruction.opcode)
        6'h00 : begin
          
          cntrl.memWriteEnable ='0;
          cntrl.regWrite='1;
          cntrl.writeBack = '1;
          cntrl.wbMux = '1;
          cntrl.rs2 = '1;
          cntrl.jump = '0;
          cntrl.aluop=3'b000;
          
        end
        6'h01 : begin
          
          cntrl.memWriteEnable ='0;
          cntrl.regWrite='1;
          cntrl.writeBack = '1;
          cntrl.wbMux = '1;
          cntrl.rs2 = '0;
          cntrl.jump = '0;
          cntrl.aluop =3'b000;
        end
        6'h02 : begin
          
          cntrl.memWriteEnable ='0;
          cntrl.regWrite='1;
          cntrl.writeBack = '1;
          cntrl.wbMux = '1;
          cntrl.rs2 = '1;
          cntrl.jump = '0;
          cntrl.aluop = 3'b001;
        end
        6'h03 : begin
          
          cntrl.memWriteEnable ='0;
          cntrl.regWrite='1;
          cntrl.writeBack = '1;
          cntrl.wbMux = '1;
          cntrl.rs2 = '0;
          cntrl.jump = '0;
          cntrl.aluop = 3'b001;
        end
          6'h04 :begin
            
            cntrl.memWriteEnable ='0;
            cntrl.regWrite='1;
            cntrl.writeBack = '1;
            cntrl.wbMux = '1;
            cntrl.rs2 = '1;
            cntrl.jump = '0;
            cntrl.aluop=3'b010;
          end
          6'h05 : begin
            
            cntrl.memWriteEnable ='0;
            cntrl.regWrite='1;
            cntrl.writeBack = '1;
            cntrl.wbMux = '1;
            cntrl.rs2 = '0;
            cntrl.jump = '0;
            cntrl.aluop =3'b010;
          end
          6'h06 : begin
            
            cntrl.memWriteEnable ='0;
            cntrl.regWrite='1;
            cntrl.writeBack = '1;
            cntrl.wbMux = '1;
            cntrl.rs2 = '1;
            cntrl.jump = '0;
            cntrl.aluop = 3'b011;
          end
          6'h07 : begin
            
            cntrl.memWriteEnable ='0;
            cntrl.regWrite='1;
            cntrl.writeBack = '1;
            cntrl.wbMux = '1;
            cntrl.rs2 = '0;
            cntrl.jump = '0;
            cntrl.aluop = 3'b011;
          end
          6'h08 : begin
            
            cntrl.memWriteEnable ='0;
            cntrl.regWrite='1;
            cntrl.writeBack = '1;
            cntrl.wbMux = '1;
            cntrl.rs2 = '1;
            cntrl.jump = '0;
            cntrl.aluop = 3'b100;
          end
          6'h09 : begin
            
            cntrl.memWriteEnable ='0;
            cntrl.regWrite='1;
            cntrl.writeBack = '1;
            cntrl.wbMux = '1;
            cntrl.rs2 = '0;
            cntrl.jump = '0;
            cntrl.aluop = 3'b100;
          end
          6'h0A : begin
            
            cntrl.memWriteEnable ='0;
            cntrl.regWrite='1;
            cntrl.writeBack = '1;
            cntrl.wbMux = '1;
            cntrl.rs2 = '1;
            cntrl.jump = '0;
            cntrl.aluop = 3'b101;
          end
          6'h0B : begin
            
            cntrl.memWriteEnable ='0;
            cntrl.regWrite='1;
            cntrl.writeBack = '1;
            cntrl.wbMux = '1;
            cntrl.rs2 = '0;
            cntrl.jump = '0;
            cntrl.aluop = 3'b101;
          end
          6'h0C : begin
            
            cntrl.memWriteEnable ='0;
            cntrl.regWrite='1;
            cntrl.writeBack = '1;
            cntrl.wbMux = '0;
            cntrl.jump = '0;
            cntrl.rs2 = '0;
            cntrl.aluop = 3'b000;
          end
          6'h0D : begin
            
            cntrl.aluop = 3'b000;
            cntrl.memWriteEnable ='1;
            cntrl.rs2 = '0;
            cntrl.jump = '0;
            cntrl.regWrite='0;
          end
          6'h0E : begin
            
            cntrl.memWriteEnable ='0;
            cntrl.regWrite='0;
            cntrl.rs2 = '0;
            cntrl.jump = '0;
            cntrl.aluop = 3'b110;
          end
          6'h0F : begin
            
            cntrl.memWriteEnable ='0;
            cntrl.regWrite='0;
            cntrl.rs2 = '1;
            cntrl.jump = '0;
            cntrl.aluop = 3'b111;
          end
          6'h10 : begin
            
            cntrl.memWriteEnable ='0;
            cntrl.regWrite='0;
            cntrl.rs2 = '0;
            cntrl.jump = '1;
            cntrl.aluop= 3'b000;
          end
          6'h11 : begin
            
            cntrl.memWriteEnable ='0;
            cntrl.regWrite='0;
            cntrl.rs2 = '1;
            cntrl.jump = '0;
            cntrl.aluop= 3'b000;
            halt_signal ='1;
          end
        default: begin
                  cntrl.regWrite='0;
                 cntrl.memWriteEnable='0;
                 halt_signal='0;
                 cntrl.aluop='x;
                 cntrl.jump ='0;
                 cntrl.rs2 ='x;
                 end
          endcase
          end
  
  always_comb
    begin
      unique case(instruction.opcode)
        6'b000001: imm_o={{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}},instruction.Type.I.imm};
        6'b000011: imm_o={{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}},instruction.Type.I.imm};
        6'b000101: imm_o={{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}},instruction.Type.I.imm};
        6'b000111: imm_o={{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}},instruction.Type.I.imm};
        6'b001001: imm_o={{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}},instruction.Type.I.imm};
        6'b001011: imm_o={{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}},instruction.Type.I.imm};
        6'b001100: imm_o={{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}},instruction.Type.I.imm};
        6'b001101: imm_o={{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}},instruction.Type.I.imm};
        6'b001110: imm_o={{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}},instruction.Type.I.imm};
        6'b001111: imm_o={{DATA-IMM_SIZE{instruction.Type.I.imm[IMM_SIZE-1]}},instruction.Type.I.imm};
        default : imm_o = 'x;
      endcase
    end
  
  always_comb
    begin

      if(rs1==Read_Buffer[0].rd || rs2==Read_Buffer[0].rd )
        begin
            if(Instr_Buffer[0].instruction.opcode==6'h0C || instruction.opcode!==6'h09 ) begin
                count=2'b10;
                hazard ='1;
            end
        end
      else if (rs1==Read_Buffer[1].rd || rs2==Read_Buffer[1].rd)
        begin
          if(Instr_Buffer[0].instruction.opcode!==6'h09 || instruction.opcode!==6'h09 ) begin
            count =2'b10;
            hazard ='1;
          end
      end
      else  hazard = '0;
    end

  always_comb
    begin
      if(hazard || set=='1) hazard_detected ='1;
      else  hazard_detected = '0;

      if(wait_count == count) hazard_detected = '0;
  end

  always_comb
    begin
      if(rs1==Read_Buffer[0].rd )
        begin
          if(Instr_Buffer[0].instruction.opcode!==6'h0C )
            begin
              Forward_1 ='1;
              Forward_2 = '0;
              mem_Forward_1 ='0;
              mem_Forward_2='0;
              wb_Forward_1 ='0;
              wb_Forward_2 ='0;
            end
      end
      else if( rs2==Read_Buffer[0].rd)
        begin
         if(Instr_Buffer[0].instruction.opcode!==6'h0C)
           begin
              Forward_1 ='0;
              Forward_2 = '1;
              mem_Forward_1 ='0;
              mem_Forward_2='0;
              wb_Forward_1 ='0;
              wb_Forward_2 ='0;
            end
      end
      else
        begin
          Forward_1 ='0;
          Forward_2 = '0;
          mem_Forward_1 ='0;
          mem_Forward_2='0;
          wb_Forward_1 ='0;
          wb_Forward_2 ='0;
      end

  end
  
endmodule