
//Cache state
`define S_IDLE 0
`define S_BACK 1
`define S_FILL 2
`define S_BACK_WAIT 3
`define S_FILL_WAIT 4

// PC sources
 
`define PC_NEXT 0
`define PC_JUMP 1
`define PC_JR  2
`define PC_BEQ 4
`define PC_BNE 5

// EXE A sources
 
`define EXE_A_RS 0
//`define EXE_A_SA 1,
`define EXE_A_LINK 2,
`define EXE_A_BRANCH 3

// EXE B sources
 
`define EXE_B_RT 0
`define EXE_B_IMM 1
`define EXE_B_LINK 2
`define EXE_B_BRANCH 3

// EXE ALU operations
`define ALU_ADD 0
`define ALU_ADDU 10 //???
`define ALU_SUB 1
`define ALU_SUBU 11 //???
`define ALU_SLT 2
`define ALU_LUI 3
`define ALU_AND 4
`define ALU_OR 5
`define ALU_XOR 6
`define ALU_NOR 7
`define ALU_SL 8
`define ALU_SR 9
`define ALU_SLL 12 //???
`define ALU_SRL 13 //???
`define ALU_SRA 14 //???
`define ALU_NONE 15 //???

`define ALU_SLTU 16 //add

// WB address sources
 
`define WB_ADDR_RD 0
`define WB_ADDR_RT 1
`define WB_ADDR_LINK 2

// WB data sources
 
`define WB_DATA_ALU 0
`define WB_DATA_MEM 1

// variables
 
`define PC_RESET 32'h0000_0000

// instructions
   // bit 31:26 for instruction type
`define CODE_R_TYPE 6'b000000  // bit 5:0 for function type
`define FUNCTION_SLL 6'b000000
`define FUNCTION_SRL 6'b000010  // including ROTR(set bit 21)
`define FUNCTION_SRA 6'b000011
`define FUNCTION_SLLV 6'b000100
`define FUNCTION_SRLV 6'b000110  // including ROTRV(set bit 6)
`define FUNCTION_SRAV 6'b000111
`define FUNCTION_JR 6'b001000
//`define FUNCTION_JALR 6'b001001
//`define FUNCTION_MOVZ 6'b001010
//`define FUNCTION_MOVN 6'b001011
//`define FUNCTION_SYSCALL 6'b001100
`define FUNCTION_ADD 6'b100000
`define FUNCTION_ADDU 6'b100001
`define FUNCTION_SUB 6'b100010
`define FUNCTION_SUBU 6'b100011
`define FUNCTION_AND 6'b100100
`define FUNCTION_OR 6'b100101
`define FUNCTION_XOR 6'b100110
`define FUNCTION_NOR 6'b100111
`define FUNCTION_SLT 6'b101010
`define FUNCTION_SLTU 6'b101011
//`define FUNCTION_TGE 6'b110000
//`define FUNCTION_TGEU 6'b110001
//`define FUNCTION_TLT 6'b110010
//`define FUNCTION_TLTU 6'b110011
//`define FUNCTION_TEQ 6'b110100
//`define FUNCTION_TNE 6'b110110
//`define CODE_I 6'b000001  // bit 20:16 for function type
//`define I_FUNC_BLTZ 5'b00000
//`define I_FUNC_BGEZ 5'b00001
//`define I_FUNC_TGEI 5'b01000
//`define I_FUNC_TGEIU 5'b01001
//`define I_FUNC_TLTI 5'b01010
//`define I_FUNC_TLTIU 5'b01011
//`define I_FUNC_TEQI 5'b01100
//`define I_FUNC_TNEI 5'b01110
//`define I_FUNC_BLTZAL 5'b10000
//`define I_FUNC_BGEZAL 5'b10001
`define CODE_J 6'b000010
`define CODE_JAL 6'b000011
`define CODE_BEQ 6'b000100
`define CODE_BNE 6'b000101
//`define CODE_BLEZ 6'b000110
//`define CODE_BGTZ 6'b000111
`define CODE_ADDI 6'b001000
`define CODE_ADDIU 6'b001001
`define CODE_SLTI 6'b001010
`define CODE_SLTIU 6'b001011
`define CODE_ANDI 6'b001100
`define CODE_ORI 6'b001101
`define CODE_XORI 6'b001110
`define CODE_LUI 6'b001111
//`define CODE_CP0    6'b010000  // bit 24:21 for function type when bit 25 is not set bit 5:0 for co type when bit 25 is set
//`define CP_FUNC_MF 4'b0000
//`define CP_FUNC_MT 4'b0100
//`define CP0_CO_ERET 6'b011000
//`define CODE_LB     6'b100000
//`define CODE_LH     6'b100001
`define CODE_LW 6'b100011
//`define CODE_LBU    6'b100100
//`define CODE_LHU    6'b100101
//`define CODE_SB     6'b101000
//`define CODE_SH     6'b101001
`define CODE_SW 6'b101011
/*
// general registers
 localparam
GPR_ZERO = 0,
GPR_AT = 1,
GPR_V0 = 2,
GPR_V1 = 3,
GPR_A0 = 4,
GPR_A1 = 5,
 GPR_A2 = 6,
 GPR_A3 = 7,
 GPR_T0 = 8,
 GPR_T1 = 9,
 GPR_T2 = 10,
 GPR_T3 = 11,
 GPR_T4 = 12,
 GPR_T5 = 13,
 GPR_T6 = 14,
 GPR_T7 = 15,
 GPR_S0 = 16,
 GPR_S1 = 17,
 GPR_S2 = 18,
 GPR_S3 = 19,
 GPR_S4 = 20,
 GPR_S5 = 21,
 GPR_S6 = 22,
 GPR_S7 = 23,
 GPR_T8 = 24,
 GPR_T9 = 25,
 GPR_K0 = 26,
 GPR_K1 = 27,
 GPR_GP = 28,
 GPR_SP = 29,
 GPR_FP = 30,
 GPR_RA = 31;
*/