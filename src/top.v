`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2025 11:27:44 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//module program_counter(
//    input clk,
//    input rst, 
//    input 
//);
//endmodule
//module control(
//    input clk,
//    input rst,
//    input [,
//    output [

//)

//endmodule

module program_counter(
    input clk,
    input rst,
    input [31:0] pc_in,
    output reg [31:0] pc_out
);
    initial begin
        pc_out = 32'd0;
    end
    
    always @(posedge clk) begin
        pc_out <= pc_in;
    end
endmodule

module top(
    input clk
 );
    wire [31:0] dummy_wire;
    wire [31:0] PC_out;
    wire [31:0] PC_in;
    program_counter pc(
        .clk(clk),
        .rst(1'b0),
        .pc_in(PC_in),
        .pc_out(PC_out)
    );
    wire [31:0] instruction;
    instruction_fetch fetch(
        .clk(clk),
        .pc(PC_out),
        .instruction(instruction)
    );

    
    wire [ 5:0] opcode;
    wire [25:0] adr;
    wire [ 4:0] rs;
    wire [ 4:0] rt;
    wire [ 4:0] rd;
    wire [ 4:0] shamt;
    wire [ 5:0] funct;
    wire [15:0] imm;
    wire regwrite;
    wire memwrite;
    wire memread;
    wire [3:0] aluOp;
    wire immReg;

    instruction_decode control(
        .instruction(instruction),
        .opcode(opcode),
        .adr(adr),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .shamt(shamt),
        .funct(funct),
        .imm(imm),
        .regwrite(regwrite),
        .memwrite(memwrite),
        .memread(memread),
        .aluOp(aluOp),
        .immReg(immReg)
    );    
    wire [31:0] reg_rs;
    wire [31:0] reg_rt;
    wire [31:0] write_data;
    
    reg_file rf(
        .clk(clk),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .write_data(write_data),
        .reg_rs(reg_rs),
        .reg_rt(reg_rt),
        .reg_write(regwrite)
    );

    wire [31:0] alu_data_in1; // for the ALU giving data to memory or registers
    wire [31:0] alu_data_in2;
    wire [31:0] alu_data_result;

    wire [31:0] immediate_extended = {{16{imm[15]}}, imm}; // sign-extend the immediate value
    assign alu_data_in1 = reg_rs; // first operand for ALU
    assign alu_data_in2 = (immReg) ? immediate_extended : reg_rt; // second operand for ALU

    wire zero;

    alu alu_data(
        .a(alu_data_in1),
        .b(alu_data_in2),
        .alu_op(aluOp),
        .result(alu_data_result),
        .zero(zero)
    );

    wire [31:0] data_memory_output;
    data_memory mem(
        .clk(clk),
        .mem_write(memwrite),
        .addr(alu_data_result),
        .write_data(reg_rt),
        .read_data(data_memory_output)
    );
    assign write_data = (memread) ? data_memory_output : alu_data_result; // choose between ALU result and memory data
    assign dummy_wire = 32'd0;



    


endmodule

//module instruction_decode_testbench();
//    wire [31:0] instruction;
//    wire [ 5:0] opcode;
//    wire [25:0] adr;
//    wire [ 4:0] rs;
//    wire [ 4:0] rt;
//    wire [ 4:0] rd;
//    wire [ 4:0] shamt;
//    wire [ 5:0] funct;
//    wire [15:0] imm;
//    wire regwrite;
//    wire memwrite;
//    wire memread;
//    wire [3:0] aluOp;
//    wire immReg;
//    instruction_decode control(
//        .instruction(instruction),
//        .opcode(opcode),
//        .adr(adr),
//        .rs(rs),
//        .rt(rt),
//        .rd(rd),
//        .shamt(shamt),
//        .funct(funct),
//        .imm(imm),
//        .regwrite(regwrite),
//        .memwrite(memwrite),
//        .memread(memread),
//        .aluOp(aluOp),
//        .immReg(immReg)
//    );    
//    assign instruction = 32'b
//    initial begin
        
//    end
//endmodule

module top_testbench();
    reg clk;
    
    top processor(
        .clk(clk)
    );
    initial begin
        clk = 1'b0;
    end
    always #20 clk=~clk;
    
endmodule
module instruction_decode_testbench();
    // Inputs
    reg [31:0] instruction;
    
    // Outputs
    wire [5:0] opcode;
    wire [25:0] adr;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] shamt;
    wire [5:0] funct;
    wire [15:0] imm;
    wire regwrite;
    wire memwrite;
    wire memread;
    wire [3:0] aluOp;
    wire immReg;
    
    // Instantiate the instruction_decode module
    instruction_decode uut (
        .instruction(instruction),
        .opcode(opcode),
        .adr(adr),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .shamt(shamt),
        .funct(funct),
        .imm(imm),
        .regwrite(regwrite),
        .memwrite(memwrite),
        .memread(memread),
        .aluOp(aluOp),
        .immReg(immReg)
    );
    
    // Test stimulus
    initial begin
        // Initialize inputs
        instruction = 32'b0;
        
        // Wait for global reset
        #100;
        
        // Apply test vector
        instruction = 32'b000000010100101101100100010;
        
        // Display the outputs
        #10;
        $display("Time: %t", $time);
        $display("Instruction: %b", instruction);
        $display("Opcode: %b", opcode);
        $display("Address: %b", adr);
        $display("RS: %b", rs);
        $display("RT: %b", rt);
        $display("RD: %b", rd);
        $display("Shamt: %b", shamt);
        $display("Funct: %b", funct);
        $display("Immediate: %b", imm);
        $display("RegWrite: %b", regwrite);
        $display("MemWrite: %b", memwrite);
        $display("MemRead: %b", memread);
        $display("ALU Op: %b", aluOp);
        $display("Immediate Register: %b", immReg);
        
        // End simulation after some time
        #100;
        $finish;
    end
    
    // Optional: Add waveform dumping
    initial begin
        $dumpfile("instruction_decode_testbench.vcd");
        $dumpvars(0, instruction_decode_testbench);
    end
endmodule


//module top_testbench()


 
