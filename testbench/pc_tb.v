module pc_tb;

  reg clk, reset, enable;
  wire [31:0] curr_pc;
  reg [31:0] next_pc;

  pc uut (
      .clk(clk),
      .reset(reset),
      .enable(enable),
      .next_pc(next_pc),
      .curr_pc(curr_pc)
  );

  always #5 clk = ~clk;  // Clock toggles every 5 time units

  initial begin
    $display("Time\tReset\tEnable\tNext_PC\t\tCurr_PC");
    $monitor("%g\t%b\t%b\t%h\t%h", $time, reset, enable, next_pc, curr_pc);

    clk = 0;
    reset = 1;
    enable = 0;
    next_pc = 32'h00000000;
    #10 reset = 0;

    #10 enable = 1;
    next_pc = 32'h00000004;
    #10 next_pc = 32'h00000008;
    #10 enable = 0;
    #10 next_pc = 32'h0000000C;

    #10 $finish;
  end

endmodule
