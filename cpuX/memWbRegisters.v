`timescale 1ns / 1ps

module MemWbRegisters (

		input clock,
		input reset,
		input cache_stall,

		input [31:0] mem_instruction,

		input mem_writeRegEnable,
		input [4:0] mem_writeRegAddr,
		input mem_mem2Reg,
		input [31:0] mem_memoryData,
		input [31:0] mem_aluOutput,

		output reg [31:0] wb_instruction = 0,

		output reg wb_writeRegEnable = 0,
		output reg [4:0] wb_writeRegAddr = 0,
		output reg wb_mem2Reg = 0,
		output reg [31:0] wb_memoryData = 0,
		output reg [31:0] wb_aluOutput = 0
	);

	always @(posedge clock) begin

		if (reset || cache_stall) begin

			wb_instruction <= 0;

			wb_writeRegEnable <= 0;
			wb_writeRegAddr <= 0;
			wb_mem2Reg <= 0;
			wb_memoryData <= 0;
			wb_aluOutput <= 0;

		end else begin

			wb_instruction <= mem_instruction;

			wb_writeRegEnable <= mem_writeRegEnable;
			wb_writeRegAddr <= mem_writeRegAddr;
			wb_mem2Reg <= mem_mem2Reg;
			wb_memoryData <= mem_memoryData;
			wb_aluOutput <= mem_aluOutput;
		end
	end
endmodule
