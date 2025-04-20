module pc (
    input             clk,
    input             reset,
    input      [31:0] next_pc,
    output reg [31:0] curr_pc
);

  always @(posedge clk or posedge reset) begin
    if (reset) curr_pc <= 32'h00000000;
    else curr_pc <= next_pc;
  end

endmodule
