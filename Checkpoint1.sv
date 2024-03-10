module FSM(ALE,CLK,RESET,RD,WR,CS,load,OE,Wrenb);
	
	input logic ALE,CLK,RD,WR,CS,RESET;
	output logic load,OE,Wrenb;
	
	typedef enum logic [4:0] {
	
		IDLE = 5'b00001,
		ADDLOAD =5'b00010,
		READ = 5'b00100,
		WRITE = 5'b01000,
		DELAY = 5'b10000
	
	} State;
	
	State Cur_State , Nxt_State;
	
	always_ff @(posedge CLK)
	begin
		if(RESET)
			Cur_State <= IDLE;
		else
			Cur_State <= Nxt_State;
	end
	
	always_comb
	begin
		{load,OE,Wrenb} = 3'b000;
		unique case(Cur_State)
			IDLE	:	{load,OE,Wrenb} = 3'b000;
			ADDLOAD	:	load = 1;
			READ	:	OE = 1;
			WRITE	:	Wrenb = 1;
			DELAY	:	{load,OE,Wrenb} = 3'b000;
		endcase
	end
	
	always_comb
	begin
		Nxt_State = Cur_State;
		unique case(Cur_State)
			IDLE	:	begin
							if(CS && ALE)
								Nxt_State = ADDLOAD;
							else
								Nxt_State = IDLE;
						end
						
			ADDLOAD	:	begin
							if(~RD)
								Nxt_State = READ;
							else if(~WR)
								Nxt_State = WRITE;
							else
								Nxt_State = ADDLOAD;
						end
			READ	:	begin
							if(RD)
								Nxt_State = DELAY;
						end
			WRITE	:	begin
							if(WR)
								Nxt_State = DELAY;
						end
			DELAY	:	Nxt_State = IDLE;
		endcase
	end
	
	// always_latch
	// begin
		// if (load)
			// Add_Reg <= {A, AD};	
	// end
	
	// always_ff @(posedge CLK)
	// begin
		// RegArray[Add_Reg] = Wrenb ? AD : 'z;
	// end
	
	// assign AD = OE ? RegArray[Add_Reg] : 'z;

	
endmodule

	
	
			
	
	
							
	
	