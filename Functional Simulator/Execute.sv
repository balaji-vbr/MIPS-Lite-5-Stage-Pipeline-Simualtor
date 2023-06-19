`include "mips_pkg.sv"
module Execute(read_data_1, read_data_2, imm_data, pc_plus_4 , cntrl, alu_o, new_addr, is_taken, write_data);
  import mips_pkg::*;
   
  input logic [DATA-1:0] read_data_1;
  input logic [DATA-1:0] read_data_2;
  input logic [DATA-1:0] imm_data;
  input logic [ADDRESS_WIDTH-1:0] pc_plus_4;
  input Control cntrl;
  
  output logic [DATA-1:0] alu_o;
  output logic [DATA-1:0] new_addr;
  logic [DATA-1:0] branch_addr_new;
  output logic [DATA-1:0] write_data;
  
  logic zero;
  output logic is_taken;
  
  
  logic invalid_addr;
  logic [DATA-1:0] alu_i;
  
  

  assign write_data = read_data_2;
  
  assign alu_i = (cntrl.srcReg2) ? read_data_2 : imm_data;

  assign new_addr = (cntrl.jump) ? read_data_1 : branch_addr_new;

  assign {invalid_addr, branch_addr_new} = $signed(pc_plus_4) + $signed(imm_data<<2);


  always_comb
    begin
      is_taken ='0;
      zero= '0;
      case(cntrl.ALU_op)
        3'b000: begin
          alu_o= $signed(read_data_1) + $signed(alu_i);
          if(cntrl.jump)
            is_taken='1;
        end
        3'b001:begin
          alu_o= $signed(read_data_1) - $signed(alu_i);
        end
        3'b010: begin
          alu_o= $signed(read_data_1)* $signed(alu_i) ;
        end
        3'b011: begin
          alu_o= read_data_1 | alu_i;
        end
        3'b100: begin
          alu_o=  read_data_1 & alu_i;
        end
        3'b101: begin
          alu_o= read_data_1 ^ alu_i ;
        end
        3'b110: begin
          alu_o= (read_data_1=='0) ? 1 : '0;
          is_taken = (read_data_1=='0) ? 1 : '0;
        end
        3'b111 : begin
          alu_o= (read_data_1==alu_i) ? 1 : '0;
          is_taken = (read_data_1==alu_i) ? 1 : '0;
        end
        default : begin
          is_taken='0;
          cntrl.jump ='0;
        end
      endcase
    end

endmodule
