module top();
  parameter CLOCK_PERIOD = 10;
  localparam HALF_PERIOD = CLOCK_PERIOD/2;

  bit clk;
  logic rst;

  MIPS_Processor DUT(clk,rst);



  always #HALF_PERIOD clk = ~clk;
  initial 
    begin
      rst ='1;
      repeat (2)@(posedge clk);
      rst ='0;
    end

  initial 
    begin 
      $dumpfile("dump.vcd");
      $dumpvars;
    end

endmodule