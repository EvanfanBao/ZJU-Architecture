`timescale 1ns / 1ps

module MemStage (
		input wire cpu_rst,  // cpu reset signal
		input wire cpu_en,  // cpu enable signal

		input clock,
		input reset,

		input [31:0] aluOutput,
		input writeMemoryEnable,
		input read_en,
		input [31:0] registerRtOrZero,
		output [31:0] memoryData,
		output cache_stall
	);
	
	wire ack, cs;//cache和memory通信用
	wire [31:0] memery_addr;
	wire [31:0] memery_data;
	
	wire [31:0] fetch_memory_data;

	
	
	memory mem(
		.cpu_rst(cpu_rst),  // cpu reset signal
		.clock(clock),

		.addr(memery_addr),
		.data(memery_data),		
		
		.writeMemoryEnable( memery_we ),
		.cs(cs),
		
		.ack(ack),
		.memoryData( fetch_memory_data )
	);
	
	cache cac(
		.cpu_rst(cpu_rst),  // cpu reset signal
		.clock(clock),
		
		.write_en( writeMemoryEnable ),
		.read_en(read_en),
		.cpu_addr( aluOutput ),
		.storedata( registerRtOrZero ),
		.fetchdata( fetch_memory_data ),	
		.ack(ack),
	
		
		.memory_addr( memery_addr ),
		.memory_data( memery_data ),
		.cs(cs),
		
		.writeMemoryEnable( memery_we ),
		.data_read( memoryData ),
		.cmd_stall( cache_stall )
	);
/*
	DataMemory dataMemory(
		.clka(~clock),
		.addra(aluOutput[9:2]),
		.douta(memoryData[31:0]),
		.wea(writeMemoryEnable & cpu_en & ~cpu_rst),
		.dina(registerRtOrZero[31:0])
	);*/
endmodule
