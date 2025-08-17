module Hazard_Detection(
    input [4:0] RA0_D, RA1_D, RA0_E, RA1_E,   
    input RS1Used_D, RS2Used_D, RS1Used_E, RS2Used_E, 
    input [4:0] WA_E, WA_M1, WA_M2, WA_W,     // WA_M2 ?
    input Load_E, Load_M1,
    input WEN_M1, WEN_M2, WEN_W,    
		input Jump, Branch, Taken,
    output reg PCWrite, IMRead, FDWrite, DEFlush, 
    output reg [1:0] FW1, FW2    
);

reg stall;
always@* begin
	PCWrite = 1; 
	IMRead = 1; 
	FDWrite = 1; 
	DEFlush = 0;
	FW1 = 2'd0; FW2 = 2'd0; 
	stall = 0;
	// Branch & Jump
	if(Jump || Branch && Taken) IMRead = 0; 
	
	// Forwarding (No Stall)
		// Select ALUSRC1
		if (RS1Used_E) begin
				if ((~WEN_M1) && (RA0_E == WA_M1)) FW1 = 2'd1; // Type1 Bypassing
				else if ((~WEN_M2) && (RA0_E == WA_M2)) FW1 = 2'd2; // Type2 Bypassing
				else if ((~WEN_W) && (RA0_E == WA_W)) FW1 = 2'd3; // Type3 Bypassing
		end

		// Select ALUSRC2
		if (RS2Used_E) begin 
				if ((~WEN_M1) && (RA1_E == WA_M1)) FW2 = 2'd1;  // Type1 Bypassing
				else if ((~WEN_M2) && (RA1_E == WA_M2)) FW2 = 2'd2;   // Type2 Bypassing
				else if ((~WEN_W) && (RA1_E == WA_W)) FW2 = 2'd3;   // Type3 Bypassing
		end
	
	// Stall
		// Write Back STALL
		if( (~WEN_W) && 
				( ( RS1Used_D && (RA0_D == WA_W) ) || 
					( RS2Used_D && (RA1_D == WA_W) ) ) ) stall = 1'b1;
		
		// Load-Use STALL
		if ( Load_E && 
			 ( ( RS1Used_D && (RA0_D == WA_E) ) || 
				 ( RS2Used_D && (RA1_D == WA_E) ) ) ) stall = 1'b1;
		
		if ( Load_M1 && 
			 ( ( RS1Used_D && (RA0_D == WA_M1) ) || 
				 ( RS2Used_D && (RA1_D == WA_M1) ) ) ) stall = 1'b1;
				 
		if (stall) begin
				PCWrite = 0;    
				IMRead  = 0;    
				FDWrite = 0;    
				DEFlush = 1;    
		end
	/*
	1. no stall
	type1: ~wen_m1 & wa_m1 = ra_e 
	type2: ~wen_m2 & wa_m2 = ra_e 
	type3: ~wen_w & wa_w = ra_e
	
	2. wb stall: ~wen_w & wa_w = ra_d
	3. load-use stall
	type1: load_e & wa_e = ra_d
	type2: load_m1 & wa_m1 = ra_d
	
	*/
end

endmodule
