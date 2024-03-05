// Code your design here
module mpFSM(clk,reset,ALE,RD,WR,CS,A,AD);
 parameter address=20;
 input logic clk,reset;
 inout logic [7:0]AD;
 input logic [19:8]A;
 input logic RD,WR,CS,ALE;

 logic load,oe,wrenb;

 logic [19:0]addreg;
 logic [7:0]regarray[2**address-1:0];

typedef enum logic [4:0]{
	IDLE  =5'b00001,
	ADDLD =5'b00010,
	READ  =5'b00100,
	WRITE =5'b01000,
	DELAY =5'b10000
}state;

state present_state,next_state;

always_ff @(posedge clk)
  begin
	if(reset)
	  present_state<=IDLE;
    else
	  present_state<=next_state;
  end

//output logic
always_comb
  begin
   {load,oe,wrenb}=3'b000;
  	  case(present_state)
       IDLE:{load,oe,wrenb}=3'b000;
	   ADDLD:load=1;
	   READ:oe=1;
	   WRITE:wrenb=1;
       DELAY:{load,oe,wrenb}=3'b000;
	  endcase
  end


//nextstate logic
always_comb
  begin
	next_state = present_state;
    case(present_state)
     IDLE:begin
	      if(ALE)
	        next_state=ADDLD;
	      else
	        next_state=IDLE;
	      end
	 ADDLD:begin
	       if(~RD)
	         next_state=READ;
	       else if(~WR)
	         next_state=WRITE;
	       end
	 READ:begin
	      if(RD)
	        next_state=DELAY;
	      end
     WRITE:begin
	       if(WR)
	         next_state=DELAY;
	       end
     DELAY:next_state=IDLE;
   endcase
end

always_latch
  begin
    if(load)
    addreg<={A,AD};
  end

always_ff @(posedge clk)
  begin
	regarray[addreg]=wrenb?AD:'z;
  end
assign AD=oe?regarray[addreg]:'z;
endmodule



