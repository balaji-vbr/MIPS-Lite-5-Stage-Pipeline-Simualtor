module top();
  parameter CLOCK_PERIOD = 10;
  localparam HALF_CYCLE = CLOCK_PERIOD/2;

  bit clock;
  logic rst;

  MIPS_Processor DUT(clock,rst);



  always #HALF_CYCLE clock = ~clock;
  initial 
    begin
      rst ='1;
      repeat (2)@(posedge clock);
      rst ='0;
    end

  initial 
    begin 
      $dumpfile("dump.vcd");
      $dumpvars;
    end

endmodule