module iom(Intel8088Pins.IOM_interface pins,input logic CS,input logic [19:0] Address,inout logic [7:0] Data);

parameter MSB = 20'hFFFFF;
parameter LSB = 20'h00000;
parameter file = "MEM1trace.txt";


logic [7:0] DATA_REG;
logic [19:0] ADD_REG;
logic LOAD,OE,WRENB;
logic [7:0] Mem [MSB:LSB];


typedef enum logic [4:0] {
	
		IDLE =   5'b00001,
		ADD_LOAD =5'b00010,
		READ =   5'b00100,
		WRITE =  5'b01000,
		DELAY =  5'b10000
	
	} State;
	
	State CURRENT_STATE , NEXT_STATE;


always_ff @ (posedge pins.CLK)
	begin
		if(pins.RESET)
			CURRENT_STATE <= IDLE;
		else
			CURRENT_STATE <= NEXT_STATE;
	end

always_comb
	begin
		{LOAD,OE,WRENB} = 3'b000;
		unique0 case(CURRENT_STATE)
		IDLE : begin
				LOAD = 1'b0;
				OE = 1'b0;
				WRENB = 1'b0;
			end

		ADD_LOAD : begin
				LOAD = 1'b1;
				end
		READ : begin
				OE = 1'b1;
			end

		WRITE : begin
				WRENB = 1'b1;
			end

		DELAY : begin
				LOAD = 1'b0;
				OE = 1'b0;
				WRENB = 1'b0;
			end
		endcase
	end

always_comb
	begin
		NEXT_STATE = CURRENT_STATE;
		unique0 case(CURRENT_STATE)
			IDLE : begin
				if(CS && pins.ALE)
					NEXT_STATE = ADD_LOAD;
				else
					NEXT_STATE = IDLE;
				end
			ADD_LOAD : begin
				if(~pins.RD)
					NEXT_STATE = READ;
				else if(~pins.WR)
					NEXT_STATE = WRITE;
				end
			READ : begin

					NEXT_STATE = DELAY;
				end

			WRITE : begin
	
					NEXT_STATE = DELAY;
				end

			DELAY : begin
					NEXT_STATE = IDLE;
				end

		endcase
	end

always_latch
	begin
	if(LOAD)
		ADD_REG <= {Address};
	end
	

always @ (posedge pins.CLK)
	begin
	if(WRENB)
		Mem[ADD_REG] <= Data;
	end

assign Data = OE ? Mem[ADD_REG] : 'z;

initial 
	begin
	$readmemh(file, Mem , MSB , LSB);
	end


endmodule
