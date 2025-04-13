`timescale 1ns / 1ps

module fpu_tb;
  reg  [31:0] a;
  reg  [31:0] b;
  reg  [ 2:0] fpu_op;
  wire [31:0] result;

  fpu uut (
      .a(a),
      .b(b),
      .fpu_op(fpu_op),
      .result(result)
  );

  task test_case(input [31:0] op_a, input [31:0] op_b, input [2:0] op, input [255:0] desc);
    begin
      a = op_a;
      b = op_b;
      fpu_op = op;
      #10;
      $display("Test: %-40s | a = %h | b = %h | fpu_op = %b | result = %h", desc, op_a, op_b, op, result);
    end
  endtask

  initial begin
    $dumpfile("fpu_tb.vcd");
    $dumpvars(0, fpu_tb);

    // MULTIPLY
    test_case(32'h40200000, 32'h40800000, 3'b000, "2.5 * 4.0");
    test_case(32'h00000000, 32'h3f800000, 3'b000, "0 * 1");
    test_case(32'hbf800000, 32'h3f800000, 3'b000, "-1 * 1");
    test_case(32'h7f800000, 32'h3f800000, 3'b000, "inf * 1");
    test_case(32'hff800000, 32'h3f800000, 3'b000, "-inf * 1");
    test_case(32'h7fc00000, 32'h3f800000, 3'b000, "NaN * 1");

    // FLOOR
    test_case(32'h40bc0000, 32'h00000000, 3'b001, "floor(5.875)");
    test_case(32'hbf99999a, 32'h00000000, 3'b001, "floor(-1.2)");
    test_case(32'h3f000000, 32'h00000000, 3'b001, "floor(0.5)");
    test_case(32'h80000000, 32'h00000000, 3'b001, "floor(-0.0)");
    test_case(32'h7f800000, 32'h00000000, 3'b001, "floor(inf)");
    test_case(32'h7fc00000, 32'h00000000, 3'b001, "floor(NaN)");

    // FLOOR TO INT
    test_case(32'h406ccccd, 32'h00000000, 3'b010, "floor_to_int(3.7)");
    test_case(32'hbe99999a, 32'h00000000, 3'b010, "floor_to_int(-0.3)");
    test_case(32'hc1a00000, 32'h00000000, 3'b010, "floor_to_int(-20.0)");
    test_case(32'h3e4ccccd, 32'h00000000, 3'b010, "floor_to_int(0.2)");

    // FLOAT COMPARE
    test_case(32'h40400000, 32'h40800000, 3'b011, "compare(3.0, 4.0)");
    test_case(32'h40a00000, 32'h40800000, 3'b011, "compare(5.0, 4.0)");
    test_case(32'h3f800000, 32'h3f800000, 3'b011, "compare(1.0, 1.0)");

    // DEFAULT
    test_case(32'h40400000, 32'h40800000, 3'b111, "undefined op");

    $finish;
  end
endmodule
