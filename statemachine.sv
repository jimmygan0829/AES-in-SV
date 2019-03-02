module state_machine(
	input logic CLK,RESET,AES_START,
	output logic AES_DONE,
	input logic [1407:0] Full_Roundkey,
	output logic [1:0] MSG_MUX,INV_MUX,
	output logic LOAD_RG,
	output logic [127:0] r_key
	//output logic testing
);

enum logic [7:0]{
	    
		start, 
		buffer,
		halt,
		
		Addroundkey0,
		Addroundkey1,
		Addroundkey2,
		Addroundkey3,
		Addroundkey4,
		Addroundkey5,
		Addroundkey6,
		Addroundkey7,
		Addroundkey8,
		Addroundkey9,
		Addroundkey10,

		Inverseshift1,
		Inverseshift2,
		Inverseshift3,
		Inverseshift4,
		Inverseshift5,
		Inverseshift6,
		Inverseshift7,
		Inverseshift8,
		Inverseshift9,
		Inverseshift10,

		InverseSub1,
		InverseSub2,
		InverseSub3,
		InverseSub4,
		InverseSub5,
		InverseSub6,
		InverseSub7,
		InverseSub8,
		InverseSub9,
		InverseSub10,
		
		InversemixCol11,
		
		
		InversemixCol21,
		
		
		InversemixCol31,
		
		
		InversemixCol41,
		
		
		InversemixCol51,
	
		
		InversemixCol61,
	
		
		InversemixCol71,
		
		
		InversemixCol81,
		
		
		InversemixCol91
		
		

			} state, next_state;

	always_ff @(posedge CLK ) 
	begin 
		if(RESET) 	begin
			 state<= start;
	 end 
	 	else begin
			state <= next_state;
		end
	end

	always_comb
begin

		next_state = state;
		case (state)
			start :
			//next_state = halt;
		begin
			if(AES_START)
			next_state = buffer;
			
			else 
			next_state = start;
		end 

		buffer:
		next_state = Addroundkey0;
		Addroundkey0:
		
		next_state = Inverseshift1; //*******************
		
		Inverseshift1:
		
		next_state = InverseSub1;
		InverseSub1:
		next_state = Addroundkey1;
		Addroundkey1:
		next_state = InversemixCol11;

		InversemixCol11:
		next_state = Inverseshift2;

		Inverseshift2:
		next_state = InverseSub2;
		InverseSub2:
		next_state = Addroundkey2;
		Addroundkey2:
		next_state = InversemixCol21;

		InversemixCol21:
		next_state = Inverseshift3;
		Inverseshift3:
		next_state = InverseSub3;
		InverseSub3:
		next_state = Addroundkey3;
		Addroundkey3:
		next_state = InversemixCol31;

		InversemixCol31:
		next_state = Inverseshift4;
		
		Inverseshift4:
		next_state = InverseSub4;
		InverseSub4:
		next_state = Addroundkey4;
		Addroundkey4:
		next_state = InversemixCol41;

		InversemixCol41:
		next_state = Inverseshift5;
		Inverseshift5:
		next_state = InverseSub5;
		InverseSub5:
		next_state = Addroundkey5;
		Addroundkey5:
		next_state = InversemixCol51;
		InversemixCol51:
		next_state = Inverseshift6;

		Inverseshift6:
		next_state = InverseSub6;
		InverseSub6:
		next_state = Addroundkey6;
		Addroundkey6:
		next_state = InversemixCol61;
		InversemixCol61:
		next_state = Inverseshift7;

		Inverseshift7:
		next_state = InverseSub7;
		InverseSub7:
		next_state = Addroundkey7;
		Addroundkey7:
		next_state = InversemixCol71;
		InversemixCol71:
		next_state = Inverseshift8;

		Inverseshift8:
		next_state = InverseSub8;
		InverseSub8:
		next_state = Addroundkey8;
		Addroundkey8:
		next_state = InversemixCol81;
		InversemixCol81:
		next_state = Inverseshift9;

		Inverseshift9:
		next_state = InverseSub9;
		InverseSub9:
		next_state = Addroundkey9;
		Addroundkey9:
		next_state = InversemixCol91;
		InversemixCol91:
		next_state = Inverseshift10; //****
		
		
		Inverseshift10:
		next_state = InverseSub10;
		InverseSub10:
		next_state = Addroundkey10;
		Addroundkey10:
		next_state = halt;

		halt:
		if(AES_START)
			next_state = halt;
		else
			next_state = start;


	endcase 

