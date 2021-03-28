`timescale 1ns / 1ps

module Cpu (

		input clock,
		input reset,
	

		//debug�������
		input wire debug_en,  // debug enable
		input wire debug_step,  // debug step clock
		input wire [6:0] debug_addr,  // debug address
		output wire [31:0] debug_data  // debug data

	);

	// if�׶����� �ź�
	wire [31:0] if_pc;    		 // pcֵ

	wire [31:0] if_pc_4;  		 // pc+4ֵ
	wire [31:0] if_instruction; // ָ��
	wire [31:0] if_nextPc;      // pc����һ��ֵ

	wire [31:0] id_pc_4;        // pc+4
	wire [31:0] id_instruction; // ָ��

	// id�׶����� �ź�
	wire branchEnable;		    // BRANCH pc��ת�����ź�
	wire [31:0] branchAddr;     // pc��ת��ַ
	wire [31:0] id_shiftAmount; // ��λ��
	wire [31:0] id_immediate;   // ������ֵ
	wire [31:0] id_registerRsOrPc_4; //rs��pc+4 ALU��A��� -��һ�����
	wire [31:0] id_registerRtOrZero; //rt��0 ��������B��� -��һ�����
	wire [3:0] id_ALUC;			 // ALU�������
	wire id_shiftEnable;        // ALU��A���ѡ����λ�������ź�
	wire id_immEnable;          // ALU��B���ѡ�������������ź�
	wire id_writeRegEnable;		 // regfile�Ĵ���д�����ź�
	wire [4:0] id_writeRegAddr; // regfile�Ĵ���д��ַ
	wire id_mem2Reg;				 // ѡ��memory����д���Ĵ��������ź�
	wire id_writeMemoryEnable;  // swд�ڴ�����ź�
	
	//ex�׶�����
	wire [31:0] ex_instruction; // ָ��
	wire [31:0] ex_shiftAmount; // ��λ��
	wire [31:0] ex_immediate;   // ������
	wire [31:0] ex_registerRsOrPc_4; // 
	wire [31:0] ex_registerRtOrZero; //
	wire [31:0] exe_registerRtOrZero_new;//����forwarding��ex_registerRtOrZero
	wire [3:0] ex_ALUC;  		 // ALU��������ź�
	wire ex_shiftEnable;			 // ALU��A���ѡ����λ�������ź�
	wire ex_immEnable;			 // ALU��B���ѡ�������������ź�
	wire ex_writeRegEnable;     // regfile�Ĵ���д�����ź�
	wire [4:0] ex_writeRegAddr; // regfile�Ĵ���д��ַ
	wire ex_mem2Reg;				 // ѡ��memory����д���Ĵ��������ź�
	wire ex_writeMemoryEnable;  // swд�ڴ�����ź�

	wire [31:0] ex_aluOutput;   // ALU�������

	//mem�׶�����
	wire [31:0] mem_instruction;// ָ��
	wire mem_writeRegEnable;    // �Ĵ���д�����ź�
	wire [4:0] mem_writeRegAddr;// �Ĵ���д��ַ
	wire mem_mem2Reg;				 // ѡ��memory����д���Ĵ��������ź�
	wire [31:0] mem_aluOutput;  // ALU�������
	wire mem_writeMemoryEnable; // swд�ڴ�����ź�
	wire [31:0] mem_registerRtOrZero; // ��ʱ��rt������ ����дmemory

	wire [31:0] mem_memoryData; // �Ĵ���ȡ����

	//wb�׶�����
	wire [31:0] wb_instruction; // ָ��
	wire wb_writeRegEnable;		 // �Ĵ���дʹ��
	wire [4:0] wb_writeRegAddr; // �Ĵ���д��ַ
	wire wb_mem2Reg;				 // ѡ��memory����д���Ĵ��������ź�
	wire [31:0] wb_memoryData;  // �ڴ����� ����ѡ��
	wire [31:0] wb_aluOutput;   // ALU������� ����ѡ��

	wire [31:0] wb_registerWriteData; // ����Ҫд������
	
	//����debug���		
	//debug�����ʾ�ź�
		// instruction signals
	wire inst_ren;
	wire [31:0] if_inst_addr;
	wire [31:0] if_inst_data;
	wire [31:0] id_inst_addr;
	wire [31:0] id_inst_data;
	wire [31:0] ex_inst_addr;
	wire [31:0] ex_inst_data;
	wire [31:0] me_inst_addr;
	wire [31:0] me_inst_data;
	
	// memory signals
	wire mem_ren, mem_wen;
	wire [31:0] mem_addr;
	wire [31:0] mem_data_r;
	wire [31:0] mem_data_w;
	
	//reg
	wire [4:0] addr_rs, addr_rt, addr_rd;
	wire [31:0] data_rs, data_rt, data_imm;	
	reg [4:0] regw_addr;
	reg [31:0] regw_data;
	
	//alu
	reg [31:0] opa, opb;
	wire [31:0] alu_out;
	
	//ctrl
	reg cpu_rst, cpu_en;  ////
	
	wire stall;
	wire stall_beq;//beqָ����Ҫstall
	wire cache_stall;
	
	
	assign clk = debug_en ? debug_step : clock;


//��һ��pc �Ĵ���
	Pc pc (
		.clock(clk),
		.reset(reset),
		.stall(stall||cache_stall),
		.stall_beq(stall_beq),

		.nextPc(if_nextPc[31:0]),
		.pc(if_pc[31:0])
	);
	
//IF�׶�
	IfStage ifStage (
      .cpu_en(cpu_en),
      .cpu_rst(cpu_rst),
		.clock(clk),

		.pc(if_pc[31:0]),

		.branchEnable(branchEnable),
		.branchAddr(branchAddr[31:0]),

		.pc_4(if_pc_4[31:0]),

		.instruction(if_instruction[31:0]),

		.nextPc(if_nextPc[31:0])
	);

//IfId�Ĵ���
//����Pc+4,����Id�׶μ�����ת��ַ
//����ָ��--����Id�׶�����
	IfIdRegisters ifIdRegisters (

		.clock(clk),
		.reset(reset),
		
		.stall(stall||cache_stall),
		.stall_beq(stall_beq),
		.jump_delect_pre_inst(branchEnable),//��Ҫ��ID�׶�ǰ�Ӵ�predic not takenָ���Ԥȡָ��

		.if_pc_4(if_pc_4[31:0]),

		.if_instruction(if_instruction[31:0]),

		.id_pc_4(id_pc_4[31:0]),

		.id_instruction(id_instruction[31:0])
	);

	wire id_forward_memory;
	wire ex_forward_memory;

	IdStage idStage (
		
		.cpu_rst(cpu_rst),
		.cpu_en(cpu_en),

		.clock(clk),
		.reset(reset),

		.pc_4(id_pc_4[31:0]),

		.instruction(id_instruction[31:0]),
		
		.if_regw_ex(ex_writeRegEnable),//ex��Ҫд�Ĵ�����?
		.if_regw_me(mem_writeRegEnable),//me��Ҫд�Ĵ�����?
		.regw_addr_ex(ex_writeRegAddr[4:0]),
		.regw_addr_me(mem_writeRegAddr[4:0]),
		.rt_addr_ex(ex_instruction[20:16]),
		.rt_addr_me(mem_instruction[20:16]),
		.if_ex_sw(ex_writeRegEnable),
		.if_ex_lw(ex_mem2Reg),
		.if_me_sw(mem_writeRegEnable),
		.if_me_lw(mem_mem2Reg),
		
		.branchEnable(branchEnable),
		.branchAddr(branchAddr[31:0]),

		.shiftAmount(id_shiftAmount[31:0]),
		.immediate(id_immediate[31:0]),

		.registerRsOrPc_4(id_registerRsOrPc_4[31:0]),
		.registerRtOrZero(id_registerRtOrZero[31:0]),

		.ALUC(id_ALUC[3:0]),
		.shiftEnable(id_shiftEnable),
		.immEnable(id_immEnable),

		.writeRegEnable(id_writeRegEnable),
		.writeRegAddr(id_writeRegAddr[4:0]),
		.mem2Reg(id_mem2Reg),

		.writeMemoryEnable(id_writeMemoryEnable),

		.wb_writeRegEnable(wb_writeRegEnable),
		.wb_writeRegAddr(wb_writeRegAddr[4:0]),
		.wb_registerWriteData(wb_registerWriteData[31:0]),
		
		.Stall(stall),
		.stall_beq(stall_beq),

		//debug�������
		.debug_addr(debug_addr[5:0]),
		.debug_data(debug_data_reg[31:0]),   //��regfile�������
		
		
		//forward ���
		.ex_mem2Reg(ex_mem2Reg),			
		.mem_mem2Reg(mem_mem2Reg), 
		.ex_aluOutput(ex_aluOutput[31:0]),	 //��һ��forwarding����
	   .mem_aluOutput(mem_aluOutput[31:0]), //�ڶ���forwarding����
		.mem_memoryData(mem_memoryData[31:0]), //������forwarding����
		
		
		.forward_memory(id_forward_memory)	//ʹ�� lw������ ת�� �������exָ���aluoutput //Ӧ�� û����

	);
	
	
	
	

	IdExRegisters idExRegisters (

		.clock(clk),
		.reset(reset),
		.cache_stall(cache_stall),


		.id_instruction(id_instruction[31:0]),

		.id_shiftAmount(id_shiftAmount[31:0]),
		.id_immediate(id_immediate[31:0]),

		.id_registerRsOrPc_4(id_registerRsOrPc_4[31:0]),
		.id_registerRtOrZero(id_registerRtOrZero[31:0]),

		.id_ALUC(id_ALUC[3:0]),
		.id_shiftEnable(id_shiftEnable),
		.id_immEnable(id_immEnable),

		.id_writeRegEnable(id_writeRegEnable),
		.id_writeRegAddr(id_writeRegAddr[4:0]),
		.id_mem2Reg(id_mem2Reg),

		.id_writeMemoryEnable(id_writeMemoryEnable),
		
		.Stall(stall),
		
		///lw ������ forwad �� mem
		.id_forward_memory(id_forward_memory),
		.ex_forward_memory(ex_forward_memory),
		////
		

		.ex_instruction(ex_instruction[31:0]),

		.ex_shiftAmount(ex_shiftAmount[31:0]),
		.ex_immediate(ex_immediate[31:0]),

		.ex_registerRsOrPc_4(ex_registerRsOrPc_4[31:0]),
		.ex_registerRtOrZero(ex_registerRtOrZero[31:0]),

		.ex_ALUC(ex_ALUC[3:0]),
		.ex_shiftEnable(ex_shiftEnable),
		.ex_immEnable(ex_immEnable),

		.ex_writeRegEnable(ex_writeRegEnable),
		.ex_writeRegAddr(ex_writeRegAddr[4:0]),
		.ex_mem2Reg(ex_mem2Reg),

		.ex_writeMemoryEnable(ex_writeMemoryEnable)
	);

	ExStage exStage (

		.shiftAmount(ex_shiftAmount[31:0]),
		.immediate(ex_immediate[31:0]),

		.ex_ALUC(ex_ALUC[3:0]),
		.ex_shiftEnable(ex_shiftEnable),
		.ex_immEnable(ex_immEnable),

		.registerRsOrPc_4(ex_registerRsOrPc_4[31:0]),
		.registerRtOrZero(ex_registerRtOrZero[31:0]),

		//forward memory lw��sw
		.ex_forward_memory(ex_forward_memory),
		//�ڴ�����
		.mem_memoryData(mem_memoryData[31:0]),
	
		
		.exe_registerRtOrZero(exe_registerRtOrZero_new[31:0]),
		.aluOutput(ex_aluOutput[31:0])

	);

	ExMemRegisters exMemRegisters (

		.clock(clk),
		.reset(reset),
		.cache_stall(cache_stall),

		.ex_instruction(ex_instruction[31:0]),

		.ex_writeRegEnable(ex_writeRegEnable),
		.ex_writeRegAddr(ex_writeRegAddr[4:0]),
		.ex_mem2Reg(ex_mem2Reg),

		.ex_aluOutput(ex_aluOutput[31:0]),
		.ex_writeMemoryEnable(ex_writeMemoryEnable),
		.ex_registerRtOrZero(exe_registerRtOrZero_new[31:0]),

		.mem_instruction(mem_instruction[31:0]),

		.mem_writeRegEnable(mem_writeRegEnable),
		.mem_writeRegAddr(mem_writeRegAddr[4:0]),
		.mem_mem2Reg(mem_mem2Reg),

		.mem_aluOutput(mem_aluOutput[31:0]),
		.mem_writeMemoryEnable(mem_writeMemoryEnable),
		.mem_registerRtOrZero(mem_registerRtOrZero[31:0])
	);

	MemStage memStage (
		.cpu_rst(cpu_rst),
		.cpu_en(cpu_en),

		.clock(clk),
		.reset(reset),

		.aluOutput(mem_aluOutput[31:0]),
		.writeMemoryEnable(mem_writeMemoryEnable),
		.read_en(mem_mem2Reg),//read to reg
		.registerRtOrZero(mem_registerRtOrZero[31:0]),
		.memoryData(mem_memoryData[31:0]),
		.cache_stall(cache_stall)
	);

	MemWbRegisters memWbRegisters (

		.clock(clk),
		.reset(reset),
		.cache_stall(cache_stall),

		.mem_instruction(mem_instruction[31:0]),

		.mem_writeRegEnable(mem_writeRegEnable),
		.mem_writeRegAddr(mem_writeRegAddr[4:0]),
		.mem_mem2Reg(mem_mem2Reg),
		.mem_memoryData(mem_memoryData[31:0]),
		.mem_aluOutput(mem_aluOutput[31:0]),

		.wb_instruction(wb_instruction[31:0]),

		.wb_writeRegEnable(wb_writeRegEnable),
		.wb_writeRegAddr(wb_writeRegAddr[4:0]),
		.wb_mem2Reg(wb_mem2Reg),
		.wb_memoryData(wb_memoryData[31:0]),
		.wb_aluOutput(wb_aluOutput[31:0])		
	);

	WbStage wbStage (
		.mem2Reg(wb_mem2Reg),
		.memoryData(wb_memoryData[31:0]),
		.aluOutput(wb_aluOutput[31:0]),
		.registerWriteData(wb_registerWriteData[31:0])
	);
	
	

	//debug
	// debug control
	reg debug_step_prev;
	
	always @(posedge clock) begin
		debug_step_prev <= debug_step;
	end
	

	always @(*) begin
		cpu_rst = 0;
		cpu_en = 1;
		if (reset) begin
			cpu_rst = 1;
		end
		// suspend and step execution
										//��׽�����źŵ�������
		else if ((debug_en) && (~debug_step_prev && debug_step)) begin
			cpu_en = 1;
		end
		
	end
	
	
	// debug�������
	
	
	//alu��������ѡ��---����aluģ��
	wire [31:0] aluInputA = ex_shiftEnable ? ex_shiftAmount : ex_registerRsOrPc_4;
	wire [31:0] aluInputB = ex_immEnable ? ex_immediate : ex_registerRtOrZero;
	////////////////////////
	 
	wire [31:0] debug_data_reg;
	reg [31:0] debug_data_signal;
	
	assign if_inst_addr = if_pc[31:0];
	assign if_inst_data = if_instruction[31:0];
	assign id_inst_addr = branchAddr[31:0];	//������ʾ������ת��ַ
	assign id_inst_data = id_instruction[31:0];
	assign ex_inst_addr = 0;    //����׶β���pc
	assign ex_inst_data = ex_instruction[31:0];
	assign me_inst_addr = 0;    //����׶�pcû��
	assign me_inst_data = mem_instruction[31:0];
	assign addr_rs = id_instruction[25:21];
	assign data_rs = id_registerRsOrPc_4;     //precisely��rs�ô�regfile����
	assign addr_rt = id_instruction[15:11];	
	assign data_rt = id_registerRtOrZero;		//precisely��rt�ô�regfile����
	//assign opa = aluInputA[31:0];  
	//assign opb = aluInputB[31:0];
	assign alu_out = ex_aluOutput[31:0];
	
	assign inst_ren = 0;   ////��CPU�޴�����
	assign mem_ren = 0;    ////��CPU�޴�����
	assign mem_wen = mem_writeMemoryEnable;
	
	assign mem_addr = mem_aluOutput[31:0];
	assign mem_data_w = mem_registerRtOrZero[31:0];
	assign mem_data_r = mem_memoryData[31:0];
	//assign regw_addr = wb_writeRegAddr[4:0];
	//assign regw_data = wb_registerWriteData[31:0];
	
		
	always @(posedge clock) begin
		case (debug_addr[4:0])
			0: debug_data_signal <= if_inst_addr;
			1: debug_data_signal <= if_inst_data;
			2: debug_data_signal <= id_inst_addr;
			3: debug_data_signal <= id_inst_data;
			4: debug_data_signal <= ex_inst_addr;
			5: debug_data_signal <= ex_inst_data;
			6: debug_data_signal <= me_inst_addr;
			7: debug_data_signal <= me_inst_data;
			8: debug_data_signal <= {27'b0, addr_rs};
			9: debug_data_signal <= data_rs;
			10: debug_data_signal <= {27'b0, addr_rt};
			11: debug_data_signal <= data_rt;
			12: debug_data_signal <= data_imm;
			13: debug_data_signal <= aluInputA[31:0];//opa;
			14: debug_data_signal <= aluInputB[31:0];//opb;
			15: debug_data_signal <= alu_out;
			16: debug_data_signal <= 0;
			17: debug_data_signal <= 0;
			18: debug_data_signal <= {19'b0, inst_ren, 7'b0, mem_ren, 3'b0, mem_wen};
			19: debug_data_signal <= mem_addr;
			20: debug_data_signal <= mem_data_w;
			21: debug_data_signal <= mem_data_r;
			22: debug_data_signal <= {27'b0, wb_writeRegAddr[4:0]};
			23: debug_data_signal <= wb_registerWriteData[31:0];
			24: debug_data_signal <= stall;
			default: debug_data_signal <= 32'hFFFF_FFFF;
		endcase
	end
	
	assign
		debug_data = debug_addr[5] ? debug_data_signal : debug_data_reg;
	

	
endmodule
