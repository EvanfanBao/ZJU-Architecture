`timescale 1ns / 1ps

module Pc (

		input clock,
		input reset,
		input stall,
		input stall_beq,

		input [31:0] nextPc,
		output reg [31:0] pc = 0
	);

	always @(posedge clock) begin
		if (reset) begin
			pc <= 0;
		end 
		else if (stall || stall_beq) begin
			pc <=pc;
		end
		else begin
			pc <= nextPc;
		end
	end
endmodule
