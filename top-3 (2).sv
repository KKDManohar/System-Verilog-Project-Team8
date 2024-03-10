module top;

bit CLK = '0;
bit MNMX = '1;
bit TEST = '1;
bit RESET = '0;
bit READY = '1;
bit NMI = '0;
bit INTR = '0;
bit HOLD = '0;

wire logic [7:0] AD;
logic [19:8] A;
logic HLDA;
logic IOM;
logic WR;
logic RD;
logic SSO;
logic INTA;
logic ALE;
logic DTR;
logic DEN;


logic [19:0] Address;
wire [7:0]  Data;

logic CS1,CS2,CS3,CS4,CS;
logic load,OE,Wrenb;


Intel8088 P(CLK, MNMX, TEST, RESET, READY, NMI, INTR, HOLD, AD, A, HLDA, IOM, WR, RD, SSO, INTA, ALE, DTR, DEN);
FSM Y(ALE,CLK,RESET,RD,WR,CS,load,OE,Wrenb);
GenericIOM #(.IOM(0)) Z(CLK,CS1,CS2,CS3,CS4,load,OE,Wrenb,A,AD);
GenericIOM #(.IOM(1)) Z1(CLK,CS1,CS2,CS3,CS4,load,OE,Wrenb,A,AD);


// 8282 Latch to latch bus address
always_latch
begin
if (ALE)
	Address <= {A, AD};
end

//2x4 Decoder
always_comb
	begin
		if(ALE && !IOM && !Address[19])
			{CS1,CS2,CS3,CS4} = 4'b1000;
		else if(ALE && !IOM && Address[19])
			{CS1,CS2,CS3,CS4} = 4'b0100;
		else if(ALE && IOM && Address[15:4] == 12'hff0)
			{CS1,CS2,CS3,CS4} = 4'b0010;
		else if(ALE && IOM && Address[15:9] == 7'h0e)
			{CS1,CS2,CS3,CS4} = 4'b0001;
		else
			{CS1,CS2,CS3,CS4} = 4'b0000;
	end
	
assign CS = CS1 || CS2 || CS3 || CS4;

// 8286 transceiver
assign Data =  (DTR & ~DEN) ? AD   : 'z;//write
assign AD   = (~DTR & ~DEN) ? Data : 'z;//read


always #50 CLK = ~CLK;

initial
begin
$dumpfile("dump.vcd"); $dumpvars;

repeat (2) @(posedge CLK);
RESET = '1;
repeat (5) @(posedge CLK);
RESET = '0;

repeat(10000) @(posedge CLK);
$finish();
end

endmodule
