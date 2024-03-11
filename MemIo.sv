module GenericIOM(CLK,CS,ALE,RESET,RD,WR,Address,data);
	
	
	parameter IOM = 0;
	parameter Addlines = 20;
	input logic ALE,CLK,RD,WR,CS,RESET;
	input logic [19:0] Address;
	inout logic [7:0] data;
	
	logic [19:0] Add_Reg;
	logic [7:0] Reg_Array [0:2**Addlines-1];
	logic [7:0] Date_reg;
	logic load,OE,Wrenb;
	
	typedef enum logic [4:0] {
	
		IDLE =   5'b00001,
		ADDLOAD =5'b00010,
		READ =   5'b00100,
		WRITE =  5'b01000,
		DELAY =  5'b10000
	
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
		unique case(Cur_State)
			IDLE	:	if(CS && ALE)
							Nxt_State = ADDLOAD;
						else
							Nxt_State = IDLE;
						
			ADDLOAD	:	if(~RD)
							Nxt_State = READ;
						else if(~WR)
							Nxt_State = WRITE;
						else
							Nxt_State = ADDLOAD;
			READ	:	if(RD)
							Nxt_State = DELAY;
			WRITE	:	if(WR)
							Nxt_State = DELAY;
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
	
	always @(posedge CLK)
	begin
	if(Wrenb)
		Reg_Array[Add_Reg] = data ;
	end
	
	assign data = OE ? Reg_Array[Add_Reg] : 'z;
	
	
	initial
	begin
		$readmemh("Memory.txt",Reg_Array);
	end

endmodule