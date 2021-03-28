`timescale 1ns / 1ps

module ExStage (

		input [31:0] shiftAmount,
		input [31:0] immediate,

		input [3:0] ex_ALUC,	// EALUC
		input ex_shiftEnable,	// ESHIFT
		input ex_immEnable,	// EALUIMM

		input [31:0] registerRsOrPc_4,
		input [31:0] registerRtOrZero,
		
		
		//forward memory lwµΩsw
		input ex_forward_memory,
		input [31:0] mem_memoryData,

		output [31:0] exe_registerRtOrZero,
		output [31:0] aluOutput

	);
	//A B ‰»Îmux
	wire [31:0] aluInputA = ex_shiftEnable ? shiftAmount : registerRsOrPc_4;
	wire [31:0] aluInputB = ex_immEnable ? immediate : registerRtOrZero;
	Alu alu (
		.inputA(aluInputA[31:0]),
		.inputB(aluInputB[31:0]),
		.operation(ex_ALUC[3:0]),
		.output_(aluOutput[31:0])
	);

	assign exe_registerRtOrZero = ex_forward_memory ? mem_memoryData : registerRtOrZero;

endmodule
