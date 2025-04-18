module top (
    input clk,
    input reset
);

  wire [31:0] curr_pc;
  wire [31:0] next_pc;
  wire [31:0] cur_4_pc;
  assign cur_4_pc = curr_pc + 4;
  assign next_pc = jump   ? {curr_pc[31:28], adr[25:0], 2'b00} :branch ? (cur_4_pc + {{14{imm[15]}}, imm, 2'b00}) :cur_4_pc;

  wire [31:0] instruction;

  wire [ 5:0] opcode;
  wire [25:0] adr;
  wire [ 4:0] rs;
  wire [ 4:0] rt;
  wire [ 4:0] rd;
  wire [ 4:0] shamt;
  wire [ 5:0] funct;
  wire [15:0] imm;

  wire [ 4:0] reg_read;
  assign reg_read = reg_dst ? rd : rt;

  wire [31:0] write_data;
  wire [31:0] reg_rs;
  wire [31:0] reg_rt;
  wire reg_write;

  wire mem_write;
  wire [3:0] alu_op;
  wire mem_read;
  wire jump;
  wire branch;
  wire alu_src;
  wire mem_to_reg;
  wire reg_dst;

  wire [31:0] alu_in1;
  wire [31:0] alu_in2;
  wire [31:0] alu_out;
  wire alu_zero;

  wire [31:0] read_data;

  assign alu_in1 = reg_rs;
  assign alu_in2 = alu_src ? {{16{imm[15]}}, imm} : reg_rt;

  assign write_data = mem_to_reg ? read_data : alu_out;


  pc pc_inst (
      .clk(clk),
      .reset(reset),
      .next_pc(next_pc),
      .curr_pc(curr_pc)
  );

  instruction_fetch IF (
      .clk(clk),
      .pc(curr_pc),
      .instruction(instruction)
  );

  instruction_decode ID (
      .instruction(instruction),
      .opcode(opcode),
      .adr(adr),
      .rs(rs),
      .rt(rt),
      .rd(rd),
      .shamt(shamt),
      .funct(funct),
      .imm(imm)
  );

  reg_file RF (
      .clk(clk),
      .rs(rs),
      .rt(rt),
      .rd(reg_read),
      .write_data(write_data),
      .reg_rs(reg_rs),
      .reg_rt(reg_rt),
      .reg_write(reg_write)
  );

  control_unit CTRL (
      .opcode(opcode),
      .funct(funct),
      .mem_write(mem_write),
      .reg_write(reg_write),
      .alu_op(alu_op),
      .mem_read(mem_read),
      .jump(jump),
      .branch(branch),
      .alu_src(alu_src),
      .mem_to_reg(mem_to_reg),
      .reg_dst(reg_dst)
  );

  alu EXEC (
      .a(alu_in1),
      .b(alu_in2),
      .alu_op(alu_op),
      .result(alu_out),
      .zero(zero)
  );

  data_memory MEM (
      .clk(clk),
      .mem_write(mem_write),
      .addr(alu_out),
      .write_data(reg_rt),
      .read_data(read_data)
  );

endmodule
