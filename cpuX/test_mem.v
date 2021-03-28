`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:34:49 01/07/2021
// Design Name:   MemStage
// Module Name:   D:/Ducument/ISE code/computer architecture/bonus/cpuX/test_mem.v
// Project Name:  Cpu
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MemStage
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_mem;

	// Inputs
	reg cpu_rst;
	reg cpu_en;
	reg clock;
	reg reset;
	reg [31:0] aluOutput;
	reg writeMemoryEnable;
	reg read_en;
	reg [31:0] registerRtOrZero;

	// Outputs
	wire [31:0] memoryData;
	wire cache_stall;

	// Instantiate the Unit Under Test (UUT)
	MemStage uut (
		.cpu_rst(cpu_rst), 
		.cpu_en(cpu_en), 
		.clock(clock), 
		.reset(reset), 
		.aluOutput(aluOutput), 
		.writeMemoryEnable(writeMemoryEnable), 
		.read_en(read_en), 
		.registerRtOrZero(registerRtOrZero), 
		.memoryData(memoryData), 
		.cache_stall(cache_stall)
	);

	initial begin
		// Initialize Inputscpu_rst = 0;
		cpu_rst = 0;
		cpu_en = 0;
		clock = 0;
		reset = 0;
		aluOutput = 0;//addr
		writeMemoryEnable = 0;
		read_en = 0;
		registerRtOrZero = 0;//write--data
		#100;
		
		cpu_rst = 0;
		cpu_en = 1;
		clock = 0;
		reset = 0;
		aluOutput = 0;//addr
		writeMemoryEnable = 0;
		read_en = 0;
		registerRtOrZero = 0;//write--data
		//read
		read_en = 1;
		aluOutput = 24;
		#200;      
		read_en = 1;
		aluOutput = 20;
		#200;      
		//write
		read_en = 0;
		writeMemoryEnable = 1;
		aluOutput = 4;
		registerRtOrZero = 16;
		#200;		  
		//read 128»»³ö0 line
		read_en = 1;
		writeMemoryEnable = 0;
		aluOutput = 132;
		#200;    
		//read 0»»»Ø0 line
		read_en = 1;
		aluOutput = 4;
		#200; 

	end
	//clock
	always begin
	forever
	begin
		clock = ~clock;
		#4;  
	end
	end
      
endmodule

