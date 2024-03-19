module top;

bit CLK = '0;
bit RESET ='0;
initial
	begin

		Bus.MNMX = '1;
		Bus.TEST = '1;
		Bus. READY = '1;
 		Bus.NMI = '0;
 		Bus.INTR = '0;
 		Bus.HOLD = '0;
	end

/*wire logic [7:0] AD;
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
*/

logic CS1,CS2,CS3,CS4;

logic [19:0] Address;
wire logic [7:0]  Data;


//Intel8088 P(CLK, MNMX, TEST, RESET, READY, NMI, INTR, HOLD, AD, A, HLDA, IOM, WR, RD, SSO, INTA, ALE, DTR, DEN);
Intel8088Pins Bus(CLK,RESET);
Intel8088 p(Bus.Processor);
//iom #(.IOM(0)) m1 (CLK,RESET,ALE,CS1,RD,WR,Address,Data);
iom #(.IOM(0)) m1 (Bus.IOM_interface,CS1,Address,Data);
iom #(.IOM(0)) m2 (Bus.IOM_interface,CS2,Address,Data);
iom #(.IOM(1)) m3 (Bus.IOM_interface,CS3,Address,Data);
iom #(.IOM(1)) m4 (Bus.IOM_interface,CS4,Address,Data);
//iom #(.IOM(0)) m2 (CLK,RESET,ALE,CS2,RD,WR,Address,Data);
//iom #(.IOM(1)) m3 (CLK,RESET,ALE,CS3,RD,WR,Address,Data);
//iom #(.IOM(1)) m4 (CLK,RESET,ALE,CS4,RD,WR,Address,Data);

always_comb
	begin
		{CS1,CS2,CS3,CS4} = 4'b0000;
		if(~Bus.IOM && ~Address[19]) 
			CS1 = 1'b1;
		else if (~Bus.IOM && Address[19]) 
			CS2 = 1'b1;
		else if(Bus.IOM && Address[15:9] == 7'hE)
			CS3 = 1'b1;

		else if(Bus.IOM && Address[15:4] == 12'hFF0)
			CS4 = 1'b1;

	end

// 8282 Latch to latch bus address
always_latch
begin
if (Bus.ALE)
	Address <= {Bus.A, Bus.AD};
end

// 8286 transceiver
assign Data =  (Bus.DTR & ~Bus.DEN) ? Bus.AD   : 'z;
assign Bus.AD   = (~Bus.DTR & ~Bus.DEN) ? Data : 'z;


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
