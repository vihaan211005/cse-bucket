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
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            pc_out <= 32'd0; 
        end else begin
            pc_out <= pc_in;
            $display("Updating pc out to %d", pc_out);
        end
            
    end
endmodule

module top(
    input clk,
    input rst,
    output [31:0] outwire 
 );
    wire [31:0] dummy_wire;
    wire [31:0] PC_out;
    wire [31:0] PC_in;
    wire [31:0] PC_final;
    // assign PC_in = 32'd0;
    program_counter pc(
        .clk(clk),
        .rst(rst),
        .pc_in(PC_final),
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
    wire regDst;
    wire jump;
    wire branch;

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
        .branch(branch),
        .jump(jump),
        .memwrite(memwrite),
        .memread(memread),
        .aluOp(aluOp),
        .immReg(immReg),
        .regDst(regDst)
    );
    
    // Special handling for JAL instruction
    wire is_jal = (opcode == 6'h03);
    wire [4:0] write_reg = (is_jal) ? 5'd31 : ((regDst) ? rd : rt); // Choose destination register
    
    wire [31:0] reg_rs;
    wire [31:0] reg_rt;
    wire [31:0] write_data;
    wire [27:0] shiftleft_adr = {adr, 2'b00}; // shift left the address for jump instruction
    
    wire zero_pc_increment;
    alu pc_increment(
        .a(PC_out),
        .b(32'd4),
        .alu_op(4'b0000),
        .result(PC_in),
        .zero(zero_pc_increment)
    );
    
    reg_file rf(
        .clk(clk),
        .rs(rs),
        .rt(rt),
        .rd(write_reg),
        .write_data(write_data),
        .reg_rs(reg_rs),
        .reg_rt(reg_rt),
        .reg_write(regwrite)
    );

    // Handle different instruction types and their special cases
    wire [31:0] alu_data_in1; // for the ALU giving data to memory or registers
    wire [31:0] alu_data_in2;
    wire [31:0] alu_data_result;

    // Special handling for different immediate formats
    wire [31:0] immediate_extended = {{16{imm[15]}}, imm}; // sign-extend the immediate value
    wire [31:0] immediate_zextended = {16'b0, imm}; // zero-extend for logical operations
    wire [31:0] immediate_lui = {imm, 16'b0}; // lui immediate (shift left 16 bits)
    
    // Special handling for shift instructions
    wire is_shift = (opcode == 6'b000000) && (funct == 6'h00 || funct == 6'h02); // SLL or SRL
    wire is_lui = (opcode == 6'h0F); // LUI
    
    // Immediate value selection based on instruction
    wire [31:0] immediate_selected = (is_lui) ? immediate_lui : 
                                    ((opcode == 6'h0C || opcode == 6'h0D) ? immediate_zextended : 
                                                                          immediate_extended);
    
    // For shift operations, use shamt as the second operand
    wire [31:0] shamt_extended = {27'b0, shamt};
    
    assign alu_data_in1 = (is_shift) ? reg_rt : reg_rs; // For shifts, use rt as first operand
    assign alu_data_in2 = (is_shift) ? shamt_extended : 
                          (immReg) ? immediate_selected : reg_rt;
    
    wire zero;
    alu alu_data(
        .a(alu_data_in1),
        .b(alu_data_in2),
        .alu_op(aluOp),
        .result(alu_data_result),
        .zero(zero)
    );

    wire [31:0] jump_addr = {PC_in[31:28], shiftleft_adr}; // concatenate the upper bits of PC with the shifted address

    // Branch handling
    wire [31:0] extended_imm = {{14{imm[15]}}, imm, 2'b00}; // sign-extend the immediate value and shift left by 2 bits for branch instruction
    wire [31:0] branch_addr = PC_in + extended_imm; // calculate the branch address

    // Check branch condition: for beq use zero, for bne use !zero
    wire is_bne = (opcode == 6'h05);
    wire branch_condition = is_bne ? !zero : zero;
    wire branch_taken = branch_condition && branch; // Check if branch condition is met
    
    // JAL handling - store PC+4 for return
    wire [31:0] jal_data = PC_in;
    
    // PC update logic
    wire [31:0] next_pc = (branch_taken) ? branch_addr : ((jump) ? jump_addr : PC_in);
    assign PC_final = next_pc;

    wire [31:0] data_memory_output;
    data_memory mem(
        .clk(clk),
        .mem_write(memwrite),
        .addr(alu_data_result),
        .write_data(reg_rt),
        .read_data(data_memory_output)
    );
    
    // Choose the data to write to register
    wire [31:0] alu_or_mem = (memread) ? data_memory_output : alu_data_result;
    assign write_data = (is_jal) ? jal_data : alu_or_mem;
    
    assign dummy_wire = 32'd0;
    assign outwire = write_data;
endmodule


module top_testbench();
    // Clock generation
    reg clk;
    
    // Instantiate the top module
    top dut(
        .clk(clk)
    );
    
    // Clock generation (50MHz)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // Toggle every 10ns (20ns period)
    end
    
    // Test stimulus and monitoring
    initial begin
        // Initialize simulation
        $display("Starting simulation of the top module");
        $monitor("Immediate extension, %d, %b", $time, dut.immediate_extended, dut.immReg);
        // Monitor for a few clock cycles
        #100;
        #100;
        #100;
        
        // End simulation after some time
//        #200;
        $display("Register 1 contains, %d", dut.rf.regs[4'd1]);
        $display("Simulation completed");
        $finish;
    end
    
    // Optional: Add waveform dumping
    initial begin
        $dumpfile("top_testbench.vcd");
        $dumpvars(0, top_testbench);
    end
endmodule
//module top_testbench()