end



always_comb
begin

	case(state)
	
	start:
	begin
	r_key = 128'b0;
	MSG_MUX = 2'b00; 
	INV_MUX = 2'b00; 
	LOAD_RG = 1'b1;
	AES_DONE = 1'b0;
	//testing = 1'b0;
	end
	
	buffer:
	begin
	r_key = 128'b0;
	MSG_MUX = 2'b00;
	INV_MUX = 2'b00; 
	LOAD_RG = 1'b0;
	AES_DONE = 1'b0;
//	testing = 1'b0;
	end

	halt:
	begin
	r_key = 128'b0;	
	MSG_MUX = 2'b00; 
	INV_MUX = 2'b00; 
	LOAD_RG = 1'b1; 
	AES_DONE = 1'b1;
	//testing = 1'b1;
	
	end


	Addroundkey0:
	begin
		MSG_MUX = 2'b00;
		LOAD_RG = 1'b1;
		r_key = Full_Roundkey[127:0];
		INV_MUX = 2'b00;
		AES_DONE = 1'b0;
	//	testing = 1'b1;
	end

	Addroundkey1:
	begin
		MSG_MUX = 2'b00;
		LOAD_RG = 1'b1;
		r_key = Full_Roundkey[255:128];	
		INV_MUX = 2'b00;
		AES_DONE = 1'b0;
	//	testing = 1'b0;
	end

	Addroundkey2:
	begin
		MSG_MUX = 2'b00;
		LOAD_RG = 1'b1;
		r_key = Full_Roundkey[383:256];	
		INV_MUX = 2'b00;
		AES_DONE = 1'b0;
	//	testing = 1'b0;
	end

	Addroundkey3:
	begin
		MSG_MUX = 2'b00;
		LOAD_RG = 1'b1;
		r_key = Full_Roundkey[511:384];	
		INV_MUX = 2'b00;
		AES_DONE = 1'b0;
	//	testing = 1'b0;
	end

	Addroundkey4:
	begin
		MSG_MUX = 2'b00;
		LOAD_RG = 1'b1;
		r_key = Full_Roundkey[639:512];
	INV_MUX = 2'b00;
		AES_DONE = 1'b0;	
	//	testing = 1'b0;
	end

	Addroundkey5:
	begin
		MSG_MUX = 2'b00;
		LOAD_RG = 1'b1;
		r_key = Full_Roundkey[767:640];
	INV_MUX = 2'b00;
		AES_DONE = 1'b0;	
	//	testing = 1'b0;
	end

	Addroundkey6:
	begin
		MSG_MUX = 2'b00;
		LOAD_RG = 1'b1;
		r_key = Full_Roundkey[895:768];
	INV_MUX = 2'b00;
		AES_DONE = 1'b0;	
	//	testing = 1'b0;
	end

		Addroundkey7:
	begin
		MSG_MUX = 2'b00;
		LOAD_RG = 1'b1;
		r_key = Full_Roundkey[1023:896];	
		INV_MUX = 2'b00;
		AES_DONE = 1'b0;
	//	testing = 1'b0;
	end
			Addroundkey8:
	begin
		MSG_MUX = 2'b00;
		LOAD_RG = 1'b1;
		r_key = Full_Roundkey[1151:1024];	
		INV_MUX = 2'b00;
		AES_DONE = 1'b0;
	//	testing = 1'b0;
	end

		Addroundkey9:
	begin
		MSG_MUX = 2'b00;
		LOAD_RG = 1'b1;
		r_key = Full_Roundkey[1279:1152];
	INV_MUX = 2'b00;
		AES_DONE = 1'b0;
	//testing = 1'b0;	
	end

			Addroundkey10:
	begin
		MSG_MUX = 2'b00;
		LOAD_RG = 1'b1;
		r_key = Full_Roundkey[1407:1280];
	INV_MUX = 2'b00;
		AES_DONE = 1'b0;	
	//	testing = 1'b0;
	end


		InverseSub1:
			begin
			MSG_MUX = 2'b11;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
	//		testing = 1'b0;
			end
		InverseSub2:
			begin
			MSG_MUX = 2'b11;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
	//		testing = 1'b0;
			end
		InverseSub3:
			begin
			MSG_MUX = 2'b11;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
	//		testing = 1'b0;
			AES_DONE = 1'b0;
			end
		InverseSub4:
			begin
			MSG_MUX = 2'b11;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
	//		testing = 1'b0;
			end
		InverseSub5:
			begin
			MSG_MUX = 2'b11;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
	//		testing =1'b0;
			end
		InverseSub6:
			begin
			MSG_MUX = 2'b11;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
	
