module instruction_fetch (
    input clk,
    input [31:0] pc,
    output [31:0] instruction
);

  wire [7:0] addr = pc[9:2];

  dist_mem_gen_instr instruction_mem (
      .a   (addr),
      .d   (32'b0),
      .dpra(addr),
      .clk (clk),
      .we  (1'b0),
      .dpo (instruction)
  );

endmodule
