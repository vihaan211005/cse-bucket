module instruction_decode (
    input  [31:0] instruction,
    output [ 5:0] opcode,
    output [25:0] adr,
    output [ 4:0] rs,
    output [ 4:0] rt,
    output [ 4:0] rd,
    output [ 4:0] shamt,
    output [ 5:0] funct,
    output [15:0] imm,
    output reg regwrite,
    output reg memwrite,
    output reg memread,
    output reg [3:0] aluOp,
    output reg immReg,
    output reg regDst
);
  assign opcode = instruction[31:26];  // R, I, J
  assign adr = instruction[25:0];  // J
  assign rs = instruction[25:21];  // R, I
  assign rt = instruction[20:16];  // R, I
  assign rd = instruction[15:11];  // R
  assign shamt = instruction[10:6];  // R
  assign funct = instruction[5:0];  // R
  assign imm = instruction[15:0];  // I
  
  always @(*) begin
    $display("Got instruction %b", instruction);
    case (opcode)
    6'b0000: begin      
        case (funct)
            6'h20: begin
                regwrite = 1'b1;
                memread = 1'b0;
                memwrite = 1'b0;
                aluOp=4'b0000;
                immReg=1'b0;
                regDst=1'b1;
            end
            6'h21: begin
                regwrite = 1'b1;
                memread = 1'b0;
                memwrite = 1'b0;
                aluOp=4'b0000; // Same ALU operation as add, but unsigned
                immReg=1'b0;
                regDst=1'b1;
                $display("Performing addu for reg %d and reg %d to reg %d", rs, rt, rd);
            end
            6'h22: begin
                regwrite = 1'b1;
                memread = 1'b0;
                memwrite = 1'b0;
                aluOp=4'b0001;
                immReg=1'b0;
                regDst=1'b1;
            end
            6'h24: begin
                regwrite = 1'b1;
                memread = 1'b0;
                memwrite = 1'b0;
                aluOp=4'b0010;
                immReg=1'b0;
                regDst=1'b1;
            end
        endcase
    end
    6'h8: begin // add immediate
        regwrite = 1'b1;
        memread = 1'b0;
        memwrite = 1'b0;
        aluOp=4'b0000;
        immReg=1'b1;
        regDst=1'b0;
        $display("Performing addi for reg %d, %d to reg %d", rs, imm, rt);
    end
    6'h23: begin // load word
        regwrite = 1'b1;
        memread = 1'b1;
        memwrite = 1'b0;
        aluOp=4'b0000;
        immReg=1'b1;
        regDst=1'b0;
        $display("Performing lw for reg %d, %d to reg %d", rs, imm, rd);
    end
    6'h2B: begin // store word
        regwrite = 1'b0;
        memread = 1'b0;
        memwrite = 1'b1;
        aluOp=4'b0000;
        immReg=1'b1;
        regDst=1'b0;
        $display("Performing sw for reg %d, %d to mem[reg %d + %d]", rd, rs, imm);
    end
    endcase
  end
endmodule
