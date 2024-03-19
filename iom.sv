//module iom(CLK,RESET,ALE,CS,RD,WR,Address,Data);
module iom(Intel8088Pins.IOM_interface pins,input CS,input [19:0]Address,[7:0]Data);
//input CS;
//input logic [19:0] Address;
//inout logic [7:0] Data;

logic [19:0] ADD_REG;

logic LOAD,OE,WRENB;

parameter ADD_LEN = 20;
parameter IOM = 0;

logic [7:0] IOM_REG [2**ADD_LEN-1:0];

parameter 
	IDLE = 5'b00001,
	ADD_LOAD = 5'b00010,
	READ = 5'b00100,
	WRITE = 5'b01000,
	DELAY = 5'b10000;

logic [4:0] CURRENT_STATE,NEXT_STATE;

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
		IOM_REG[ADD_REG] <= Data;
	end

assign Data = OE ? IOM_REG[ADD_REG] : 'z;

initial 
	begin
		$readmemh("Memory.txt",IOM_REG);
	end


endmodule
