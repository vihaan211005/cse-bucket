`timescale 1ns / 1ps

module alu_tb;
  reg  [31:0] a;
  reg  [31:0] b;
  reg  [ 3:0] alu_op;
  wire [31:0] result;

  alu uut (
      .a(a),
      .b(b),
      .alu_op(alu_op),
      .result(result)
  );

  task test_case(input [31:0] op_a, input [31:0] op_b, input [3:0] op, input [255:0] desc);
    begin
      a = op_a;
      b = op_b;
      alu_op = op;
      #10;
      $display("Test: %-40s | a = %0d | b = %0d | alu_op = %b | result = %0d (hex: %h)", desc, a, b, alu_op, result, result);
    end
  endtask

  initial begin
    $dumpfile("alu_tb.vcd");
    $dumpvars(0, alu_tb);

    // ADD
    test_case(32'd10, 32'd20, 4'b0000, "ADD: 10 + 20");
    test_case(32'd0, 32'd0, 4'b0000, "ADD: 0 + 0");
    test_case(32'd4294967295, 32'd1, 4'b0000, "ADD: overflow check");

    // SUB
    test_case(32'd50, 32'd20, 4'b0001, "SUB: 50 - 20");
    test_case(32'd20, 32'd50, 4'b0001, "SUB: 20 - 50");
    test_case(32'd0, 32'd0, 4'b0001, "SUB: 0 - 0");

    // MUL
    test_case(32'd7, 32'd8, 4'b0010, "MUL: 7 * 8");
    test_case(32'd0, 32'd100, 4'b0010, "MUL: 0 * 100");
    test_case(32'd1234, 32'd4321, 4'b0010, "MUL: large number");

    // LSHIFT
    test_case(32'd1, 32'd3, 4'b0011, "LSHIFT: 1 << 3");
    test_case(32'd255, 32'd4, 4'b0011, "LSHIFT: 255 << 4");

    // RSHIFT
    test_case(32'd128, 32'd3, 4'b0100, "RSHIFT: 128 >> 3");
    test_case(32'd1024, 32'd10, 4'b0100, "RSHIFT: 1024 >> 10");

    // INVALID OP
    test_case(32'd42, 32'd24, 4'b1111, "Invalid op: should return 0");

    $finish;
  end
endmodule
