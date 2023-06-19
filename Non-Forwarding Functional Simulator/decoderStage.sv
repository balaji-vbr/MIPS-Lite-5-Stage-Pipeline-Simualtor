`include "mipspkg.sv"

module InstrDecode(clock,rst,is_taken,pc,control_i,input_read, wr_en, instruction, wr_data, cntrl, imm_o, read_data1, read_data2,pc_o, rs1,rs2,rd, hazard_detected,halt_detected);
  import Types::*;
  
  input Instruct instruction;
  input logic clock;
  input logic rst;
  input logic is_taken;
  input logic [ADD_WIDTH-1:0] pc;
  input logic [DATA-1:0] wr_data;
  input logic wr_en;
  input Control control_i;
  input logic [REG_WIDTH-1:0] input_read;
  output logic [DATA-1:0] imm_o;
  output logic [DATA-1:0] read_data1;
  output logic [DATA-1:0] read_data2;
  output logic [ADD_WIDTH-1:0] pc_o;
  output Control cntrl;
  output logic [REG_WIDTH-1:0] rd;
  output logic [REG_WIDTH-1:0] rs1, rs2;
  output logic hazard_detected;
  output logic halt_detected;
  
  logic [1:0] count;
  logic hazard; 
  logic [1:0] waitCount;
  bit set;
  
  logic[DATA-1:0] registerFile [REG_NUM-1:0];
  
  always_comb
    begin
      if(!is_taken)
       begin
      
      case(instruction.opcode) 
        6'b000000: begin
          
          if(!halt_detected)
          begin
          Total_Instruction_Count();
          Arithmetic_Instruction_Count();
           end
          rs1 = instruction.Type.R.rs;
          rs2 = instruction.Type.R.rt;
          rd = instruction.Type.R.rd;
        end
        6'b000001: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Arithmetic_Instruction_Count();
            end
          rs1 = instruction.Type.I.rs;
          rs2 = 'x;
          rd =  instruction.Type.I.rt;
        end
        6'b000010: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Arithmetic_Instruction_Count();
            end
          rs1 = instruction.Type.R.rs;
          rs2 = instruction.Type.R.rt;
          rd  = instruction.Type.R.rd;
        end

        6'b000011: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Arithmetic_Instruction_Count();
            end
          rs1 = instruction.Type.I.rs;
          rs2 ='x;
          rd  = instruction.Type.I.rt;
        end

        6'b000100: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Arithmetic_Instruction_Count();
            end
          rs1 = instruction.Type.R.rs;
          rs2 = instruction.Type.R.rt;
          rd = instruction.Type.R.rd;
        end
        6'b000101: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Arithmetic_Instruction_Count();
            end
          rs1 = instruction.Type.I.rs;
          rs2 = 'x;
          rd = instruction.Type.I.rt;
        end
        6'b000110: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Logical_Instruction_Count();
            end
          rs1 = instruction.Type.R.rs;
          rs2 = instruction.Type.R.rt;
          rd = instruction.Type.R.rd;
        end
        6'b000111: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Logical_Instruction_Count();
            end
          rs1 = instruction.Type.I.rs;
          rs2 = 'x;
          rd = instruction.Type.I.rt;
        end
        6'b001000: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Logical_Instruction_Count();
            end
          rs1 = instruction.Type.R.rs;
          rs2 = instruction.Type.R.rt;
          rd = instruction.Type.R.rd;
        end
        6'b001001: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Logical_Instruction_Count();
            end
          rs1 = instruction.Type.I.rs;
          rs2='x;
          rd = instruction.Type.I.rt;
        end
        6'b001010: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Logical_Instruction_Count();
            end
          rs1 = instruction.Type.R.rs;
          rs2 = instruction.Type.R.rt;
          rd = instruction.Type.R.rd;
        end
        6'b001011: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Logical_Instruction_Count();
            end
          rs1 = instruction.Type.I.rs;
          rs2 = 'x;
          rd = instruction.Type.I.rt;
        end
        6'b001100: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Mem_Instruction_Count();
            end
          rs1 = instruction.Type.I.rs;
          rs2 = 'x;
          rd = instruction.Type.I.rt;
        end
        6'b001101: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Mem_Instruction_Count();
            end
          rs1 = instruction.Type.I.rs;
          rs2 = instruction.Type.I.rt;
          rd='x;
        end
        6'b001110: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Branch_Instruction_Count();
            end
          rs1 = instruction.Type.I.rs;
          rs2 = 'x;
          rd='x;
        end
        6'b001111: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Branch_Instruction_Count();
            end
          rs1 =  instruction.Type.I.rs;
          rs2 = instruction.Type.I.rt;
          rd='x;
        end
        6'b010000: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Branch_Instruction_Count();
            end
          rs1 = instruction.Type.I.rs;
          rs2 = 'x;
          rd='x;
        end
        6'b010001: begin
          
          if(!halt_detected)
            begin
          Total_Instruction_Count();
          Branch_Instruction_Count();
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
  
  always_ff@(posedge clock)
    begin
      if(rst)
        begin
          for(int i=0; i < REG_NUM; i++)
            begin
             registerFile[i] <= '0;
            end
        end
      else if(control_i.regWrite)
        begin
        registerFile[input_read] <= wr_data;
        end
      else
        begin
          registerFile[input_read] <= registerFile[input_read];
        end
    end
  always_ff@(negedge clock)
    begin
      read_data1 <= registerFile[rs1];
      read_data2 <= registerFile[rs2];
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
            halt_detected ='1;
          end
        default: begin
                  cntrl.regWrite='0;
                 cntrl.memWriteEnable='0;
                 halt_detected='0;
                 cntrl.aluop='x;
                 cntrl.jump ='0;
                 cntrl.rs2 ='x;
                 end
          endcase
          end

    always_comb
    begin
      unique case(instruction.opcode)
        6'b000001: imm_o={{DATA-IMMEDIATE_SIZE{instruction.Type.I.imm[IMMEDIATE_SIZE-1]}},instruction.Type.I.imm};
        6'b000011: imm_o={{DATA-IMMEDIATE_SIZE{instruction.Type.I.imm[IMMEDIATE_SIZE-1]}},instruction.Type.I.imm};
        6'b000101: imm_o={{DATA-IMMEDIATE_SIZE{instruction.Type.I.imm[IMMEDIATE_SIZE-1]}},instruction.Type.I.imm};
        6'b000111: imm_o={{DATA-IMMEDIATE_SIZE{instruction.Type.I.imm[IMMEDIATE_SIZE-1]}},instruction.Type.I.imm};
        6'b001001: imm_o={{DATA-IMMEDIATE_SIZE{instruction.Type.I.imm[IMMEDIATE_SIZE-1]}},instruction.Type.I.imm};
        6'b001011: imm_o={{DATA-IMMEDIATE_SIZE{instruction.Type.I.imm[IMMEDIATE_SIZE-1]}},instruction.Type.I.imm};
        6'b001100: imm_o={{DATA-IMMEDIATE_SIZE{instruction.Type.I.imm[IMMEDIATE_SIZE-1]}},instruction.Type.I.imm};
        6'b001101: imm_o={{DATA-IMMEDIATE_SIZE{instruction.Type.I.imm[IMMEDIATE_SIZE-1]}},instruction.Type.I.imm};
        6'b001110: imm_o={{DATA-IMMEDIATE_SIZE{instruction.Type.I.imm[IMMEDIATE_SIZE-1]}},instruction.Type.I.imm};
        6'b001111: imm_o={{DATA-IMMEDIATE_SIZE{instruction.Type.I.imm[IMMEDIATE_SIZE-1]}},instruction.Type.I.imm};
        default : imm_o = 'x;
      endcase
    end
  
  always_comb
    begin
      if(rs1==Read__Buffer[0].rd || rs2==Read__Buffer[0].rd)
        begin
          count=2'b10;
          hazard ='1;
        end
      else if (rs1==Read__Buffer[1].rd || rs2==Read__Buffer[1].rd)
        begin
          count =2'b01;
          hazard ='1;
        end
      else
        begin
          hazard = '0;
        end

    end

  always_ff@(posedge clock)
  begin
    if(hazard && set=='0)
      begin
      waitCount <='0;
      set <='1;
      end
    else if( set=='1 && waitCount!==count)
      begin
        waitCount <= waitCount + 1'b1;
        stalls <= stalls+1;
      end
    else 
      begin
      set<=0;
      waitCount <='0;
      end
  end
  always_comb
    begin
      if(hazard || set=='1)
         begin
        hazard_detected ='1;
         end
      else 
        hazard_detected='0;
        
      if(waitCount == count)
        hazard_detected = '0;
       
    end
  always_comb
    begin
      if(set)
      Data_Hazards = Data_Hazards+1;
    end
  
  assign pc_o = pc;
 
    
  
endmodule
