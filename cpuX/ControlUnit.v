`timescale 1ns / 1ps

`include "Constants.vh"

module ControlUnit (

		input [31:0] instruction,
		
		input equal,	// RSRTEQU
		
		input if_regw_ex,//ex需要写寄存器吗?
		input if_regw_me,//me需要写寄存器吗?
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
		
		
		//forward 相关内容
		
		output forwardA1,
		output forwardA2,
		output forwardA3,
		output forwardB1,
		output forwardB2,
		output forwardB3,
		
		input mem_mem2Reg,
		input ex_mem2Reg,
		
		output forward_memory   //控制lw的数据转发到 sw 在ex阶段完成传递 这里传出
	);
	
	
	
	//forward相关判断
	// 可以解决ALU-ALU冲突和ALU_lw冲突，例如 Add $3,$2,$1 Sub $4,$3,$1 和 Add $7, $zero, $1 Lw $8,0($7)
	assign forwardA1 = Id_use_Ex_Rs && !ex_mem2Reg;      
	// 可以解决相差一个指令的ALU-ALU冲突 例如 Add $3,$2,$1 Sub $4,$3,$1
	assign forwardA2 = Id_use_Mem_Rs && !mem_mem2Reg;	  
	// 可以解决Lw后冲突然后stall一个周期之后仍存在的冲突，例如 Lw $2, 24($zero) Add $3,$2,$1
	assign forwardA3 = Id_use_Mem_Rs && mem_mem2Reg;	  
	
	assign forwardB1 =(!immEnable) && Id_use_Ex_Rt && !ex_mem2Reg; 
	assign forwardB2 =(!immEnable) && Id_use_Mem_Rt && !mem_mem2Reg;
	//这两者与前面解决的问题相同 无非是Rt作为源
	//考虑到 当前指令是存在立即数的运算(addi、lw、sll 这种 只有rs是源寄存器可能冲突而rt不产生冲突的情况)
	
	assign forwardB3 = Id_use_Mem_Rt && mem_mem2Reg;
   //能够实现LW-ALU停顿一次后的转发。也解决了lw后面隔了一条指令而后sw -- 且二者rt相同
	
	
	//先lw再sw且rt寄存器相同 且前后紧挨 则 forward_memory=1	
	assign forward_memory = (writeMemoryEnable)&&(if_ex_lw)&&(rt==rt_addr_ex);
	//可以解决 lw sw相同rt
	//如Lw $8,0($7) Sw $8,8($7)

	
	
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
	
	//是否停顿
	wire [4:0] rs = instruction[25:21];
	wire [4:0] rt = instruction[20:16];
	wire ctrl_stall_yes = 0;
	wire pre_ctrl_stall_yes = 0;
	wire Id_use_Ex_Rs = if_regw_ex && regw_addr_ex == rs && rs != 0;
	wire Id_use_Ex_Rt = if_regw_ex && regw_addr_ex == rt && rt != 0;
	wire Id_use_Mem_Rs = if_regw_me && regw_addr_me == rs && rs != 0;
	wire Id_use_Mem_Rt = if_regw_me && regw_addr_me == rt && rt != 0;
	
	//alu 运算后面跟beq指令 则beq stall一下
	assign stall_beq = isBranch &&
							(
							(Id_use_Ex_Rs || Id_use_Ex_Rt) //源寄存器rs和rt
	//mem阶段forward解决||(Id_use_Mem_Rs || Id_use_Mem_Rt)//源寄存器rs和rt
							);//需要前面的alu或lw指令的结果
	assign Stall = (if_ex_lw && 						
                 (
						((!immEnable) && (Id_use_Ex_Rs || Id_use_Ex_Rt))|| //源寄存器rs和rt
						(immEnable && (Id_use_Ex_Rs)) //源寄存器仅rs
						) ); //lw 跟alu 运算  必须stall。 lw 后面 跟sw也是一样的内容
	
	
	
	//符号扩展控制
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
			: code == `CODE_BEQ ? `ALU_SUB   //减法操作
			: code == `CODE_BNE ? `ALU_SUB   //减法操作
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
