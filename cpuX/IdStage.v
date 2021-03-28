`timescale 1ns / 1ps

module IdStage (
		input wire cpu_rst,  // cpu reset signal
		input wire cpu_en,  // cpu enable signal

		input clock,
		input reset,

		input [31:0] pc_4,//PC+4

		input [31:0] instruction,//指令
		
		input if_regw_ex,//ex需要写寄存器吗?
		input if_regw_me,//me需要写寄存器吗?
		input [4:0]regw_addr_ex,
		input [4:0]regw_addr_me,
		input [4:0]IF_nextpc,
		input  if_ex_sw,
		input  if_ex_lw,
		input  if_me_sw,
		input  if_me_lw,
		input  [4:0]rt_addr_ex,
		input  [4:0]rt_addr_me,
		
		//控制信号传递
		output branchEnable,	// BRANCH 跳转控制信号 jump jr beq等
		output [31:0] branchAddr, // 各种跳转指令的pc

		output [31:0] shiftAmount,  //移位量 到下一级
		output [31:0] immediate,   // 立即数

		output [31:0] registerRsOrPc_4,//ALU的A入口mux选择结果
		output [31:0] registerRtOrZero,//ALU的B入口mux选择结果

		output [3:0] ALUC,	// ALU Control signal
		output shiftEnable,	// SHIFT  移位控制信号传到下一级
		output immEnable,	// ALUIMM ALU立即数使能信号运算信号

		output writeRegEnable,	// WREG 寄存器写控制信号
		output [4:0] writeRegAddr,  //寄存器写地址
		output mem2Reg,	// M2REG 内存或者aluout写选择

		output writeMemoryEnable,	// WMEM 内存写控制信号
		
		output Stall,
		output stall_beq,
		
		//wb写寄存器
		input wb_writeRegEnable,
		input [4:0] wb_writeRegAddr,
		input [31:0] wb_registerWriteData,	
			
		input wire [5:0] debug_addr,  // debug address
		output wire [31:0] debug_data,  // debug data
		
		
		
		
		
		//forward 相关
		input ex_mem2Reg,			//
		input mem_mem2Reg, 
		input [31:0] ex_aluOutput,	 //第一个forwarding数据
		input [31:0] mem_aluOutput, //第二个forwarding数据
		input [31:0] mem_memoryData, //第三个forwarding数据
		
		
		output forward_memory
			
	
		
	);
	
	
	//forward 相关内容	
	wire forwardA1;	//选择Ex运算后的ALUout
	wire forwardA2;	//选择Mem开始的ALUout
	wire forwardA3;	//选择Mem加载的data
	wire forwardB1;	//选择Ex运算后的ALUout
	wire forwardB2;	//选择Mem阶段的ALUout
	wire forwardB3;	//选择mem加载data
	
	wire [31:0] registerRs =
			forwardA1 ? ex_aluOutput
			: forwardA2 ? mem_aluOutput
			: forwardA3 ? mem_memoryData
			: localRegisterRs;
	wire [31:0] registerRt =
			forwardB1 ? ex_aluOutput
			: forwardB2 ? mem_aluOutput
			: forwardB3 ? mem_memoryData
			: localRegisterRt;
	
	
	

	wire isJumpIndex;	// JUMP
	wire [25:0] jumpIndex;	// address
	wire isJR;	// JR
	wire equal;	// RSRTEQU
	wire isJAL;	// JAL
	wire signExtendEnable;	// SEXT
	wire shouldWriteToRegisterRtElseRd;	// REGRT

	//指令译码-产生控制信号
	ControlUnit controlUnit (

		.instruction(instruction[31:0]),//input

		.equal(equal),//input
		
		.if_regw_ex(if_regw_ex),//ex需要写寄存器吗?
		.if_regw_me(if_regw_me),//me需要写寄存器吗?
		.regw_addr_ex(regw_addr_ex),
		.regw_addr_me(regw_addr_me),
		.if_ex_sw(if_ex_sw),
		.if_ex_lw(if_ex_lw),
		.if_me_sw(if_me_sw),
		.if_me_lw(if_me_lw),
		.rt_addr_ex(rt_addr_ex),
		.rt_addr_me(rt_addr_me),
		
		
		.isJumpIndex(isJumpIndex),
		.jumpIndex(jumpIndex[25:0]),
		.isJR(isJR),
		
		.branchEnable(branchEnable),
		.isJAL(isJAL),

		.signExtendEnable(signExtendEnable),

		.ALUC(ALUC[3:0]),
		.shiftEnable(shiftEnable),
		.immEnable(immEnable),

		.writeRegEnable(writeRegEnable),
		.shouldWriteToRegisterRtElseRd(shouldWriteToRegisterRtElseRd),
		.mem2Reg(mem2Reg),

		.writeMemoryEnable(writeMemoryEnable),
		.Stall(Stall),	
		.stall_beq(stall_beq),
		
		
		
		//forward 相关内容
		.forwardA1(forwardA1),
		.forwardA2(forwardA2),
		.forwardA3(forwardA3),
		.forwardB1(forwardB1),
		.forwardB2(forwardB2),
		.forwardB3(forwardB3),
		
		.mem_mem2Reg(mem_mem2Reg),
		.ex_mem2Reg(ex_mem2Reg),
		
		.forward_memory(forward_memory)
		
		
	);

	assign shiftAmount = {27'b0, instruction[10:6]};        //移位量---ex阶段alu的第一个输入
	wire [15:0] instructionImmediate = instruction[15:0];
	
	//立即数扩展
	assign immediate = {
			signExtendEnable ? {16{instructionImmediate[15]}} : 16'b0,
			instructionImmediate};

	wire [4:0] rs = instruction[25:21];
	wire [4:0] rt = instruction[20:16];
	wire [4:0] rd = instruction[15:11];

	//寄存器写地址传递
	//Jal指令对应31号。否则是根据控制信号rt或者rd
	assign writeRegAddr =
			isJAL ? 5'd31
			: shouldWriteToRegisterRtElseRd ? rt : rd;

	wire [31:0] localRegisterRs;
	wire [31:0] localRegisterRt;
	RegisterFile registerFile (

		.clock(clock),
		.reset(reset),

		.readAddressA(rs[4:0]),
		.readDataA(localRegisterRs[31:0]),
		.readAddressB(rt[4:0]),
		.readDataB(localRegisterRt[31:0]),

		.shouldWrite(wb_writeRegEnable & cpu_en & ~cpu_rst),
		.writeAddress(wb_writeRegAddr[4:0]),
		.writeData(wb_registerWriteData[31:0]),
		
		
		.debug_addr(debug_addr[4:0]),
		.debug_data(debug_data[31:0])
	);

	//寄存器两个输出口
	//wire [31:0] registerRs = localRegisterRs;		
	//wire [31:0] registerRt = localRegisterRt;     //变为forwarding的一部分的
	
	//jal指令对应的是pc+4+0存到31号寄存器
	//ALU A B输入mux
	assign registerRsOrPc_4 = isJAL ? pc_4 : registerRs;
	assign registerRtOrZero = isJAL ? 32'b0 : registerRt;

	assign equal = registerRs == registerRt;   //用于控制branch
	//确定跳转地址
	wire [31:0] jumpIndexPc = {pc_4[31:28], jumpIndex, 2'b0};
	wire [31:0] branchPc = pc_4 + {immediate[29:0], 2'b0};
	
	//选择对应的pc地址传递给ID阶段pc寄存器
	assign branchAddr =
			isJR ? registerRs
			: isJumpIndex ? jumpIndexPc
			: branchPc;
endmodule
