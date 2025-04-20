module reg_file (
    input clk,
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    input [31:0] write_data,
    output [31:0] reg_rs,
    output [31:0] reg_rt,
    input reg_write
);
  reg [31:0] regs[0:63];

  assign reg_rs = (rs == 0) ? 32'b0 : regs[rs];
  assign reg_rt = (rt == 0) ? 32'b0 : regs[rt];

  always @(posedge clk) begin
    if (reg_write && rd != 0) regs[rd] <= write_data;
  end
endmodule
