`timescale 1ns / 1ps

module IfStage (
      input cpu_en,
      input cpu_rst,
		input clock,

		input [31:0] pc,
 
		input branchEnable,	// BRANCH  pc��תʹ��-�����˸�����ת���jump jr beq�ȵ�
		input [31:0] branchAddr, //pc����ת��ַ

		output [31:0] pc_4,

		output [31:0] instruction,

		output [31:0] nextPc
	);

	assign pc_4 = cpu_en & ~cpu_rst ? pc + 4 : pc_4;

	InstructionMemory instructionMemory (
		.clka(~clock),
		.addra(pc[9:2]),
		.douta(instruction[31:0])
	);
	assign nextPc = branchEnable & cpu_en & ~cpu_rst ? branchAddr : pc_4;
endmodule
