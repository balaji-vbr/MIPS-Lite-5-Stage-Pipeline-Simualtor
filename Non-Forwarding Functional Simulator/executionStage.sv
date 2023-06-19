`include "mipspkg.sv"

module Execute(clock, instruction, decoder_read,read_data1, read_data2, imm_o, pc_added4 ,cntrl,alu_o,addr_new, is_taken, wr_data, exec_read);
  import Types::*;
 
  input logic clock;
  input Instruct instruction;
  input logic [DATA-1:0] read_data1;
  input logic [DATA-1:0] read_data2;
  input logic [DATA-1:0] imm_o;
  input logic [ADD_WIDTH-1:0] pc_added4;
  input Control cntrl;
  input logic[REG_WIDTH-1:0] decoder_read;
  
  output logic [DATA-1:0] alu_o;
  output logic [DATA-1:0] addr_new;
  logic [DATA-1:0] addr_branch;
  output logic [DATA-1:0] wr_data;
  
  bit zero;
  output logic is_taken;
  output logic [REG_WIDTH-1:0]  exec_read;
  
  logic [DATA-1:0] alu_i_1;
  logic invalid_addr;
  logic [DATA-1:0] alu_i_2;
  
  always_comb
  begin
  wr_data = read_data2;
  exec_read = decoder_read;
  {invalid_addr,addr_branch} = $signed(pc_added4)+$signed(imm_o<<2);
  end

  assign alu_i_2 = (cntrl.rs2) ? read_data2 : imm_o;
  assign addr_new = (cntrl.jump) ? read_data1: addr_branch;
 
  always_comb
    begin
      is_taken ='0;
      zero= '0;
      case(cntrl.aluop)
        3'b000: begin
          alu_o = $signed(read_data1) + $signed(alu_i_2);
          if(cntrl.jump)
            is_taken='1;
        end
        3'b001:begin
          alu_o = $signed(read_data1) - $signed(alu_i_2);
        end
        3'b010: begin
          alu_o = $signed(read_data1)* $signed(alu_i_2) ;
        end
        3'b011: begin
          alu_o = read_data1 | alu_i_2;
        end
        3'b100: begin
          alu_o =  read_data1 & alu_i_2;
        end
        3'b101: begin
          alu_o = read_data1 ^ alu_i_2 ;
        end
        3'b110: begin
        if(read_data1=='0) 
	alu_o = 1;
	else
	alu_o = 0;
	
        if (read_data1=='0) 
	is_taken = 1;
	else
	is_taken = 0;
	end

        3'b111 : begin
        if (read_data1==alu_i_2) 
	alu_o = 1;
	else 
	alu_o = 0;

        if (read_data1==alu_i_2) 
	is_taken = 1;
	else
	is_taken = 0;
        end

        default : begin
          is_taken='0;
          cntrl.jump ='0;
        end
      endcase
    end
 
endmodule
