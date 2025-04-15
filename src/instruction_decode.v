module instruction_decode (
    input  [31:0] instruction,
    output [ 5:0] opcode,
    output [25:0] adr,
    output [ 4:0] rs,
    output [ 4:0] rt,
    output [ 4:0] rd,
    output [ 4:0] shamt,
    output [ 6:0] funct,
    output [15:0] imm
);
  assign opcode = instruction[31:26];  // R, I, J
  assign adr = instruction[25:0];  // J
  assign rs = instruction[25:21];  // R, I
  assign rt = instruction[20:16];  // R, I
  assign rd = instruction[15:11];  // R
  assign shamt = instruction[11:7];  // R
  assign funct = instruction[6:0];  // R
  assign imm = instruction[15:0];  // I
endmodule
