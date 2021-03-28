`timescale 1ns / 1ps

module IdExRegisters (

		input clock,
		input reset,
		input cache_stall,

		input [31:0] id_instruction,

		input [31:0] id_shiftAmount,
		input [31:0] id_immediate,

		input [31:0] id_registerRsOrPc_4,
		input [31:0] id_registerRtOrZero,

		input [3:0] id_ALUC,
		input id_shiftEnable,
		input id_immEnable,

		input id_writeRegEnable,
		input [4:0] id_writeRegAddr,
		input id_mem2Reg,

		input id_writeMemoryEnable,
		
		input Stall,
		 
		///lw 的数据 forwad 给 mem
		input id_forward_memory,
		output reg ex_forward_memory = 0,
		////

		output reg [31:0] ex_instruction = 0,

		output reg [31:0] ex_shiftAmount = 0,
		output reg [31:0] ex_immediate = 0,

		output reg [31:0] ex_registerRsOrPc_4 = 0,
		output reg [31:0] ex_registerRtOrZero = 0,

		output reg [3:0] ex_ALUC = 0,
		output reg ex_shiftEnable = 0,
		output reg ex_immEnable = 0,

		output reg ex_writeRegEnable = 0,
		output reg [4:0] ex_writeRegAddr = 0,
		output reg ex_mem2Reg = 0,

		output reg ex_writeMemoryEnable = 0
	);

	always @(posedge clock) begin

		  if (reset || Stall) begin
			
			ex_instruction <= 0;

			ex_shiftAmount <= 0;
			ex_immediate <= 0;

			ex_registerRsOrPc_4 <= 0;
			ex_registerRtOrZero <= 0;

			ex_ALUC <= 0;
			ex_shiftEnable <= 0;
			ex_immEnable <= 0;

			ex_writeRegEnable <= 0;
			ex_writeRegAddr <= 0;
			ex_mem2Reg <= 0;

			ex_writeMemoryEnable <= 0;

		end 
		else if (cache_stall) begin
			
			ex_instruction <= ex_instruction;

			ex_instruction <= ex_instruction;
			ex_immediate <= ex_immediate;

			ex_registerRsOrPc_4 <= ex_registerRsOrPc_4;
			ex_registerRtOrZero <= ex_registerRtOrZero;

			ex_ALUC <= ex_ALUC;
			ex_shiftEnable <= ex_shiftEnable;
			ex_immEnable <= ex_immEnable;

			ex_writeRegEnable <= ex_writeRegEnable;
			ex_writeRegAddr <= ex_writeRegAddr;
			ex_mem2Reg <= ex_mem2Reg;

			ex_writeMemoryEnable <= ex_writeMemoryEnable;

		end 
		else begin
			///容易理解-信号与数据的传递
			ex_forward_memory <= id_forward_memory;
			ex_instruction <= id_instruction;

			ex_shiftAmount <= id_shiftAmount;
			ex_immediate <= id_immediate;

			ex_registerRsOrPc_4 <= id_registerRsOrPc_4;
			ex_registerRtOrZero <= id_registerRtOrZero;

			ex_ALUC <= id_ALUC;
			ex_shiftEnable <= id_shiftEnable;
			ex_immEnable <= id_immEnable;

			ex_writeRegEnable <= id_writeRegEnable;
			ex_writeRegAddr <= id_writeRegAddr;
			ex_mem2Reg <= id_mem2Reg;

			ex_writeMemoryEnable <= id_writeMemoryEnable;
		end
	end
endmodule
