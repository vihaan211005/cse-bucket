`timescale 1ns / 1ps

module tb_top;

  reg clk;
  reg reset;

  top uut (
      .clk  (clk),
      .reset(reset)
  );

  always #5 clk = ~clk;

  initial begin
    clk   = 0;
    reset = 1;

    #20;
    reset = 0;

    #200;

    $finish;
  end

  initial begin
    $monitor("Time=%0t | Reset=%b | PC=%h", $time, reset, uut.curr_pc);
  end

  initial begin
    $dumpfile("top_tb.vcd");
    $dumpvars(0, tb_top);
    $dumpvars(0, uut.RF.regs[0]);
    $dumpvars(0, uut.RF.regs[1]);
    $dumpvars(0, uut.RF.regs[2]);
    $dumpvars(0, uut.RF.regs[3]);
    $dumpvars(0, uut.RF.regs[4]);
    $dumpvars(0, uut.RF.regs[5]);
    $dumpvars(0, uut.RF.regs[6]);
    $dumpvars(0, uut.RF.regs[7]);
    $dumpvars(0, uut.RF.regs[8]);
    $dumpvars(0, uut.RF.regs[9]);
  end

endmodule
