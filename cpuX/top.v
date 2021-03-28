

module top (
	input wire CLK_200M_P,CLK_200M_N,
	input wire [7:0] SW,
	input wire RSTN,
	output wire [4:0] BTN_X,	//matrix button for output
	input wire [3:0] BTN_Y,	//matrix button for input
	output wire SEGLED_CLK,
	output wire SEGLED_DO, 
	output wire SEGLED_PEN,
	output wire LED_PEN, 
	output wire LED_DO, 
	output wire LED_CLK,
	output wire [3:0]VGA_B,
	output wire [3:0]VGA_G,
	output wire [3:0]VGA_R,
	output wire HS, VS
	);
	
	///cpu相关数据
	wire [31:0] cpu_if_pc;
	wire [31:0] cpu_if_nextPc;
	wire [31:0] cpu_if_instruction;
	wire [31:0] cpu_id_instruction;
	//wire cpu_id_shouldStall;
	wire cpu_id_shouldForwardRegisterRs;
	wire cpu_id_shouldForwardRegisterRt;
	wire [32 * 32 - 1 : 0] cpu_id_registers;
	wire [31:0] cpu_ex_instruction;
	wire [31:0] cpu_ex_aluInputA;
	wire [31:0] cpu_ex_aluInputB;
	wire [31:0] cpu_ex_aluOutput;
	wire [31:0] cpu_mem_instruction;
	wire [31:0] cpu_mem_memoryAddress;
	wire [31:0] cpu_mem_memoryReadData;
	wire cpu_mem_shouldWriteMemory;
	wire [31:0] cpu_mem_memoryWriteData;
	wire [31:0] cpu_wb_instruction;
	wire cpu_wb_shouldWriteRegister;
	wire [4:0] cpu_wb_registerWriteAddress;
	wire [31:0] cpu_wb_registerWriteData;
	//////////////
	
	
	// clock generator
	wire clk_cpu, clk_disp;
	wire locked;
	wire clk200MHz;
	
	clk_diff CLK_DIFF (
		.clk200P(CLK_200M_P),
		.clk200N(CLK_200M_N),
		.clk200MHz(clk200MHz)
	);
	my_clk_gen CLK_GEN (
		.clkin1(clk200MHz),
		.CLK_OUT1(), //100MHz
		.CLK_OUT2(), //50MHz
		.CLK_OUT3(clk_disp), //25MHz
		.CLK_OUT4(clk_cpu) //10MHz
		);
		
	///////////////////


	///button相关
	wire [19:0] btn;
	wire btn_reset, btn_step;
	wire btn_interrupt;
	wire disp_prev, disp_next;

	btn_scan #(
		.CLK_FREQ(25)
		) BTN_SCAN (
		.clk(clk_disp),
		.rst(1'b0),
		.btn_x(BTN_X),
		.btn_y(BTN_Y),
		.result(btn)
		);
	
	assign
		btn_step = btn[16],
		btn_interrupt = btn[19];
	///////////////

	
	
	// reset
	reg rst_all;
	reg [15:0] rst_count = 16'hFFFF;
	
	always @(posedge clk_cpu) begin
		rst_all <= (rst_count != 0);
		rst_count <= {rst_count[14:0], (!RSTN)};
	end

	wire [31:0] disp_data;
	
	display DISPLAY (
		.clk(clk_disp),
		.rst(rst_all),
		.en(8'b11111111),
		.data(0),
		.dot(8'b00000000),
		.led(~{btn_step, btn_interrupt, 6'b0, SW}),
		.led_clk(LED_CLK),
		.led_en(LED_PEN),
		.led_do(LED_DO),
		.seg_clk(SEGLED_CLK),
		.seg_en(SEGLED_PEN),
		.seg_do(SEGLED_DO)
		);
	wire [6:0] debug_addr;
	wire [31:0] debug_data;
	
	
	
	///我还是比较担心时钟频率的问题
	///这个兼容原理上是没有问题的的 但具体的我也不完全知道
	//实验的时候再看吧  ///实在不行就直接在张海的上面修改了  整个结构也不换了
	
	
		
		Cpu cpu (

		.clock(clk_cpu),   //变慢
		.reset(rst_all),
		
		.debug_en(SW[0]),  // debug enable
		.debug_step(btn_step),  // debug step clock
		.debug_addr(debug_addr),  // debug address
		.debug_data(debug_data)  // debug data
		
	);
	
		
		
	wire [9:0] vga_h_count;
	wire [9:0] vga_v_count;
	wire	vga_rdn;
	wire [11:0] vga_data;
		
	vga VGA(
		.clk(clk_disp),					// vga clk = 25MHz
		.rst(0),  // never reset
		.Din(vga_data),	
		.h_count(vga_h_count),
		.v_count(vga_v_count),
		.rdn(vga_rdn),
		.R(VGA_R),
		.G(VGA_G),
		.B(VGA_B),
		.HS(HS),
		.VS(VS)
		); 
	
	vga_debug VGA_DEBUG(
	.clk(clk_disp),
	.debug_data(debug_data),
	.h_count(vga_h_count),
	.v_count(vga_v_count),
	.debug_addr(debug_addr),
	.dout(vga_data)
	
    );
endmodule