//	testing = 1'b0;
			end
		InverseSub7:
			begin
			MSG_MUX = 2'b11;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
	//		testing = 1'b0;
			end
		InverseSub8:
			begin
			MSG_MUX = 2'b11;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
	//		testing =1'b0;
			end
		InverseSub9:
			begin
			MSG_MUX = 2'b11;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
	//		testing = 1'b0;
			end
		InverseSub10:
			begin
			MSG_MUX = 2'b11;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
	//		testing = 1'b0;
			end





		Inverseshift1:
		begin
			MSG_MUX = 2'b01;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
	//		testing = 1'b0;
			end
		Inverseshift2:
		begin
			MSG_MUX = 2'b01;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
	//		testing = 1'b0;
			end
		Inverseshift3:
		begin
			MSG_MUX = 2'b01;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
	//		testing = 1'b0;
			end
		Inverseshift4:
		begin
			MSG_MUX = 2'b01;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
	//		testing = 1'b0;
			end
		Inverseshift5:
		begin
			MSG_MUX = 2'b01;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
	//		testing = 1'b0;
			end
		Inverseshift6:
		begin
			MSG_MUX = 2'b01;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
	//		testing = 1'b0;
			end
		Inverseshift7:
		begin
			MSG_MUX = 2'b01;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
		//	testing = 1'b0;
			end
		Inverseshift8:
		begin
			MSG_MUX = 2'b01;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
		//	testing = 1'b0;
			end
		Inverseshift9:
		begin
			MSG_MUX = 2'b01;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
		//	testing = 1'b0;
			end
		Inverseshift10:
			begin
			MSG_MUX = 2'b01;
			LOAD_RG = 1'b1;
			r_key = 128'b1;
			INV_MUX = 2'b00;
			AES_DONE = 1'b0;
		//	testing = 1'b0;
			end



		InversemixCol11,
		InversemixCol21,
		InversemixCol31,
		InversemixCol41,
		InversemixCol51,
		InversemixCol61,
		InversemixCol71,
		InversemixCol81,
		InversemixCol91:
		begin
			MSG_MUX = 2'b10;
			LOAD_RG = 1'b1;
			INV_MUX = 2'b00; //[31:0]
			r_key = 128'b1;
			
			AES_DONE = 1'b0;
		//	testing = 1'b0;
		end
	
//
//
//
//
//		InversemixCol12,
//		InversemixCol22,
//		InversemixCol32,
//		InversemixCol42,
//		InversemixCol52,
//		InversemixCol62,
//		InversemixCol72,
//		InversemixCol82,
//		InversemixCol92:
//		begin
//			MSG_MUX = 2'b10;
//			LOAD_RG = 1'b1;
//			INV_MUX = 2'b01; //[63:32]
//			r_key = 128'b1;
//			
//			AES_DONE = 1'b0;
//		//	testing = 1'b0;
//		end
//
//		InversemixCol13,
//		InversemixCol23,
//		InversemixCol33,
//		InversemixCol43,
//		InversemixCol53,
//		InversemixCol63,
//		InversemixCol73,
//		InversemixCol83,
//		InversemixCol93:
//		begin
//			MSG_MUX = 2'b10;
//			LOAD_RG = 1'b1;
//			INV_MUX = 2'b10; //[95:64]
//			r_key = 128'b1;
//			
//			AES_DONE = 1'b0;
//		//	testing = 1'b0;
//		end
//
//		InversemixCol14,
//		InversemixCol24,
//		InversemixCol34,
//		InversemixCol44,
//		InversemixCol54,
//		InversemixCol64,
//		InversemixCol74,
//		InversemixCol84,
//		InversemixCol94:
//		begin
//			MSG_MUX = 2'b10;
//			LOAD_RG = 1'b1;
//			INV_MUX = 2'b11; //[127:96]
//			r_key = 128'b1;
//			
//			AES_DONE = 1'b0;
//		//	testing = 1'b0;
//		end

//		default:
//		begin
//			MSG_MUX = 2'b00;
//			INV_MUX = 1'b0;
//			LOAD_RG = 1'b0;
//			r_key = 128'b0;
//			AES_DONE = 1'b0;
//			testing = 1'b0;
//		end
	endcase 

end


endmodule

 