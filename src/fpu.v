module fpu (
    input [31:0] a,
    input [31:0] b,
    input [2:0] fpu_op,
    output reg [31:0] result
);
  wire [31:0] float_mult_result;
  wire [31:0] floor_result;
  wire [31:0] floor_to_int_result;
  wire [1:0] float_compare_result;

  float_multiplier fm (
      .a(a),
      .b(b),
      .result(float_mult_result)
  );

  floor_unit floor (
      .a(a),
      .result(floor_result)
  );

  floor_to_int_unit floor_to_int (
      .a(a),
      .result(floor_to_int_result)
  );

  float_comparator fc (
      .a(a),
      .b(b),
      .result(float_compare_result)
  );

  always @(*) begin
    case (fpu_op)
      3'b000:  result = float_mult_result;
      3'b001:  result = floor_result;
      3'b010:  result = floor_to_int_result;
      3'b011:  result = {30'b0, float_compare_result};
      default: result = 32'b0;
    endcase
  end
endmodule

module float_multiplier (
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] result
);
  wire sign_a = a[31];
  wire sign_b = b[31];
  wire [7:0] exp_a = a[30:23];
  wire [7:0] exp_b = b[30:23];
  wire [22:0] frac_a = a[22:0];
  wire [22:0] frac_b = b[22:0];

  wire sign_res = sign_a ^ sign_b;

  wire [23:0] mantissa_a = (exp_a == 0) ? {1'b0, frac_a} : {1'b1, frac_a};
  wire [23:0] mantissa_b = (exp_b == 0) ? {1'b0, frac_b} : {1'b1, frac_b};

  wire [47:0] mantissa_mul = mantissa_a * mantissa_b;

  wire leading_one = mantissa_mul[47];
  wire [22:0] normalized_frac = leading_one ? mantissa_mul[46:24] : mantissa_mul[45:23];

  wire [7:0] exp_sum = exp_a + exp_b - 8'd127;
  wire [7:0] normalized_exp = leading_one ? (exp_sum + 1) : exp_sum;

  wire is_zero = (a[30:0] == 0) || (b[30:0] == 0);
  wire is_inf = (exp_a == 8'hFF && frac_a == 0) || (exp_b == 8'hFF && frac_b == 0);
  wire is_nan = (exp_a == 8'hFF && frac_a != 0) || (exp_b == 8'hFF && frac_b != 0);

  assign result = is_nan ? 32'h7FC00000 :
                  is_inf ? {sign_res, 8'hFF, 23'd0} :
                  is_zero ? 32'd0 :
                  {sign_res, normalized_exp, normalized_frac};
endmodule

module floor_unit (
    input [31:0] a,
    output reg [31:0] result
);
  wire sign = a[31];
  wire [7:0] exponent = a[30:23];
  wire [22:0] mantissa = a[22:0];

  integer shift;
  reg [22:0] int_mantissa;

  always @(*) begin
    if (exponent < 8'd127) begin
      result = {sign, 31'b0};
    end else begin
      shift = exponent - 8'd127;
      if (shift >= 23) begin
        result = a;
      end else begin
        int_mantissa = mantissa >> (23 - shift);
        int_mantissa = int_mantissa << (23 - shift);
        result = {sign, exponent, int_mantissa};
      end
    end
  end
endmodule

module floor_to_int_unit (
    input [31:0] a, 
    output reg [31:0] result     
);
    wire sign = a[31];
    wire [7:0] exponent = a[30:23];
    wire [22:0] mantissa = a[22:0];

    wire [23:0] full_mantissa = {1'b1, mantissa}; 
    integer shift;
    integer int_part;
    integer fractional_bits;

    always @(*) begin
        if (exponent < 8'd127) begin
            result = sign ? -32'd1 : 32'd0;
        end else if (exponent > 8'd158) begin
            result = sign ? 32'h80000000 : 32'h7FFFFFFF; 
        end else begin
            shift = exponent - 8'd127;
            if (shift >= 23) begin
                int_part = full_mantissa << (shift - 23);
                fractional_bits = 0;
            end else begin
                int_part = full_mantissa >> (23 - shift);
                fractional_bits = full_mantissa & ((1 << (23 - shift)) - 1);
            end

            if (sign) begin
                if (fractional_bits != 0)
                    int_part = -int_part - 1; 
                else
                    int_part = -int_part;
            end else begin
                int_part = int_part;
            end

            result = int_part;
        end
    end
endmodule

module float_comparator (
    input [31:0] a,
    input [31:0] b,
    output reg [1:0] result
);
  wire sign_a = a[31];
  wire sign_b = b[31];
  wire [7:0] exp_a = a[30:23];
  wire [7:0] exp_b = b[30:23];
  wire [22:0] frac_a = a[22:0];
  wire [22:0] frac_b = b[22:0];

  wire is_nan_a = (exp_a == 8'hFF && frac_a != 0);
  wire is_nan_b = (exp_b == 8'hFF && frac_b != 0);
  wire is_inf_a = (exp_a == 8'hFF && frac_a == 0);
  wire is_inf_b = (exp_b == 8'hFF && frac_b == 0);
  wire is_zero_a = (a[30:0] == 0);
  wire is_zero_b = (b[30:0] == 0);

  always @(*) begin
    if (is_nan_a || is_nan_b) begin
      result = 2'b11;
    end else if (is_inf_a && is_inf_b) begin
      if (sign_a == sign_b) begin
        result = 2'b00;
      end else begin
        result = 2'b01;
      end
    end else if (is_inf_a) begin
      if (sign_a) begin
        result = 2'b10;
      end else begin
        result = 2'b01;
      end
    end else if (is_inf_b) begin
      if (sign_b) begin
        result = 2'b01;
      end else begin
        result = 2'b10;
      end
    end else if (is_zero_a && is_zero_b) begin
      result = 2'b00;
    end else if (is_zero_a) begin
      if (sign_b) begin
        result = 2'b10;
      end else begin
        result = 2'b01;
      end
    end else if (is_zero_b) begin
      if (sign_a) begin
        result = 2'b01;
      end else begin
        result = 2'b10;
      end
    end else begin
      if (exp_a != exp_b) begin
        if (exp_a > exp_b) begin
          result = sign_a ? 2'b10 : 2'b01;
        end else begin
          result = sign_b ? 2'b01 : 2'b10;
        end
      end else begin
        if (frac_a > frac_b) begin
          result = sign_a ? 2'b10 : 2'b01;
        end else if (frac_a < frac_b) begin
          result = sign_b ? 2'b01 : 2'b10;
        end else begin
          result = 2'b00;
        end
      end
    end
  end
endmodule
