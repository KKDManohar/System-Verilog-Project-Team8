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

logic CS1,CS2,CS3,CS4;

logic [19:0] Address;
wire logic [7:0]  Data;


//Intel8088 P(CLK, MNMX, TEST, RESET, READY, NMI, INTR, HOLD, AD, A, HLDA, IOM, WR, RD, SSO, INTA, ALE, DTR, DEN);
Intel8088Pins Bus(CLK,RESET);
Intel8088 p(Bus.Processor);

iom #(.MSB(20'h80000),.LSB(20'hFFFFF),.file("MEM1trace.txt")) m1 (Bus.IOM_interface,CS1,Address,Data);
iom #(.MSB(20'h00000),.LSB(20'h7FFFF),.file("MEM2trace.txt")) m2 (Bus.IOM_interface,CS2,Address,Data);
iom #(.MSB(16'h1C00),.LSB(16'h1DFF),.file("IOPORT2.txt")) m3 (Bus.IOM_interface,CS3,Address,Data);
iom #(.MSB(16'hFF00),.LSB(16'hFF0F),.file("IOPORT1.txt")) m4 (Bus.IOM_interface,CS4,Address,Data);

//Chip Select Logic
always_comb
	begin
		{CS1,CS2,CS3,CS4} = 4'b0000;
		if(~Bus.IOM && Address[19]) 
			CS1 = 1'b1;
		else if (~Bus.IOM && ~Address[19]) 
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
