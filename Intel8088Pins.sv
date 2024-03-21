interface Intel8088Pins(input logic CLK,RESET);

		logic MNMX;
		logic TEST;

		logic READY;
		logic NMI;
		logic INTR;
		logic HOLD;

		logic HLDA;
		tri [7:0] AD;
		tri [19:8] A;

		logic IOM;
		logic WR;
		logic RD;
		logic SSO;
		logic INTA;
		logic ALE;
		logic DTR;
		logic DEN;


		modport Processor(input CLK,MNMX,TEST,RESET,READY,NMI,INTR,HOLD, 
						  inout AD,
						  output A, HLDA, IOM, WR, RD, SSO, INTA, ALE, DTR, DEN);

		modport IOM_interface(input CLK,RESET,WR,RD,ALE);
		
endinterface
