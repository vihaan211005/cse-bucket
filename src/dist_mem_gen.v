module dist_mem_gen_data (
    input  wire        clk,
    input  wire [ 7:0] a,
    input  wire [ 7:0] dpra,
    input  wire [31:0] d,
    input  wire        we,
    output wire [31:0] dpo
);
  reg [31:0] mem[0:255];

  always @(posedge clk) begin
    if (we) mem[a] <= d;
  end

  assign dpo = mem[dpra];
endmodule

module dist_mem_gen_instr (
    input  wire        clk,
    input  wire [ 7:0] a,
    input  wire [ 7:0] dpra,
    input  wire [31:0] d,
    input  wire        we,
    output wire [31:0] dpo
);
  reg [31:0] mem[0:255];
  integer i;
  initial begin
    for (i = 3; i < 256; i = i + 1) mem[i] = 32'd0;

    mem[0] = 32'h00000000;
    mem[1] = 32'h3c013dcc;
    mem[2] = 32'h3421cccd;
    mem[3] = 32'h00000000;
  end

  always @(posedge clk) begin
    if (we) mem[a] <= d;
  end

  assign dpo = mem[dpra];
endmodule
