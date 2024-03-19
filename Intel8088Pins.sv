interface Intel8088Pins(input logic CLK,RESET);
logic MNMX, TEST, READY, NMI, INTR, HOLD, HLDA, IOM, WR, RD, SSO, INTA, ALE, DTR, DEN;
tri [7:0]AD;
tri [19:8]A;

/*modport intel_interface(output HLDA,A,IOM,WR,RD,SSO,INTA,ALE,DTR,DEN, 
		      inout AD,
		      input CLK,RESET,HOLD,READY,INTR,NMI,MNMX,TEST);*/
modport Processor(input CLK,MNMX,TEST,RESET,READY,NMI,INTR,HOLD, 
			inout AD,
			output A, HLDA, IOM, WR, RD, SSO, INTA, ALE, DTR, DEN);
modport IOM_interface(input CLK,RESET,WR,RD,ALE);
endinterface
