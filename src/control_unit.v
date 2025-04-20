module control_unit (
    input [5:0] opcode,
    input [5:0] funct,
    output reg mem_write,
    output reg reg_write,
    output reg [3:0] alu_op,
    output reg mem_read,
    output reg jump,
    output reg branch,
    output reg alu_src,
    output reg mem_to_reg,
    output reg reg_dst
);

  always @(*) begin
    mem_write  = 0;
    reg_write  = 0;
    alu_op     = 4'b0000;
    mem_read   = 0;
    jump       = 0;
    branch     = 0;
    alu_src    = 0;
    mem_to_reg = 0;
    reg_dst    = 0;
    case (opcode)
      6'b000000: begin  // R-type
        case (funct)
          6'b000000: reg_write = 0;
          default:   reg_write = 1;
        endcase
        case (funct)
          6'b100000: alu_op = 4'b0000;  // ADD
          6'b100010: alu_op = 4'b0001;  // SUB
          default:   alu_op = 4'bxxxx;  // Undefined
        endcase
      end
      6'b001101: begin  // ORI
        reg_write = 1;
        alu_src = 1;
        alu_op = 4'b1001;
      end
      6'b001111: begin  // LUI
        reg_write = 1;
        alu_src = 1;
        alu_op = 4'b1010;
      end
      6'b100011: begin  // LW
        reg_write = 1;
        mem_read  = 1;
        mem_to_reg = 1;
        alu_op    = 4'b0000; // ADD
      end
      6'b101011: begin  // SW
        mem_write = 1;
        alu_op    = 4'b0000; // ADD
      end
      6'b000100: begin  // BEQ
        branch = 1;
        alu_op = 4'b0001;  // SUB
      end
      6'b000010: begin  // J
        jump   = 1;
        alu_op = 4'bxxxx;  // Don't care
      end
      default: begin
        alu_op = 4'bxxxx;  // Undefined
      end
    endcase
  end

endmodule
