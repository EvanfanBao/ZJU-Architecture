`timescale 1ns / 1ps

module IfIdRegisters (

		input clock,
		input reset,
		
		input stall,
		input stall_beq,
		input jump_delect_pre_inst,


		input [31:0] if_pc_4,
		input [31:0] if_instruction,
		output reg [31:0] id_pc_4 = 0,
		output reg [31:0] id_instruction = 0
	);

	always @(posedge clock) begin//�����ش�ֵ
		if (reset || (jump_delect_pre_inst && !stall_beq)) begin
			id_pc_4 <= 0;
			id_instruction <= 0;
		end 		
		else if (stall || stall_beq) begin//����PC
			id_pc_4 <= id_pc_4;
			id_instruction <= id_instruction;
		end
		else begin
			id_pc_4 <= if_pc_4;
			id_instruction <= if_instruction;
		end
	end
endmodule
