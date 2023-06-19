`include "instructionFetch.sv"
`include "decoderStage.sv"
`include "executionStage.sv"
`include "memStage.sv"
`include "writeBackStage.sv"

module MIPS_Processor(clk,rst);
  import TYPES::*;

  input logic clk;
  input logic rst;

  Instruct instruction,instr, instrMem, instrDec;
  Control cntrl;
  string TEST;
  
  logic [ADDRESS_WIDTH-1:0] pcPlus4;
  logic [ADDRESS_WIDTH-1:0] pc;
  logic [ADDRESS_WIDTH-1:0] pcOut;
  logic writeEnable;
  logic [DATA-1:0]wbData;
  logic [DATA-1:0] immOut;
  logic [DATA-1:0] readData1;
  logic [DATA-1:0] readData2;
  logic [DATA-1:0] aluOut;
  logic [ADDRESS_WIDTH-1:0] Branch_Address;
  logic is_taken;
  logic [DATA-1:0] writeData;
  logic [DATA-1:0] dataOut;
  logic[DATA-1:0] memDataOut;
  logic [DATA-1:0] writeBackData;
  logic [REGISTER_WIDTH-1:0] rd,rs1,rs2;
  logic Hazard_Detected;
  logic haltSignal;
  logic Forward_1, Forward_2, Mem_Forward_1, Mem_Forward_2, wb_Forward_1, wb_Forward_2;

  initial 
    begin
      if($value$plusargs("TEST = %s",TEST))
        $display("string = %s",TEST);
    end

  
  InstrFetch IF(clk, rst, haltSignal, Hazard_Detected, Branch_Address, is_taken, pcPlus4, instruction,pc);

  always_comb
  begin
    if(haltSignal)
    Final_Clock_Count = Clock_Count + 3;
  end
  
  always_ff@(posedge clk)
    begin
      if(rst)
        begin
        Clock_Count<=0;
          
        end
      else
        begin
          if(Forward_1=='0 && Forward_2 =='0)
          Clock_Count<= Clock_Count+1;
          if(!Hazard_Detected )
            begin
          Fetch_Buffer.instruction <=instruction;
          Fetch_Buffer.pc <= pc;
            end
          if(is_taken)
          begin
          Fetch_Buffer.instruction <='x;
            Fetch_Buffer.pc <= pc;
            end
        end
    end


  InstrDecode ID(clk,rst,is_taken,Fetch_Buffer.pc,Cntrl_Buffer[2].cntrl, Read_Buffer[2].rd , writeEnable, Fetch_Buffer.instruction, wbData, cntrl, immOut, readData1, readData2,pcOut, rs1, rs2, rd,Hazard_Detected,haltSignal,Forward_1, Forward_2,Mem_Forward_1, Mem_Forward_2,wb_Forward_1, wb_Forward_2, instrDec);

  always_ff@(posedge clk)
    begin
      if(!Hazard_Detected && !is_taken)
        begin
      Decode_Buffer.instruction <= instrDec;
      Decode_Buffer.readData1 <= readData1;
      Decode_Buffer.readData2 <= readData2;
      Decode_Buffer.immOut <= immOut;
      Decode_Buffer.pc <= pcOut;
      Decode_Buffer.Forward_1 <= Forward_1;
      Decode_Buffer.Forward_2 <= Forward_2;
      Decode_Buffer.Mem_Forward_1 <= Mem_Forward_1;
      Decode_Buffer.Mem_Forward_2 <= Mem_Forward_2;
          Decode_Buffer.wb_Forward_1 <= wb_Forward_1;
          Decode_Buffer.wb_Forward_2 <= wb_Forward_2;
      Decode_Buffer.haltSignal<=haltSignal;
      Instr_Buffer[0].instruction <= instrDec;
      Cntrl_Buffer[0].cntrl<= cntrl;
      Read_Buffer[0].rd <= rd;
      Read_Buffer[0].rs1 <= rs1;
      Read_Buffer[0].rs2 <= rs2;
        end
       else if(is_taken)
        begin
          Total_Instr_Count = Total_Instr_Count -1;
          case(Fetch_Buffer.instruction.opcode)
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
          Decode_Buffer.Forward_1 <= Forward_1;
          Decode_Buffer.Forward_2 <= Forward_2;
          Decode_Buffer.Mem_Forward_1 <= Mem_Forward_1;
          Decode_Buffer.Mem_Forward_2 <= Mem_Forward_2;
          Decode_Buffer.wb_Forward_1 <= wb_Forward_1;
          Decode_Buffer.wb_Forward_2 <= wb_Forward_2;
          Decode_Buffer.haltSignal<=haltSignal;
          Instr_Buffer[0].instruction <= instrDec;
          Cntrl_Buffer[0].cntrl<= '0;
          Read_Buffer[0].rd <= '0;
          Read_Buffer[0].rs1 <= '0;
          Read_Buffer[0].rs2 <= '0;
        end
    end


  Execute IE(clk,Instr_Buffer[0].instruction, Decode_Buffer.readData1, Decode_Buffer.readData2, Decode_Buffer.immOut, Decode_Buffer.pc ,Cntrl_Buffer[0].cntrl,aluOut,Branch_Address, is_taken, writeData, Decode_Buffer.Forward_1, Decode_Buffer.Forward_2,Decode_Buffer.Mem_Forward_1, Decode_Buffer.Mem_Forward_2, Decode_Buffer.wb_Forward_1, Decode_Buffer.wb_Forward_2, Mem_Buffer.memDataOut,Mem_Buffer.writeBackData, instr);
  always_ff@(posedge clk)
    begin
      Execution_Buffer.aluOut <= aluOut;
      Execution_Buffer.Branch_Address <= Branch_Address;
      Execution_Buffer.is_taken <= is_taken;
      Execution_Buffer.writeData <= writeData;
      Execution_Buffer.haltSignal <= Decode_Buffer.haltSignal;
      Instr_Buffer[1].instruction <= instr;
      Cntrl_Buffer[1].cntrl<= Cntrl_Buffer[0].cntrl;
      Read_Buffer[1].rd <= Read_Buffer[0].rd;
      Read_Buffer[1].rs1 <= Read_Buffer[0].rs1;
      Read_Buffer[1].rs2 <= Read_Buffer[0].rs2;     
  end

  MemAccess IM(clk,rst,Instr_Buffer[1].instruction, Execution_Buffer.aluOut, Execution_Buffer.writeData, Execution_Buffer.aluOut, Cntrl_Buffer[1].cntrl, memDataOut, writeBackData, instrMem);
  always_ff@(posedge clk)
    begin
      Instr_Buffer[2].instruction <= instrMem;
      Mem_Buffer.memDataOut <= memDataOut;
      Mem_Buffer.writeBackData <= writeBackData;
      Mem_Buffer.haltSignal <= Execution_Buffer.haltSignal;
      Cntrl_Buffer[2].cntrl<= Cntrl_Buffer[1].cntrl;
      Read_Buffer[2].rd <= Read_Buffer[1].rd;
      Read_Buffer[2].rs1 <= Read_Buffer[1].rs1;
      Read_Buffer[2].rs2 <= Read_Buffer[1].rs2;
    end
  WriteBack WB(clk,Mem_Buffer.writeBackData, Mem_Buffer.memDataOut , 
                    Cntrl_Buffer[2].cntrl, wbData,Mem_Buffer.haltSignal);
 
  final
  begin
    $display("-------------------------------------------------------");
    $display("                   Pipeline with Forwarding       ");
    $display("-------------------------------------------------------");
	$display("");
	$display("-------------------------------------------------------");
    $display("\n                 Total Instruction Counts ");
	$display("-------------------------------------------------------");
    $display("Toatl Number of Instructions = %0d", Total_Instr_Count);
    $display("Total Number of Arithmetic Instructions = %0d", Arithmetic_Instr_Count);
    $display("Total Number of Logical Instructions = %0d", Logical_Instr_Count);
    $display("Total Number of Memory Access Instruction = %0d", Mem_Instr_Count);
    $display("Total Number of Control Transfer Instruction = %0d", Branch_Instr_Count);
	$display("");
	$display("-------------------------------------------------------");
    $display("\n                  Final Register Status ");
	$display("-------------------------------------------------------");
    $display("Program Counter = %0d", IF.pc);
    for (int i=0; i< 32; i++)
      begin
        $display("R%0d = %0d", i, $signed(ID.registerFile[i]));
      end
	$display("");
	$display("-------------------------------------------------------");
	$display("\n                   Final Memory State ");
    $display("-------------------------------------------------------");
	for(int i=0;i<MEM_DEPTH-1; i=i+4)
      begin
        if(memWriteStatus[i]=='1)
          begin
        dataOut = {>>MEM_WIDTH{IM.dataMem[i +: BPI]}};
                    $display("Address = %0d Contents =%0d",i,dataOut);

          end
      end
	$display("-------------------------------------------------------");
    $display("\n                   Timing Simulator ");
	$display("-------------------------------------------------------");
    $display("Total number of Clock Cycles = %0d", Final_Clock_Count);
    $display("STALLS=%0d",stalls);
    $display("Total Data hazard=%0d", Data_Hazards);
	$display("-------------------------------------------------------");

  end

endmodule