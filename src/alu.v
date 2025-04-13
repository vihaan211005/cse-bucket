module alu (
  input [31:0] a,
  input [31:0] b,
  input [3:0] alu_op,
  output reg [31:0] result,
  output reg zero
);
  wire [31:0] add_result, sub_result, mul_result, lshift_result, rshift_result;

  adder adder_inst (
    .a(a),
    .b(b),
    .result(add_result)
  );

  subtractor subtractor_inst (
    .a(a),
    .b(b),
    .result(sub_result)
  );

  multiplier multiplier_inst (
    .a(a),
    .b(b),
    .result(mul_result)
  );

  left_shift left_shift_inst (
    .a(a),
    .b(b),
    .result(lshift_result)
  );

  right_shift right_shift_inst (
    .a(a),
    .b(b),
    .result(rshift_result)
  );

  always @(*) begin
    case (alu_op)
      4'b0000: result = add_result;
      4'b0001: result = sub_result;
      4'b0010: result = mul_result;
      4'b0011: result = lshift_result;
      4'b0100: result = rshift_result;
      default: result = 0;
    endcase
    zero = (result == 0) ? 1'b1 : 1'b0;
  end
endmodule

module adder (
  input [31:0] a,
  input [31:0] b,
  output reg [31:0] result
);
  always @(*) begin
    result = a + b;
  end
endmodule

module subtractor (
  input [31:0] a,
  input [31:0] b,
  output reg [31:0] result
);
  always @(*) begin
    result = a - b;
  end
endmodule

module multiplier (
  input [31:0] a,
  input [31:0] b,
  output reg [31:0] result
);
  always @(*) begin
    result = a * b;
  end
endmodule

module left_shift (
  input [31:0] a,
  input [31:0] b,
  output reg [31:0] result
);
  always @(*) begin
    result = a << b;
  end
endmodule

module right_shift (
  input [31:0] a,
  input [31:0] b,
  output reg [31:0] result
);
  always @(*) begin
    result = a >> b;
  end
endmodule
