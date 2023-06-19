module tb();
  parameter CYCLE_TIME = 10;
  localparam ON_TIME = CYCLE_TIME/2;

  bit clk;
  logic reset;

  MIPS_Lite_Simulator DUT(clk,reset);



  always #ON_TIME clk = ~clk;
  initial 
    begin
      reset ='1;
      repeat (2) @(posedge clk);
      reset ='0;
    end

  initial 
    begin 
      $dumpfile("dump.vcd");
      $dumpvars;
     
     
    end

endmodule
