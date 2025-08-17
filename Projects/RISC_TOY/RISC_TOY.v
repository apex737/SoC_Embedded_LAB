/*****************************************
    
    Team XX : 
        2024000000    Kim Mina
        2024000001    Lee Minho
*****************************************/


// You are able to add additional modules and instantiate in RISC_TOY.

////////////////////////////////////
//  TOP MODULE
////////////////////////////////////
module RISC_TOY (
	input CLK, RSTN,
	input [31:0] INSTR, 
	input [31:0] DRDATA, 
	output [29:0] IADDR, 
	output [29:0] DADDR, 
	output IREQ, DREQ, DRW, 
	output [31:0] DWDATA    
);

/////////////////////////////////////
// Declaration
/////////////////////////////////////
	// IF Stage 
	wire [1:0] PCSRC; 
	wire [31:0] NextPC;
	wire [29:0] IADDR_o;
	wire PCWrite;
	wire FDWrite;
	wire IMRead;
	wire [31:0] PCADD4_F1; 
	
	// FD (Pipeline Register)
	wire [31:0] INSTR_i, PCADD4_F2, INSTR_o, PCADD4_D;
	
	// ID Stage
	wire Sel1_D, RS1Used_D, RS2Used_D;
	wire [2:0] Sel2_D;
	wire [1:0] SelWB_D;
	wire [3:0] ALUOP_D;
	wire WEN_D, DRW_D, DREQ_D;
	wire Jump, Branch, Taken, Load_D;
	wire [31:0] DOUT0_D, DOUT1_D;
	wire [4:0] RA0_D, RA1_D, WA_D;
	wire [31:0] Iext_D, Jext, zeroExt_D, shamtExt_D;
	wire signed [31:0] JPC_D;
	
	// DE (Pipeline Register)
	wire DEFlush;
	wire [1:0] SelWB_E;
	wire WEN_E, Load_E;
	wire DRW_E, DREQ_E, Sel1_E, RS1Used_E, RS2Used_E;
	wire [2:0] Sel2_E;
  wire [3:0] ALUOP_E;
	wire [4:0] RA0_E, RA1_E, WA_E;
  wire [31:0] DOUT0_E, DOUT1_E, PCADD4_E;
	wire [31:0] zeroExt_E, Iext_E, shamtExt_E, JPC_E;


	// EX Stage
	// MuxSRC
	wire [31:0] SRC1, SRC2; 
	// Mux3 : FWD1, FWD2
	wire [31:0] ALUSRC1, ALUSRC2;
	wire [1:0] FW1, FW2;
	wire [31:0] ALUOUT_E;
	
	// M1 Stage
	wire WEN_M1, Load_M1, DRW_M1, DREQ_M1;
	wire [1:0] SelWB_M1;
	wire [4:0] WA_M1;
	wire [31:0]	PCADD4_M1, ALUOUT_M1, DOUT0_M, LoadData_M;

	// M2 Stage
	wire WEN_M2, DRW_M2, DREQ_M2;
	wire [1:0] SelWB_M2;
	wire [4:0] WA_M2;
	wire [31:0]	PCADD4_M2, ALUOUT_M2;
	
	// WB Stage
	wire WEN_W;
	wire [1:0] SelWB_W; 
	wire [4:0] WA_W;
	wire [31:0] ALUOUT_W, LoadData_W, PCADD4_W;
	wire [31:0]	WBData; 



////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Assign & Instantiation
////////////////////////////////////////////////////////////////////////////////////////////////////////////

// IF Stage
	assign PCADD4_F1 = IADDR_o + 4;
	assign PCSRC = {Jump, Branch&Taken};
	
	// Mux3 (I0, I1, I2, Sel, Out)
	Mux3 muxPC (PCADD4_F1, DOUT0_D, JPC_D, PCSRC, NextPC);
		
	// PC_Main
	PC instPC (PCWrite, CLK, RSTN, NextPC, IADDR_o);
	
	// PCBuffer
	PCBuffer InstPB(CLK, RSTN, IMRead, PCADD4_F1, PCADD4_F2);
	
	// IM
	assign IREQ = IMRead;
	assign IADDR = IADDR_o;
	assign INSTR_i = INSTR;
	
	// FD (Pipeline Register)
	FD instFD (CLK, RSTN, FDWrite, INSTR_i, PCADD4_F2, INSTR_o, PCADD4_D);
	
// ID Stage
	// INSTR Decode
	wire [4:0] opcode = INSTR_o[31:27];
	wire [4:0] ra = INSTR_o[26:22];
	wire [4:0] rb = INSTR_o[21:17];
	wire [4:0] rc = INSTR_o[16:12];
	wire shSrc = INSTR_o[5];
	wire [4:0] shamt = INSTR_o[4:0];
	wire [2:0] cond = INSTR_o[2:0];
	wire [16:0] Imm17 = INSTR_o[16:0];
	wire [21:0] Imm22 = INSTR_o[21:0];
	wire NOP = ~(|INSTR_o);
	// Control Unit	
	Control InstCtrl(
		// Input 
		opcode, rb,
		shSrc, NOP,
		// Output
		Sel1_D,
		Sel2_D,
		SelWB_D,
		ALUOP_D,
		WEN_D, DRW_D, DREQ_D, 
		Jump, Branch, Load_D,
		RS1Used_D, RS2Used_D
	);
	
	// REGISTER FILE FOR GENRAL PURPOSE REGISTERS
	assign RA0_D = DRW_D ? ra : rb;
	assign RA1_D = DRW_D ? rb : rc;
	REGFILE    #(.AW(5), .ENTRY(32))    RegFile (
								.CLK    (CLK),
								.RSTN   (RSTN),
								.WEN    (WEN_W),
								.WA     (WA_W),
								.DI     (WBData),
								.RA0    (RA0_D),
								.RA1    (RA1_D),
								.DOUT0  (DOUT0_D),
								.DOUT1  (DOUT1_D)
	);
	
	// BranchTaken
	BranchTaken InstBR(DOUT1_D, cond, Taken);
	
	// SignExt
	SignExt SE(Imm17, Imm22, shamt, Iext_D, Jext, zeroExt_D, shamtExt_D);
	assign JPC_D = $signed(Jext) + $signed(PCADD4_D);

