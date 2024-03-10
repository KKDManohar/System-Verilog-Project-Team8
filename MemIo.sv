module GenericIOM(CLK,CS,ALE,RESET,RD,WR,Address,AD);
	
	
	parameter IOM = 0;
	parameter Addlines = 20;
	input logic ALE,CLK,RD,WR,CS,RESET;
	input logic [19:0] Address;
	inout logic [7:0] AD;
	
	logic [19:0] Add_Reg;
	logic [7:0] Reg_Array [2**Addlines-1 : 0];
	logic [7:0] Date_reg;
	logic load,OE,Wrenb;
	
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
	
	always_latch
	begin
		if (load)
		begin
			Add_Reg <= {Address};
		end
	end
	
	always_ff @(posedge CLK)
	begin
		Reg_Array[Add_Reg] = Wrenb ? AD : 'z;
	end
	
	assign AD = OE ? Reg_Array[Add_Reg] : 'z;
	
	
	initial
	begin
		$readmemh("Memory.txt",Reg_Array);
	end
	


	// parameter IOM = 0;
	// parameter Addlines = 20;
	// parameter A_L = 20'hFF00;
	// parameter A_U = 20'hFF0F;
	// parameter B_L = 20'h1C00;
	// parameter B_U = 20'h1DFF;

	// input logic [19:8] A;
	// inout logic [7:0] AD;
	// input logic CS;
	// input logic CLK,ALE,RESET,RD,WR;
	
	// logic [19:0] Add_Reg;
	// logic [7:0] Reg_Array [2**Addlines-1 : 0];
	// logic [7:0] Date_reg;
	// logic load,OE,Wrenb;
	
	// FSM Y(ALE,CLK,RESET,RD,WR,CS,load,OE,Wrenb);
	
	// always_latch
	// begin
		// if (load)
		// begin
			// Add_Reg <= {A,AD};
		// end
	// end
	
	// always_ff @(posedge CLK)
	// begin
		// if(!IOM)
		// begin
			// if(CS)
			// begin
				// Date_reg = OE ? Reg_Array[Add_Reg] : 'z;
				// Reg_Array[Add_Reg] = Wrenb ? AD : 'z;
			// end
			// else if(CS2)
			// begin
				// Date_reg = OE ? Reg_Array[Add_Reg] : 'z;
				// Reg_Array[Add_Reg] = Wrenb ? AD : 'z;
			// end
			// else
			// begin
				// Date_reg = 'z;
				// Reg_Array[Add_Reg] = 'z;
			// end
		// end
		// else if(IOM)
		// begin
			// if(CS)
			// begin
				// Date_reg = OE ? Reg_Array[Add_Reg] : 'z;
				// Reg_Array[Add_Reg] = Wrenb ? AD : 'z;
			// end
			// else if(CS4)
			// begin
				// Date_reg = OE ? Reg_Array[Add_Reg] : 'z;
				// Reg_Array[Add_Reg] = Wrenb ? AD : 'z;
			// end
			// else
			// begin
				// Date_reg = 'z;
				// Reg_Array[Add_Reg] = 'z;
			// end
		// end
	// end
				
		
	
	// always_ff @(posedge CLK)
	// begin
		// if(CS1 || CS2)
		// begin
			// Date_reg = OE ? Reg_Array[Add_Reg] : 'z;
			// Reg_Array[Add_Reg] = Wrenb ? AD : 'z;
		// end
		// else if(CS3)
		// begin
			// Date_reg = OE ? Reg_Array[Add_Reg[A_U : A_L]] : 'z;
			// Reg_Array[Add_Reg[A_U : A_L]] = Wrenb ? AD : 'z;	
		// end
		// else if(CS4)
		// begin
			// Date_reg = OE ? Reg_Array[Add_Reg[B_U : B_L]] : 'z;
			// Reg_Array[Add_Reg[B_U : B_L]] = Wrenb ? AD : 'z;	
		// end
		// else
		// begin
			// Date_reg = 'z;
			// Reg_Array[Add_Reg] = 'z;
		// end
	// end
	
	//assign AD = Date_reg;

endmodule
		
		
			
	
	
	// always_ff(@posedge CLK)
	// begin
		// if(!IOM)
		// begin
			// if(OE)
			// begin
				// Date_reg = CS1 ? MemArray[Add_Reg] : MemArray[Add_Reg];
			
	
	// always_ff @(posedge CLK)
	// begin
		// if(IOM)
			// MemArray[Add_Reg] = Wrenb ? AD : 'z;
		// else
			// IOArray[Add_Reg] = Wrenb ? AD : 'z;
	// end
	
	// assign AD = IOM ? (OE ? (CS ? RegArray[Add_Reg] : RegArray[Add_Reg]) : 'z) : (CS ? RegArray[Add_Reg] : RegArray[Add_Reg]) : 'z);
