///************************************************************************
//Avalon-MM Interface for AES Decryption IP Core
//
//Dong Kai Wang, Fall 2017
//
//For use with ECE 385 Experiment 9
//University of Illinois ECE Department
//
//Register Map:
//
// 0-3 : 4x 32bit AES Key
// 4-7 : 4x 32bit AES Encrypted Message
// 8-11: 4x 32bit AES Decrypted Message
//   12: Not Used
//	13: Not Used
//   14: 32bit Start Register
//   15: 32bit Done Register
//
//************************************************************************/
//


module avalon_aes_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [3:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [31:0] EXPORT_DATA		// Exported Conduit Signal to LEDs
	);
	
	

	logic shit = 1'b1;
	
	
	
	logic [31:0]temp[16];
	logic LOAD_RG;
	logic [1:0] MSG_MUX;
	logic [1:0] INV_MUX;
//	logic [31:0] single_inv_in , single_inv_out ;
	logic [127:0] r_key, msg_in, msg_out,AES_KEY,AES_MSG_ENC;
	logic [127:0] add_roundkey_out, inv_col_out, inv_shift_out, inv_sub_out;
	logic [1407:0] Full_Roundkey;
	logic done;
	logic [127:0] dec;
	
	
	
	
	always_ff @ (posedge CLK)
	begin
	if(RESET)
		begin
		temp[0]<=32'h00000000;
		temp[1]<=32'h00000000;
		temp[2]<=32'h00000000;
		temp[3]<=32'h00000000;
		temp[4]<=32'h00000000;
		temp[5]<=32'h00000000;
		temp[6]<=32'h00000000;
		temp[7]<=32'h00000000;
		temp[8]<=32'h00000000;
		temp[9]<=32'h00000000;
		temp[10]<=32'h00000000;
		temp[11]<=32'h00000000;
		temp[12]<=32'h00000000;
		temp[13]<=32'h00000000;
		temp[14]<=32'h00000000;
		temp[15]<=32'h00000000;
		end
		
		
	else if(AVL_CS && AVL_WRITE)
			begin
			if(AVL_BYTE_EN[0])
			temp[AVL_ADDR][7:0] <= AVL_WRITEDATA [7:0];
			if (AVL_BYTE_EN[1])
			temp[AVL_ADDR][15:8] <= AVL_WRITEDATA [15:8];
			if (AVL_BYTE_EN[2])
			temp[AVL_ADDR][23:16] <= AVL_WRITEDATA [23:16];
			if (AVL_BYTE_EN[3])
			temp[AVL_ADDR][31:24] <= AVL_WRITEDATA [31:24];	
			end
	else if(done)
		begin 
		temp[8][31:0] <= dec[127:96];
		temp[9][31:0] <= dec[95:64];
		temp[10][31:0] <= dec[63:32];
		temp[11][31:0] <= dec[31:0];
		temp[15][0] <=done;
		end
//	else
//		begin
//		temp[8][31] <= 1'b1;
//		temp[8][30:0] <= dec[126:96];
//		temp[9][31:0] <= dec[95:64];
//		temp[10][31:0] <= dec[63:32];
//		temp[11][31:0] <= dec[31:0];
//		temp[15][0] <=done;
//		end
			end
			
 


logic test;



assign AES_KEY = {temp[0][31:0],temp[1][31:0],temp[2][31:0],temp[3][31:0]};
assign AES_MSG_ENC = {temp[4][31:0],temp[5][31:0],temp[6][31:0],temp[7][31:0]};


	state_machine FSM
	(
	.CLK(CLK),
	.RESET(RESET),
	.AES_START(temp[14][0]),
	.AES_DONE(done),
	.MSG_MUX(MSG_MUX),
	.INV_MUX(INV_MUX),
	.LOAD_RG(LOAD_RG),
	.r_key(r_key),
	.Full_Roundkey(Full_Roundkey)
	);
	//.testing(test));

	InvShiftRows Invshiftrows(.data_in(msg_out),  //*******
							  .data_out(inv_shift_out)); 

	KeyExpansion expand_that( .clk(CLK), 
							  .Cipherkey(AES_KEY), 
							  .KeySchedule(Full_Roundkey));

	addroundkey addroundkey0( .msg(msg_out), 	//******
							  .key(r_key) , 
								.add_roundkey_out(add_roundkey_out));   //*****

