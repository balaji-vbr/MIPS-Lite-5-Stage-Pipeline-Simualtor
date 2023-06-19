`include "InstrFetch.sv"
`include "InstrDecode.sv"
`include "Execute.sv"
`include "MemAccess.sv"
`include "WriteBack.sv"

module MIPS_Lite_Simulator(clk,reset);
  import mips_pkg::*;
  input logic clk;
  input logic reset;
  
  Instr instruction;
  logic [ADDRESS_WIDTH-1:0] pc_add_4;
  logic [ADDRESS_WIDTH-1:0] pc;
  
  logic Write_Enable;
  logic [DATA-1:0]WB_Data;
  logic [DATA-1:0] imm_op;
  logic [DATA-1:0] Data1_read;
  logic [DATA-1:0] Data2_read;
  Control cntrl;
  
  int clock_count;

  
  logic [DATA-1:0] ALU_Out;
  logic [ADDRESS_WIDTH-1:0] Branch_Address;
  logic Branch_Taken;
  logic [DATA-1:0] WriteData;
  
  logic [DATA-1:0] dataOut;
  
  logic[DATA-1:0] Mem_Data_Out;
  logic [DATA-1:0] Write_Back_Data;
  
  
  InstrFetch a(clk, reset, Branch_Address, Branch_Taken, pc_add_4, instruction,pc);
  
  InstrDecode b(clk,reset,Write_Enable, instruction, WB_Data, cntrl, Data1_read, Data2_read, imm_op);

  Execute c(Data1_read, Data2_read, imm_op, pc, cntrl, ALU_Out, Branch_Address, Branch_Taken, WriteData);
  
  MemAccess d(clk,reset, ALU_Out, WriteData, ALU_Out, cntrl, Mem_Data_Out, Write_Back_Data);
  
  WriteBack e(Write_Back_Data, Mem_Data_Out, cntrl, WB_Data);
  

final
  begin
    
    $display("-----------------------------------------------");
    $display("               Functional Simulator Output ");
    $display("-----------------------------------------------");
    $display("");
    $display("-----------------------------------------------");
    $display("\n               Total Instruction Counts");
    $display("-----------------------------------------------");
    $display("Total Number of Instructions     = %0d", InstructionCount);
    $display("Total Number of Arithmetic Instructions         = %0d", ArithmeticInstrCount);
    $display("Total Number of Logical Instructions            = %0d", LogicalInstrCount);
    $display("Total Number of Memory access instructions      = %0d", MemoryInstrCount);
    $display("Total Number of Control transfer instructions   = %0d", BranchInstrCount);
    $display("");
    $display("-----------------------------------------------");
    $display("\n               Final Register Status ");
    $display("-----------------------------------------------");
    $display("Program Counter                 = %0d", a.mux_branch_op);
    
    for (int i=0; i<32; i=i+1)
    begin
        $display("R%0d                              = %0d", i, $signed(b.RegisterFile[i]));
    end
    $display("");
    $display("-----------------------------------------------");
    $display("\n               Final Memory State ");
    $display("-----------------------------------------------");
    
    for (int i=0; i<MEMDEPTH-1; i=i+4)
    begin
        if (MemWriteStatus[i] == '1)
        begin
            dataOut = {>>MEMWIDTH{d.data_memory[i +: BPI]}};
            $display("Address                          = %0d", i);
            $display("Contents                         = %0d", $signed(dataOut));
        end
    end
    
    $display("-----------------------------------------------");
    
  end

  
endmodule
