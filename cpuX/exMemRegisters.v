`timescale 1ns / 1ps

module ExMemRegisters (

		input clock,
		input reset,
		input cache_stall,

		input [31:0] ex_instruction,

		input ex_writeRegEnable,
		input [4:0] ex_writeRegAddr,
		input ex_mem2Reg,

		input [31:0] ex_aluOutput,
		input ex_writeMemoryEnable,
		input [31:0] ex_registerRtOrZero,

		output reg [31:0] mem_instruction = 0,

		output reg mem_writeRegEnable = 0,
		output reg [4:0] mem_writeRegAddr = 0,
		output reg mem_mem2Reg = 0,

		output reg [31:0] mem_aluOutput = 0,
		output reg mem_writeMemoryEnable = 0,
		output reg [31:0] mem_registerRtOrZero = 0
	);

	always @(posedge clock) begin

		if (reset) begin

			mem_instruction <= 0;

			mem_writeRegEnable <= 0;
			mem_writeRegAddr <= 0;
			mem_mem2Reg <= 0;

			mem_aluOutput <= 0;
			mem_writeMemoryEnable <= 0;
			mem_registerRtOrZero <= 0;

		end 		
		else if (cache_stall) begin
			mem_instruction <= mem_instruction;
			mem_writeRegEnable <= mem_writeRegEnable;
			mem_writeRegAddr <= mem_writeRegAddr;
			mem_mem2Reg <= mem_mem2Reg;
			mem_aluOutput <= mem_aluOutput;
			mem_writeMemoryEnable <= mem_writeMemoryEnable;
			mem_registerRtOrZero <= mem_registerRtOrZero;

		end 
		else begin
			mem_instruction <= ex_instruction;
			mem_writeRegEnable <= ex_writeRegEnable;
			mem_writeRegAddr <= ex_writeRegAddr;
			mem_mem2Reg <= ex_mem2Reg;
			mem_aluOutput <= ex_aluOutput;
			mem_writeMemoryEnable <= ex_writeMemoryEnable;
			mem_registerRtOrZero <= ex_registerRtOrZero;
		end
	end
endmodule
