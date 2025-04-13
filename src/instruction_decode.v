module instruction_decode (
    input  [31:0] instruction,
    output [ 5:0] opcode,
    output [ 4:0] rs,
    output [ 4:0] rt,
    output [ 4:0] rd,
    output [15:0] imm
);
  assign opcode = instr[31:26];  // R, I, J
  assign adr = instr[25:0];  // J
  assign rs = instr[25:21];  // R, I
  assign rt = instr[20:16];  // R, I
  assign rd = instr[15:11];  // R
  assign shamt = instr[11:7];  // R
  assign funct = instr[6:0];  // R
  assign imm = instr[15:0];  // I
endmodule