//	InvMixColumns mix_that_powder(.in(single_inv_in), 
//								  .out(single_inv_out));

//	mux_32 mah_dawg(.s00(msg_out[31:0]) , .s01(msg_out[63:32]), 
//	.s10(msg_out[95:64]), 
//	.s11(msg_out[127:96]), .sel(INV_MUX), .dout(single_inv_in) );

//	decoder happy_together(.clk(CLK), .din(single_inv_out) , 
//								.sel(INV_MUX), 
//								.dout0(inv_col_out[31:0]), 
//								.dout1(inv_col_out[63:32]),
//								.dout2(inv_col_out[95:64]), 
//								.dout3(inv_col_out[127:96])
//
//		);

InvMixCol128 dude_damn(
							.InvMix1(msg_out[31:0]), .InvMix_out1(inv_col_out[31:0]),
							.InvMix2(msg_out[63:32]), .InvMix_out2(inv_col_out[63:32]),
							.InvMix3(msg_out[95:64]), .InvMix_out3(inv_col_out[95:64]),
							.InvMix4(msg_out[127:96]), .InvMix_out4(inv_col_out[127:96])
);

	InvSub128 mah_lawd( .clk(CLK), 
			   .SubIn1(msg_out[7:0]), 
			   .SubIn2(msg_out[15:8]), 	
			   .SubIn3(msg_out[23:16]), 
			   .SubIn4(msg_out[31:24]), 
			   .SubIn5(msg_out[39:32]), 
			   .SubIn6(msg_out[47:40]), 
			   .SubIn7(msg_out[55:48]), 
			   .SubIn8(msg_out[63:56]), 
			   .SubIn9(msg_out[71:64]), 
			   .SubIn10(msg_out[79:72]), 	
			   .SubIn11(msg_out[87:80]), 
			   .SubIn12(msg_out[95:88]), 
			   .SubIn13(msg_out[103:96]), 
			   .SubIn14(msg_out[111:104]), 
			   .SubIn15(msg_out[119:112]), 
			   .SubIn16(msg_out[127:120]), 

			   .SubOut1(inv_sub_out[7:0]), 
			   .SubOut2(inv_sub_out[15:8]), 	
			   .SubOut3(inv_sub_out[23:16]), 
			   .SubOut4(inv_sub_out[31:24]), 
			   .SubOut5(inv_sub_out[39:32]), 
			   .SubOut6(inv_sub_out[47:40]), 
			   .SubOut7(inv_sub_out[55:48]), 
			   .SubOut8(inv_sub_out[63:56]), 
			   .SubOut9(inv_sub_out[71:64]), 
			   .SubOut10(inv_sub_out[79:72]), 	
			   .SubOut11(inv_sub_out[87:80]), 
			   .SubOut12(inv_sub_out[95:88]), 
			   .SubOut13(inv_sub_out[103:96]), 
			   .SubOut14(inv_sub_out[111:104]), 
			   .SubOut15(inv_sub_out[119:112]), 
			   .SubOut16(inv_sub_out[127:120]) 

		);
	reg_128 I_just_wanna_get_a_decent_job(
		.*, .load(LOAD_RG), .din(msg_in), .msg(AES_MSG_ENC), .dout(msg_out)

		);



	mux_128 mah_luv(.s00(add_roundkey_out), .s01(inv_shift_out) , 
					.s10(inv_col_out) , .s11(inv_sub_out) , 
					.sel(MSG_MUX),
					.dout(msg_in)

		);

	
	assign dec = msg_out;





assign AVL_READDATA = (AVL_CS && AVL_READ)?temp[AVL_ADDR]:32'h00000000;

assign EXPORT_DATA = {temp[0][31:16],temp[3][15:0]}	; //output for hex display




endmodule




