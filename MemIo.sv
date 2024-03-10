module GenericIOM(CLK,CS1,CS2,CS3,CS4,load,OE,Wrenb,A,AD);


	parameter IOM = 0;
	parameter Addlines = 20;
	// parameter A_L = 20'hFF00;
	// parameter A_U = 20'hFF0F;
	// parameter B_L = 20'h1C00;
	// parameter B_U = 20'h1DFF;

	input logic load,OE,Wrenb,CLK;
	input logic [19:8] A;
	inout logic [7:0] AD;
	input logic CS1,CS2,CS3,CS4;
	
	logic [19:0] Add_Reg;
	logic [7:0] Reg_Array [2**Addlines-1 : 0];
	logic [7:0] Date_reg;
	
	always_latch
	begin
		if (load)
		begin
			if(!IOM)
				Add_Reg <= {A,AD};
			else if(IOM)
				Add_Reg <= {A[15:8],AD};
		end
	end
	
	always_ff @(posedge CLK)
	begin
		if(!IOM)
		begin
			if(CS1)
			begin
				Date_reg = OE ? Reg_Array[Add_Reg] : 'z;
				Reg_Array[Add_Reg] = Wrenb ? AD : 'z;
			end
			else if(CS2)
			begin
				Date_reg = OE ? Reg_Array[Add_Reg] : 'z;
				Reg_Array[Add_Reg] = Wrenb ? AD : 'z;
			end
			else
			begin
				Date_reg = 'z;
				Reg_Array[Add_Reg] = 'z;
			end
		end
		else if(IOM)
		begin
			if(CS3)
			begin
				Date_reg = OE ? Reg_Array[Add_Reg] : 'z;
				Reg_Array[Add_Reg] = Wrenb ? AD : 'z;
			end
			else if(CS4)
			begin
				Date_reg = OE ? Reg_Array[Add_Reg] : 'z;
				Reg_Array[Add_Reg] = Wrenb ? AD : 'z;
			end
			else
			begin
				Date_reg = 'z;
				Reg_Array[Add_Reg] = 'z;
			end
		end
	end
				
		
	
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
	
	assign AD = Date_reg;

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
