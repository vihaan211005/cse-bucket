module data_memory (
    input clk,
    input mem_write,
    input [31:0] addr,
    input [31:0] write_data,
    output [31:0] read_data
);

  wire [7:0] word_addr = addr[9:2];

  dist_mem_gen_0 data_mem (
      .a   (word_addr),
      .d   (write_data),
      .dpra(word_addr),
      .clk (clk),
      .we  (mem_write),
      .dpo (read_data)
  );

endmodule
