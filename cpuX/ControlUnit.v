`timescale 1ns / 1ps

`include "Constants.vh"

module ControlUnit (

		input [31:0] instruction,
		
		input equal,	// RSRTEQU
		
		input if_regw_ex,//ex��Ҫд�Ĵ�����?
		input if_regw_me,//me��Ҫд�Ĵ�����?
		input [4:0]regw_addr_ex,
		input [4:0]regw_addr_me,
		input  if_ex_sw,
		input  if_ex_lw,
		input  if_me_sw,
		input  if_me_lw,
		input  [4:0]rt_addr_ex,
		input  [4:0]rt_addr_me,

		output isJumpIndex,	// JUMP
		output [25:0] jumpIndex,	// address
		output isJR,	// JR, but not JALR yet
		
		output branchEnable,	// BRANCH
		output isJAL,	// JAL

		output signExtendEnable,	// SEXT

		output [3:0] ALUC,	// ALUC
		output shiftEnable,	// SHIFT
		output immEnable,	// ALUIMM

		output writeRegEnable,	// WREG
		output shouldWriteToRegisterRtElseRd,	// REGRT
		output mem2Reg,	// M2REG

		output writeMemoryEnable,	// WMEM
		output Stall,	// WPCIR
		output stall_beq,
		
		
		//forward �������
		
		output forwardA1,
		output forwardA2,
		output forwardA3,
		output forwardB1,
		output forwardB2,
		output forwardB3,
		
		input mem_mem2Reg,
		input ex_mem2Reg,
		
		output forward_memory   //����lw������ת���� sw ��ex�׶���ɴ��� ���ﴫ��
	);
	
	
	
	//forward����ж�
	// ���Խ��ALU-ALU��ͻ��ALU_lw��ͻ������ Add $3,$2,$1 Sub $4,$3,$1 �� Add $7, $zero, $1 Lw $8,0($7)
	assign forwardA1 = Id_use_Ex_Rs && !ex_mem2Reg;      
	// ���Խ�����һ��ָ���ALU-ALU��ͻ ���� Add $3,$2,$1 Sub $4,$3,$1
	assign forwardA2 = Id_use_Mem_Rs && !mem_mem2Reg;	  
	// ���Խ��Lw���ͻȻ��stallһ������֮���Դ��ڵĳ�ͻ������ Lw $2, 24($zero) Add $3,$2,$1
	assign forwardA3 = Id_use_Mem_Rs && mem_mem2Reg;	  
	
	assign forwardB1 =(!immEnable) && Id_use_Ex_Rt && !ex_mem2Reg; 
	assign forwardB2 =(!immEnable) && Id_use_Mem_Rt && !mem_mem2Reg;
	//��������ǰ������������ͬ �޷���Rt��ΪԴ
	//���ǵ� ��ǰָ���Ǵ���������������(addi��lw��sll ���� ֻ��rs��Դ�Ĵ������ܳ�ͻ��rt��������ͻ�����)
	
	assign forwardB3 = Id_use_Mem_Rt && mem_mem2Reg;
   //�ܹ�ʵ��LW-ALUͣ��һ�κ��ת����Ҳ�����lw�������һ��ָ�����sw -- �Ҷ���rt��ͬ
	
	
	//��lw��sw��rt�Ĵ�����ͬ ��ǰ����� �� forward_memory=1	
	assign forward_memory = (writeMemoryEnable)&&(if_ex_lw)&&(rt==rt_addr_ex);
	//���Խ�� lw sw��ͬrt
	//��Lw $8,0($7) Sw $8,8($7)

	
	
	//code == `CODE_J || code == `CODE_JAL

	wire [5:0] code = instruction[31:26];
	wire [5:0] function_ = instruction[5:0];

	assign isJumpIndex = code == `CODE_J || code == `CODE_JAL;
	assign jumpIndex = instruction[25:0];
	
	assign isJAL = code == `CODE_JAL;
	wire isRType = code == `CODE_R_TYPE;
	
	assign isJR = isRType && function_ == `FUNCTION_JR;
	wire isBeq = code == `CODE_BEQ;
	wire isBranch = isBeq || code == `CODE_BNE;
	wire shouldBranch = isBranch && (isBeq == equal);
	assign branchEnable = isJumpIndex || isJR || shouldBranch;
	
	//�Ƿ�ͣ��
	wire [4:0] rs = instruction[25:21];
	wire [4:0] rt = instruction[20:16];
	wire ctrl_stall_yes = 0;
	wire pre_ctrl_stall_yes = 0;
	wire Id_use_Ex_Rs = if_regw_ex && regw_addr_ex == rs && rs != 0;
	wire Id_use_Ex_Rt = if_regw_ex && regw_addr_ex == rt && rt != 0;
	wire Id_use_Mem_Rs = if_regw_me && regw_addr_me == rs && rs != 0;
	wire Id_use_Mem_Rt = if_regw_me && regw_addr_me == rt && rt != 0;
	
	//alu ��������beqָ�� ��beq stallһ��
	assign stall_beq = isBranch &&
							(
							(Id_use_Ex_Rs || Id_use_Ex_Rt) //Դ�Ĵ���rs��rt
	//mem�׶�forward���||(Id_use_Mem_Rs || Id_use_Mem_Rt)//Դ�Ĵ���rs��rt
							);//��Ҫǰ���alu��lwָ��Ľ��
	assign Stall = (if_ex_lw && 						
                 (
						((!immEnable) && (Id_use_Ex_Rs || Id_use_Ex_Rt))|| //Դ�Ĵ���rs��rt
						(immEnable && (Id_use_Ex_Rs)) //Դ�Ĵ�����rs
						) ); //lw ��alu ����  ����stall�� lw ���� ��swҲ��һ��������
	
	
	
	//������չ����
	assign signExtendEnable =
			code == `CODE_ADDI
			|| code == `CODE_ADDIU
			|| code == `CODE_LW
			|| code == `CODE_SW
			|| code == `CODE_BEQ
			|| code == `CODE_BNE
			|| code == `CODE_SLTI;
	assign ALUC =
			isJAL ? `ALU_ADD	// pc_4 + 0
			: isRType ? (
				function_ == `FUNCTION_ADD ? `ALU_ADD
				: function_ == `FUNCTION_ADDU ? `ALU_ADDU
				: function_ == `FUNCTION_SUB ? `ALU_SUB
				: function_ == `FUNCTION_SUBU ? `ALU_SUBU
				: function_ == `FUNCTION_AND ? `ALU_AND
				: function_ == `FUNCTION_OR ? `ALU_OR
				: function_ == `FUNCTION_XOR ? `ALU_XOR
				: function_ == `FUNCTION_NOR ? `ALU_NOR
				: function_ == `FUNCTION_SLT ? `ALU_SLT//`ALU_SUB
				: function_ == `FUNCTION_SLTU ? `ALU_SLTU//`ALU_SUBU
				: function_ == `FUNCTION_SLL ? `ALU_SLL
				: function_ == `FUNCTION_SRL ? `ALU_SRL
				: function_ == `FUNCTION_SRA ? `ALU_SRA
				: function_ == `FUNCTION_SLLV ? `ALU_SLL
				: function_ == `FUNCTION_SRLV ? `ALU_SRL
				: function_ == `FUNCTION_SRAV ? `ALU_SRA
				: `ALU_NONE
			)
			: code == `CODE_ADDI ? `ALU_ADD
			: code == `CODE_ADDIU ? `ALU_ADDU
			: code == `CODE_ANDI ? `ALU_AND
			: code == `CODE_ORI ? `ALU_OR
			: code == `CODE_XORI ? `ALU_XOR
			: code == `CODE_LUI ? `ALU_LUI	// HIGHLIGHT
			: code == `CODE_LW ? `ALU_ADD
			: code == `CODE_SW ? `ALU_ADD
			: code == `CODE_BEQ ? `ALU_SUB   //��������
			: code == `CODE_BNE ? `ALU_SUB   //��������
			: code == `CODE_SLTI ? `ALU_SLT//`ALU_SUB  
			: code == `CODE_SLTIU ? `ALU_SLTU//`ALU_SUBU
			: `ALU_NONE;
	assign shiftEnable =
			!isJAL	// pc_4
			&& (isRType && (
				function_ == `FUNCTION_SLL
				|| function_ == `FUNCTION_SRL
				|| function_ == `FUNCTION_SRA
			));
	assign immEnable =
			!isJAL	// 0
			&& (
				code == `CODE_ADDI
				|| code == `CODE_ADDIU
				|| code == `CODE_ANDI
				|| code == `CODE_ORI
				|| code == `CODE_XORI
				|| code == `CODE_LUI	// TODO: Correct?
				|| code == `CODE_LW
				|| code == `CODE_SW
				|| code == `CODE_SLTI
				|| code == `CODE_SLTIU
				|| code == `CODE_LUI
			);

	assign shouldWriteToRegisterRtElseRd =
			code == `CODE_ADDI
			|| code == `CODE_ADDIU
			|| code == `CODE_ANDI
			|| code == `CODE_ORI
			|| code == `CODE_XORI
			|| code == `CODE_LUI
			|| code == `CODE_LW
			|| code == `CODE_SLTI
			|| code == `CODE_SLTIU;
	assign writeRegEnable =
			(isRType && (
				function_ == `FUNCTION_ADD
				|| function_ == `FUNCTION_ADDU
				|| function_ == `FUNCTION_SUB
				|| function_ == `FUNCTION_SUBU
				|| function_ == `FUNCTION_AND
				|| function_ == `FUNCTION_OR
				|| function_ == `FUNCTION_XOR
				|| function_ == `FUNCTION_NOR
				|| function_ == `FUNCTION_SLT
				|| function_ == `FUNCTION_SLTU
				|| function_ == `FUNCTION_SLL
				|| function_ == `FUNCTION_SRL
				|| function_ == `FUNCTION_SRA
				|| function_ == `FUNCTION_SLLV
				|| function_ == `FUNCTION_SRLV
				|| function_ == `FUNCTION_SRAV
			))
			|| shouldWriteToRegisterRtElseRd
			|| isJAL;
	assign mem2Reg = code == `CODE_LW;

	assign writeMemoryEnable = code == `CODE_SW;

	

	
	
	endmodule
