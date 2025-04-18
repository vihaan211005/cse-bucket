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
  end

endmodule
