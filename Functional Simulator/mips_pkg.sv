`ifndef MIPS_LITE
`define MIPS_LITE

package mips_pkg;
parameter IMM_SIZE=16;//
parameter OPCODE =6;
parameter REGISTER_NUMBER= 32;//
parameter DATA = 32;
parameter ADDRESS_WIDTH=32;//

localparam REGISTER_WIDTH = $clog2(REGISTER_NUMBER);//
localparam MEMDEPTH = 4096;
localparam  MEMWIDTH=8;
localparam INSTRUCTION_WIDTH=32;
localparam BPI= INSTRUCTION_WIDTH/MEMWIDTH; 


int InstructionCount;//
int ArithmeticInstrCount;//
int LogicalInstrCount;//
int MemoryInstrCount;//
int BranchInstrCount;//


logic [MEMDEPTH-1:0] MemWriteStatus;//

typedef union packed{
  
  struct packed {
    logic [REGISTER_WIDTH-1:0] rs;
    logic [REGISTER_WIDTH-1:0] rt;
    logic [REGISTER_WIDTH-1:0] rd;
    logic[10:0] unused;
  }R;
  
  struct packed{
    logic [REGISTER_WIDTH-1:0] rs;
    logic [REGISTER_WIDTH-1:0] rt;
    logic [IMM_SIZE-1:0] imm;
  }I;

}Instruction;

typedef struct packed{
  logic[OPCODE-1:0] opcode;
  Instruction Type;
}Instr; //

typedef struct packed{
  logic MemWriteEnable;//
  logic RegWriteEnable;//
  logic WriteBack;//
  logic WBMux;//
  logic srcReg2;//
  logic jump;
  logic [2:0] ALU_op;
}Control;

task CountInstruction();//
  InstructionCount = InstructionCount + 1;
endtask

task CountArithmeticInstruction();//
  ArithmeticInstrCount = ArithmeticInstrCount + 1;
endtask

task CountLogicalInstruction();//
  LogicalInstrCount = LogicalInstrCount + 1;
endtask

task CountMemoryInstruction();//
  MemoryInstrCount = MemoryInstrCount + 1;
endtask

task CountBranchInstruction();//
  BranchInstrCount = BranchInstrCount + 1;
endtask


endpackage


`endif
