module GenericIOM(ALE,Clock,Reset,A,AD,RD,WR,CS);
	
	parameter IOM = 0;
	parameter AddLines = 20;
	parameter IOLines = 16;
	input logic ALE,Clock,RD,WR,CS,Reset;
	inout logic [7:0] AD;
	input logic [19:8] A;
	
	logic [19:0] Add_Reg;
	logic [7:0] RegArray [2^AddLines-1 : 0];
	//logic [7:0] IOReg [2^IOLines-1 : 0];
	logic load,OE,Wrenb;
	
	typedef enum logic [4:0] {
	
		IDLE = 5'b00001,
		ADDLOAD =5'b00010,
		READ = 5'b00100,
		WRITE = 5'b01000,
		DELAY = 5'b10000
	
	} State;
	
	State Cur_State , Nxt_State;
	
	always_ff @(posedge Clock)
	begin
		if(Reset)
			Cur_State <= IDLE;
		else
			Cur_State <= Nxt_State;
	end
	
	always_comb
	begin
		{load,OE,Wrenb} = 3'b000;
		case(Cur_State)
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
		case(Cur_State)
			IDLE	:	begin
							if(ALE)
								Nxt_State = ADDLOAD;
							else
								Nxt_State = IDLE;
						end
						
			ADDLOAD	:	begin
							if(RD)
								Nxt_State = READ;
							else if(WR)
								Nxt_State = WRITE;
							else
								Nxt_State = ADDLOAD;
						end
			READ	:	Nxt_State = DELAY;
			WRITE	:	Nxt_State = DELAY;
			DELAY	:	Nxt_State = IDLE;
		endcase
	end
	
	always_latch
	begin
		if (load)
			Add_Reg <= {A, AD};	
	end
	
	// always_comb
	// begin
		// if(IOM)
		// begin
			// AD = OE ? IOReg[Add_Reg] : 'z;
			// IOReg[Add_Reg] = Wrenb ? AD : 'z;
		// end
		// else
		// begin
			// AD = OE ? RegArray[Add_Reg] : 'z;
			// RegArray[Add_Reg] = Wrenb ? AD : 'z;
		// end
	// end
	
	always_ff @(posedge Clock)
	begin
		RegArray[Add_Reg] = Wrenb ? AD : 'z;
	end
	
	assign AD = OE ? RegArray[Add_Reg] : 'z;

	
endmodule

	
	
			
	
	
							
	
	