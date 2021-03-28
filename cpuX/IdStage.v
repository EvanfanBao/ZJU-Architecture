`timescale 1ns / 1ps

module IdStage (
		input wire cpu_rst,  // cpu reset signal
		input wire cpu_en,  // cpu enable signal

		input clock,
		input reset,

		input [31:0] pc_4,//PC+4

		input [31:0] instruction,//ָ��
		
		input if_regw_ex,//ex��Ҫд�Ĵ�����?
		input if_regw_me,//me��Ҫд�Ĵ�����?
		input [4:0]regw_addr_ex,
		input [4:0]regw_addr_me,
		input [4:0]IF_nextpc,
		input  if_ex_sw,
		input  if_ex_lw,
		input  if_me_sw,
		input  if_me_lw,
		input  [4:0]rt_addr_ex,
		input  [4:0]rt_addr_me,
		
		//�����źŴ���
		output branchEnable,	// BRANCH ��ת�����ź� jump jr beq��
		output [31:0] branchAddr, // ������תָ���pc

		output [31:0] shiftAmount,  //��λ�� ����һ��
		output [31:0] immediate,   // ������

		output [31:0] registerRsOrPc_4,//ALU��A���muxѡ����
		output [31:0] registerRtOrZero,//ALU��B���muxѡ����

		output [3:0] ALUC,	// ALU Control signal
		output shiftEnable,	// SHIFT  ��λ�����źŴ�����һ��
		output immEnable,	// ALUIMM ALU������ʹ���ź������ź�

		output writeRegEnable,	// WREG �Ĵ���д�����ź�
		output [4:0] writeRegAddr,  //�Ĵ���д��ַ
		output mem2Reg,	// M2REG �ڴ����aluoutдѡ��

		output writeMemoryEnable,	// WMEM �ڴ�д�����ź�
		
		output Stall,
		output stall_beq,
		
		//wbд�Ĵ���
		input wb_writeRegEnable,
		input [4:0] wb_writeRegAddr,
		input [31:0] wb_registerWriteData,	
			
		input wire [5:0] debug_addr,  // debug address
		output wire [31:0] debug_data,  // debug data
		
		
		
		
		
		//forward ���
		input ex_mem2Reg,			//
		input mem_mem2Reg, 
		input [31:0] ex_aluOutput,	 //��һ��forwarding����
		input [31:0] mem_aluOutput, //�ڶ���forwarding����
		input [31:0] mem_memoryData, //������forwarding����
		
		
		output forward_memory
			
	
		
	);
	
	
	//forward �������	
	wire forwardA1;	//ѡ��Ex������ALUout
	wire forwardA2;	//ѡ��Mem��ʼ��ALUout
	wire forwardA3;	//ѡ��Mem���ص�data
	wire forwardB1;	//ѡ��Ex������ALUout
	wire forwardB2;	//ѡ��Mem�׶ε�ALUout
	wire forwardB3;	//ѡ��mem����data
	
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

	//ָ������-���������ź�
	ControlUnit controlUnit (

		.instruction(instruction[31:0]),//input

		.equal(equal),//input
		
		.if_regw_ex(if_regw_ex),//ex��Ҫд�Ĵ�����?
		.if_regw_me(if_regw_me),//me��Ҫд�Ĵ�����?
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
		
		
		
		//forward �������
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

	assign shiftAmount = {27'b0, instruction[10:6]};        //��λ��---ex�׶�alu�ĵ�һ������
	wire [15:0] instructionImmediate = instruction[15:0];
	
	//��������չ
	assign immediate = {
			signExtendEnable ? {16{instructionImmediate[15]}} : 16'b0,
			instructionImmediate};

	wire [4:0] rs = instruction[25:21];
	wire [4:0] rt = instruction[20:16];
	wire [4:0] rd = instruction[15:11];

	//�Ĵ���д��ַ����
	//Jalָ���Ӧ31�š������Ǹ��ݿ����ź�rt����rd
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

	//�Ĵ������������
	//wire [31:0] registerRs = localRegisterRs;		
	//wire [31:0] registerRt = localRegisterRt;     //��Ϊforwarding��һ���ֵ�
	
	//jalָ���Ӧ����pc+4+0�浽31�żĴ���
	//ALU A B����mux
	assign registerRsOrPc_4 = isJAL ? pc_4 : registerRs;
	assign registerRtOrZero = isJAL ? 32'b0 : registerRt;

	assign equal = registerRs == registerRt;   //���ڿ���branch
	//ȷ����ת��ַ
	wire [31:0] jumpIndexPc = {pc_4[31:28], jumpIndex, 2'b0};
	wire [31:0] branchPc = pc_4 + {immediate[29:0], 2'b0};
	
	//ѡ���Ӧ��pc��ַ���ݸ�ID�׶�pc�Ĵ���
	assign branchAddr =
			isJR ? registerRs
			: isJumpIndex ? jumpIndexPc
			: branchPc;
endmodule
