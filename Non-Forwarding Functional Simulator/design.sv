`include "instructionFetch.sv"
`include "decoderStage.sv"
`include "executionStage.sv"
`include "memStage.sv"
`include "writeBackStage.sv"

module MIPS_Processor(clock,rst);
  import Types::*;
  input logic clock;
  input logic rst;

  Instruct instruction;
  logic [ADD_WIDTH-1:0] pcPlus4;
  logic [ADD_WIDTH-1:0] pc;
  logic [ADD_WIDTH-1:0] pcOut;

  logic writeEnable;
  logic [DATA-1:0]wbData;
  logic [DATA-1:0] immOut;
  logic [DATA-1:0] readData1;
  logic [DATA-1:0] readData2;
  Control cntrl;




  logic [DATA-1:0] aluOut;
  logic [ADD_WIDTH-1:0] branchAddress;
  logic branchTaken;
  logic [DATA-1:0] writeData;

  logic [DATA-1:0] dataOut;

  logic[DATA-1:0] memDataOut;
  logic [DATA-1:0] writeBackData;
  
  
  string TEST;
  logic [REG_WIDTH-1:0] rd,rs1,rs2,decoderRd, executionRd,wbRd;
  logic hazardDetected;
  logic haltSignal;
  int count;
  initial 
    begin
      if($value$plusargs("TEST = %s",TEST))
        $display("string = %s",TEST);
    end

  
  InstrFetch IF(clock, rst, haltSignal, hazardDetected, branchAddress, branchTaken, pcPlus4, instruction,pc);

  
  always_ff@(posedge clock)
    begin
      if(rst)
        begin
        clockCount<=0;
          stalls<=0;
        end
      else
        begin
          clockCount<= clockCount+1;
          if(!hazardDetected && !branchTaken)
            begin
          Fetch_Buffer.instruction <=instruction;
          Fetch_Buffer.pc <= pc;
            end
          if(branchTaken )
          begin
            Fetch_Buffer.pc <= pc;
          Fetch_Buffer.instruction <='x;
             clockCount <= clockCount-1;
            count =count+1;
            end
        end
    end
always_comb
  begin
    if(haltSignal)
    finalClockCount = clockCount + 3;
  end

  InstrDecode ID(clock,rst,branchTaken,Fetch_Buffer.pc,Cntrl_Buffer[2].cntrl, wbRd , writeEnable, Fetch_Buffer.instruction, wbData, cntrl, immOut, readData1, readData2,pcOut, rs1, rs2, rd,hazardDetected,haltSignal);

  always_ff@(posedge clock)
    begin
      if(!hazardDetected && !branchTaken)
        begin
      Decode_Buffer.instruction <= Fetch_Buffer.instruction;
      Decode_Buffer.readData1 <= readData1;
      Decode_Buffer.readData2 <= readData2;
      Decode_Buffer.immOut <= immOut;
      Decode_Buffer.pc <= pcOut;
      Decode_Buffer.haltSignal<=haltSignal;
          Decode_Buffer.rd <= rd;
      
      Cntrl_Buffer[0].cntrl<= cntrl;
      Read__Buffer[0].rd <= rd;
      Read__Buffer[0].rs1 <= rs1;
      Read__Buffer[0].rs2 <= rs2;
        end
       else if(branchTaken)
        begin
          Instruction_Count = Instruction_Count -1;
          unique case(Fetch_Buffer.instruction.opcode)
            6'h00,
            6'h01,
            6'h02,
            6'h03,
            6'h04,
            6'h05 : Arithmetic_Instr_Count = Arithmetic_Instr_Count-1;
            
            6'h06,
            6'h07,
            6'h08,
            6'h09,
            6'h0A,
            6'h0B : Logical_Instr_Count = Logical_Instr_Count-1;
            
            6'h0C,
            6'h0D : Mem_Instr_Count = Mem_Instr_Count - 1;
            
            6'h0E,
            6'h0F,
            6'h10,
            6'h11 : Branch_Instr_Count = Branch_Instr_Count - 1;
            
          endcase
      Decode_Buffer.readData1 <= '0;
      Decode_Buffer.readData2 <= '0;
      Decode_Buffer.immOut <= '0;
      Decode_Buffer.pc <= pcOut ;
          Decode_Buffer.haltSignal<=haltSignal;
          Decode_Buffer.instruction <= 'x;
      
          Cntrl_Buffer[0].cntrl<= 'x;
          Read__Buffer[0].rd <= 'x;
          Read__Buffer[0].rs1 <= 'x;
          Read__Buffer[0].rs2 <= 'x;
           Decode_Buffer.rd <= 'X;
        end
    end


  Execute IE(clock,Decode_Buffer.instruction, Decode_Buffer.rd, Decode_Buffer.readData1, Decode_Buffer.readData2, Decode_Buffer.immOut, Decode_Buffer.pc ,Cntrl_Buffer[0].cntrl,aluOut,branchAddress, branchTaken, writeData ,executionRd);
  always_ff@(posedge clock)
    begin
 
      Execution_Buffer.aluOut <= aluOut;
      Execution_Buffer.branchAddress <= branchAddress;
      Execution_Buffer.branchTaken <= branchTaken;
      Execution_Buffer.writeData <= writeData;
      Execution_Buffer.haltSignal <= Decode_Buffer.haltSignal;
      Execution_Buffer.rd <= executionRd;
      Execution_Buffer.instruction <=Decode_Buffer.instruction;
      Execution_Buffer.branchTaken <= branchTaken;
      Cntrl_Buffer[1].cntrl<= Cntrl_Buffer[0].cntrl;
      Read__Buffer[1].rd <= Read__Buffer[0].rd;
      Read__Buffer[1].rs1 <= Read__Buffer[0].rs1;
      Read__Buffer[1].rs2 <= Read__Buffer[0].rs2;
        
    end

  MemAccess IM(clock,rst,Execution_Buffer.aluOut, Execution_Buffer.writeData, Execution_Buffer.aluOut, Cntrl_Buffer[1].cntrl, memDataOut, writeBackData);
  always_ff@(posedge clock)
    begin
      Memory_Buffer.instruction <=Execution_Buffer.instruction;
      Memory_Buffer.memDataOut <= memDataOut;
      Memory_Buffer.writeBackData <= writeBackData;
      Memory_Buffer.haltSignal <= Execution_Buffer.haltSignal;
      Memory_Buffer.rd <= Execution_Buffer.rd;
      
      Cntrl_Buffer[2].cntrl<= Cntrl_Buffer[1].cntrl;
      Read__Buffer[2].rd <= Read__Buffer[1].rd;
      Read__Buffer[2].rs1 <= Read__Buffer[1].rs1;
      Read__Buffer[2].rs2 <= Read__Buffer[1].rs2;
    end
  WriteBack WB(clock,Memory_Buffer.instruction,Memory_Buffer.rd ,Memory_Buffer.writeBackData, Memory_Buffer.memDataOut , 
                    Cntrl_Buffer[2].cntrl, wbData,Memory_Buffer.haltSignal,wbRd);



  final
  begin
    $display("--------------------------------------------------------------------------");
    $display("			     Pipeline Without Forwarding 			");
    $display("--------------------------------------------------------------------------");
    $display("");
    $display("--------------------------------------------------------------------------");
    $display("\n			 Instruction Counts                             ");
    $display("--------------------------------------------------------------------------");				
    $display("Total Number of Instructions = %0d", Instruction_Count);
    $display("Total Number of Arithmetic Instructions = %0d", Arithmetic_Instr_Count);
    $display("Total Number of Logical Instructions = %0d", Logical_Instr_Count);
    $display("Total Number of Memory access instruction = %0d", Mem_Instr_Count);
    $display("Total Number of Control transfer instruction = %0d", Branch_Instr_Count);
    $display("");
    $display("-----------------------------------------------");
    $display("\n Final Register Status ");
    $display("-----------------------------------------------");
    $display("Program Counter = %0d", IF.pc);
    for (int i=0; i< 32; i++)
      begin
        $display("R%0d = %0d", i, $signed(ID.registerFile[i]));
      end
    dataOut = {>>MEM_WIDTH{IM.dataMem[1400 +: BPI]}};
    $display("-----------------------------------------------");
    $display("\n Final Memory State ");
    $display("-----------------------------------------------");
    $display("Address = 1400 Contents =%0d",dataOut);
    dataOut = {>>MEM_WIDTH{IM.dataMem[1404 +: BPI]}};
    $display("Address = 1404 Contents =%0d", dataOut);
    dataOut = {>>MEM_WIDTH{IM.dataMem[1408 +: BPI]}};
    $display("Address = 1408 Contents =%0d",dataOut);
    $display("-----------------------------------------------");
    $display("\n Timing Simulator ");
    $display("-----------------------------------------------");
    $display("");
    $display("Total number of clock Cycles = %0d", finalClockCount);
    $display("STALLS=%0d",stalls);
    $display("Total Data Hazards=%0d", Data_Hazards);
    $display("-----------------------------------------------");

  end


endmodule
