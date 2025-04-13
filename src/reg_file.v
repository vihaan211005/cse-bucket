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
  reg [31:0] regs[0:31];
  assign reg_rs = regs[rs];
  assign reg_rt = regs[rt];
  always @(posedge clk) if (reg_write) regs[rd] <= write_data;
endmodule

module reg_file_float (
    input clk,
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    input [31:0] write_data,
    output [31:0] reg_rs,
    output [31:0] reg_rt,
    input reg_write
);
  reg [31:0] regs[0:31];
  assign reg_rs = regs[rs];
  assign reg_rt = regs[rt];
  always @(posedge clk) if (reg_write) regs[rd] <= write_data;
endmodule

