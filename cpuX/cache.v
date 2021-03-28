`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:55:03 12/17/2020 
// Design Name: 
// Module Name:    cache 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`include "Constants.vh"

module cache(
		input cpu_rst,  // cpu reset signal
		input clock,
		input write_en,
		input read_en,
		input [31:0]cpu_addr,
		
		input ack,//memory传输完成
		input [31:0] storedata,//写入memory data来源
		input [31:0] fetchdata,//从memory获取

		output reg [31:0] memory_addr,  //写入memory addr 
		output reg [31:0] memory_data = 0,	//写入memory data
		
		output reg writeMemoryEnable = 0,//memory写允许
		output reg cs = 0,	//向memory请求数据	
		output reg [31:0] data_read = 0,
		output reg cmd_stall = 0
    );
	 
	
	reg [2:0] state;//状态
	
	reg [31:0] cache_data1 [7:0]; 
	reg [31:0] cache_data2 [7:0]; 
	reg [31:0] cache_data3 [7:0]; 
	reg [31:0] cache_data4 [7:0]; 	
	reg [24:0] tag [3:0];
	reg [3:0] valid;
	reg [3:0] dirty;
	
	wire [2:0] offset;
	wire [1:0] index;
	wire [24:0] addr_tag;
	
	reg [2:0] count;
	
	assign offset = cpu_addr[4:2];//3--8 word
	assign index = cpu_addr[6:5];//2--4 line
	assign addr_tag = cpu_addr[31:7];//25
	
	initial begin
		state <= `S_IDLE;
		valid <= 0;
		dirty <= 0;
		count <= 0;
		memory_addr[1:0] <= 0;
	end
	
	always @(posedge clock) begin		
		if(read_en||write_en)begin
		case (state)
		`S_IDLE: begin
			if(tag[index] == addr_tag) begin//hit
			//read
			data_read <= index==0 ? cache_data1[offset]:
							 index==1 ? cache_data2[offset]:
							 index==2 ? cache_data3[offset]:
							 cache_data4[offset];
			//write
			cache_data1[offset] <= index==0&&write_en ? storedata : cache_data1[offset];
			cache_data2[offset] <= index==1&&write_en ? storedata : cache_data2[offset];
			cache_data3[offset] <= index==2&&write_en ? storedata : cache_data3[offset];
			cache_data4[offset] <= index==3&&write_en ? storedata : cache_data4[offset];
			dirty[index] <= write_en ? 1 : dirty[index];
			end
			else begin//miss
				state <= valid[index]&&dirty[index] ? `S_BACK : `S_FILL;
				cmd_stall <= 1;
			end
		end
		`S_BACK: begin
			//发送cs和addr和data和写使能
			cs <= 1;//写回数据
			//写回data的addr
			memory_addr[31:7] <= tag[index];
			memory_addr[6:5] <= index;
			memory_addr[4:2] <= count;//addr
			memory_data <= index==0 ? cache_data1[count]:
							  index==1 ? cache_data2[count]:
						 	  index==2 ? cache_data3[count]:
							  cache_data4[count];
			writeMemoryEnable <= 1;//写使能
			//收到ack
			count <= ack ? count + 1:count;//计数器
			//转换状态
			state <= count == 7 && ack ? `S_BACK_WAIT : `S_BACK;//当前周期为第八次收到ack-->cache fill
			
			//stall
			cmd_stall <= 1;		
		end
		`S_FILL: begin
			//发送cs和addr
			cs <= 1;//请求数据
			//要取入的data的addr
			memory_addr[31:5] <= cpu_addr[31:5];
			memory_addr[4:2] <= ack? count+1 : count;//addr
			
			//存入上次获取data
			cache_data1[count] <= index==0&&ack ? fetchdata : cache_data1[count];
			cache_data2[count] <= index==1&&ack ? fetchdata : cache_data2[count];
			cache_data3[count] <= index==2&&ack ? fetchdata : cache_data3[count];
			cache_data4[count] <= index==3&&ack ? fetchdata : cache_data4[count];
			
			//收到ack
			count <= ack ? count + 1:count;//计数器
			
			//转换状态
			state <= count == 7 && ack ? `S_FILL_WAIT : `S_FILL;//当前周期为第八次收到ack-->cache fill
			
			//stall
			cmd_stall <= 1;
		end
		`S_BACK_WAIT: begin
			cs<=0;
			writeMemoryEnable <= 0;
			valid[index] <= 0;
			dirty[index] <= 0;
			state <= `S_FILL;			
			count <= 0;//count还原
			//stall
			cmd_stall <= 0;		
		end
		`S_FILL_WAIT: begin	
			cs<=0;
			valid[index] <= 1;
			dirty[index] <= 0;
			tag[index] <= addr_tag[24:0];
			state <= `S_IDLE;		
			count <= 0;//count还原
			//stall
			cmd_stall <= 0;		
		end
		endcase	
		
		end
	end
	
	


endmodule