// DE (Pipeline Register)
	assign WA_D = ra;
	DE InstDE(
		// Input
		CLK, RSTN, DEFlush, 
		SelWB_D,
		WEN_D, Load_D, 
		DRW_D, DREQ_D, RS1Used_D, RS2Used_D, Sel1_D,
		Sel2_D, 
		ALUOP_D,
		RA0_D, RA1_D, WA_D,
		DOUT0_D, DOUT1_D, PCADD4_D,
		JPC_D, zeroExt_D, Iext_D, shamtExt_D,
		// Output
		SelWB_E,
		WEN_E, Load_E,
		DRW_E, DREQ_E, RS1Used_E, RS2Used_E, Sel1_E,
		Sel2_E, 
		ALUOP_E,
		RA0_E, RA1_E, WA_E,
		DOUT0_E, DOUT1_E, PCADD4_E,
		JPC_E, zeroExt_E, Iext_E, shamtExt_E
	);
	
// EX Stage
	// MuxSRC1
	assign SRC1 = Sel1_E ? Iext_E : DOUT0_E;
	// MuxSRC2
	MuxSrc2 InstMuxSrc2(
		Sel2_E, DOUT1_E, Iext_E, shamtExt_E, zeroExt_E, JPC_E, SRC2
	);
	
	// Mux4 (I0, I1, I2, I3, Sel, Out)
	Mux4 muxFWD1(SRC1, ALUOUT_M1, ALUOUT_M2, WBData, FW1, ALUSRC1);
	Mux4 muxFWD2(SRC2, ALUOUT_M1, ALUOUT_M2, WBData, FW2, ALUSRC2);

	// ALU
	ALU InstALU(ALUOP_E, ALUSRC1, ALUSRC2, ALUOUT_E);

	// EM (Pipeline Register)
	EM InstEM(
		// Input
		CLK, RSTN,
		WEN_E, DRW_E, DREQ_E, Load_E,
		SelWB_E,
		WA_E, 
		PCADD4_E, ALUOUT_E, DOUT0_E, 
		// Output
		WEN_M1, DRW_M1, DREQ_M2, Load_M1,
		SelWB_M1,
		WA_M1,
		PCADD4_M1, ALUOUT_M1, DOUT0_M
	);
	
// M1 Stage
	// DM
	assign DADDR = ALUOUT_M1;
	assign DWDATA = DOUT0_M;
	assign DREQ = DREQ_M2;
	assign DRW = DRW_M1;
	assign LoadData_M = DRDATA;

// M2 Stage
	MemBuffer InstMB(
		CLK, RSTN,
		SelWB_M1,
		WEN_M1,
		ALUOUT_M1, PCADD4_M1,		
		WA_M1,
		SelWB_M2,
		WEN_M2, 
		ALUOUT_M2, PCADD4_M2,
		WA_M2
	);
	// MW (Pipeline Register)
		MW InstMW(
			// Input
			.CLK(CLK), .RSTN(RSTN),
			.SelWB_M2(SelWB_M2),
			.WEN_M2(WEN_M2),
			.ALUOUT_M2(ALUOUT_M2), .LoadData_M(LoadData_M), .PCADD4_M2(PCADD4_M2),
			.WA_M2(WA_M2),
			// Output
			.SelWB_W(SelWB_W),
			.WEN_W(WEN_W),
			.ALUOUT_W(ALUOUT_W), .LoadData_W(LoadData_W), .PCADD4_W(PCADD4_W),
			.WA_W(WA_W)
		);

// WB Stage
	// Mux3 (I0, I1, I2, Sel, Out)
	Mux3 muxWB (ALUOUT_W, LoadData_W, PCADD4_W, SelWB_W, WBData);

	Hazard_Detection InstHD (
		.RA0_D(RA0_D), .RA1_D(RA1_D), .RA0_E(RA0_E), .RA1_E(RA1_E),
		.RS1Used_D(RS1Used_D), .RS2Used_D(RS2Used_D),
		.RS1Used_E(RS1Used_E), .RS2Used_E(RS2Used_E),
		.WA_E(WA_E), .WA_M1(WA_M1), .WA_M2(WA_M2), .WA_W(WA_W),
		.Load_E(Load_E), .Load_M1(Load_M1),
		.WEN_M1(WEN_M1), .WEN_M2(WEN_M2), .WEN_W(WEN_W), 
		.Jump(Jump), .Branch(Branch), .Taken(Taken),
		// output
		.PCWrite(PCWrite), .IMRead(IMRead), .FDWrite(FDWrite), .DEFlush(DEFlush),
		.FW1(FW1), .FW2(FW2)
	);
	
endmodule
