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
    output reg regDst,
    output reg jump,
    output reg branch
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
    
    // Default values
    jump = 1'b0;
    branch = 1'b0;
    regwrite = 1'b0;
    memread = 1'b0;
    memwrite = 1'b0;
    aluOp = 4'b0000;
    immReg = 1'b0;
    regDst = 1'b0;
    
    case (opcode)
    6'b000000: begin      
        case (funct)
            6'h20: begin // add
                regwrite = 1'b1;
                aluOp = 4'b0000; // add
                immReg = 1'b0;
                regDst = 1'b1;
                $display("Performing add for reg %d and reg %d to reg %d", rs, rt, rd);
            end
            6'h21: begin // addu
                regwrite = 1'b1;
                aluOp = 4'b0000; // Same ALU operation as add, but unsigned
                immReg = 1'b0;
                regDst = 1'b1;
                $display("Performing addu for reg %d and reg %d to reg %d", rs, rt, rd);
            end
            6'h22: begin // sub
                regwrite = 1'b1;
                aluOp = 4'b0001; // sub
                immReg = 1'b0;
                regDst = 1'b1;
                $display("Performing sub for reg %d and reg %d to reg %d", rs, rt, rd);
            end
            6'h24: begin // and
                regwrite = 1'b1;
                aluOp = 4'b0010; // and
                immReg = 1'b0;
                regDst = 1'b1;
                $display("Performing and for reg %d and reg %d to reg %d", rs, rt, rd);
            end
            6'h25: begin // or
                regwrite = 1'b1;
                aluOp = 4'b0010; // Using ALU for logical OR
                immReg = 1'b0;
                regDst = 1'b1;
                $display("Performing or for reg %d and reg %d to reg %d", rs, rt, rd);
            end
            6'h00: begin // sll (shift left logical)
                regwrite = 1'b1;
                aluOp = 4'b0011; // lshift
                immReg = 1'b0; // Use rt as the value to shift
                regDst = 1'b1; // Write to rd
                $display("Performing sll for reg %d by %d to reg %d", rt, shamt, rd);
            end
            6'h02: begin // srl (shift right logical)
                regwrite = 1'b1;
                aluOp = 4'b0100; // rshift
                immReg = 1'b0;
                regDst = 1'b1;
                $display("Performing srl for reg %d by %d to reg %d", rt, shamt, rd);
            end
            default: begin
                $display("Unknown R-type instruction with function code: %h", funct);
            end
        endcase
    end
    6'h08: begin // addi
        regwrite = 1'b1;
        aluOp = 4'b0000; // add
        immReg = 1'b1;
        regDst = 1'b0;
        $display("Performing addi for reg %d, %d to reg %d", rs, imm, rt);
    end
    6'h09: begin // addiu (add immediate unsigned)
        regwrite = 1'b1;
        aluOp = 4'b0000; // add
        immReg = 1'b1;
        regDst = 1'b0;
        $display("Performing addiu for reg %d, %d to reg %d", rs, imm, rt);
    end
    6'h0C: begin // andi
        regwrite = 1'b1;
        aluOp = 4'b0010; // and
        immReg = 1'b1;
        regDst = 1'b0;
        $display("Performing andi for reg %d, %d to reg %d", rs, imm, rt);
    end
    6'h0D: begin // ori
        regwrite = 1'b1;
        aluOp = 4'b0010; // Using ALU for logical OR with immediate
        immReg = 1'b1;
        regDst = 1'b0;
        $display("Performing ori for reg %d, %d to reg %d", rs, imm, rt);
    end
    6'h0F: begin // lui (Load Upper Immediate)
        regwrite = 1'b1;
        aluOp = 4'b0011; // Using left shift for lui
        immReg = 1'b1;
        regDst = 1'b0;
        $display("Performing lui with immediate %d to reg %d", imm, rt);
    end
    6'h23: begin // lw
        regwrite = 1'b1;
        memread = 1'b1;
        aluOp = 4'b0000; // add (for address calculation)
        immReg = 1'b1;
        regDst = 1'b0;
        $display("Performing lw for reg %d, %d to reg %d", rs, imm, rt);
    end
    6'h2B: begin // sw
        memwrite = 1'b1;
        aluOp = 4'b0000; // add (for address calculation)
        immReg = 1'b1;
        regDst = 1'b0;
        $display("Performing sw for reg %d, %d to mem[%d]", rt, rs, imm);
    end
    6'h04: begin // beq
        aluOp = 4'b0001; // sub (for comparison)
        immReg = 1'b0; // Use rt directly for comparison
        branch = 1'b1;
        $display("Performing beq comparing reg %d and reg %d with offset %d", rs, rt, imm);
    end
    6'h05: begin // bne (branch if not equal)
        aluOp = 4'b0001; // sub (for comparison)
        immReg = 1'b0; // Use rt directly for comparison
        branch = 1'b1;
        // Note: The top module will need to check !zero for bne
        $display("Performing bne comparing reg %d and reg %d with offset %d", rs, rt, imm);
    end
    6'h02: begin // j (jump)
        jump = 1'b1;
        $display("Performing jump to address %d", adr);
    end
    6'h03: begin // jal (jump and link)
        regwrite = 1'b1; // Write to register 31 (ra)
        jump = 1'b1;
        $display("Performing jump and link to address %d", adr);
    end
    default: begin
        $display("Unknown opcode: %b", opcode);
    end
    endcase
  end
endmodule
