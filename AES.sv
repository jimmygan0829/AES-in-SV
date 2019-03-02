//
///************************************************************************
//AES Decryption Core Logic
//
//Dong Kai Wang, Fall 2017
//
//For use with ECE 385 Experiment 9
//University of Illinois ECE Department
//************************************************************************/




module AES(
	input logic CLK,
	input logic RESET,
	input logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC,
	output logic test
	);

	logic LOAD_RG;
	logic [1:0] MSG_MUX;
	logic [1:0] INV_MUX;
	logic [31:0] single_inv_in , single_inv_out ;
	logic [127:0] r_key, msg_in, msg_out, add_roundkey_out, inv_col_out, inv_shift_out, inv_sub_out;
	logic [1407:0] Full_Roundkey;
	


	state_machine FSM(.*);

	InvShiftRows Invshiftrows(.data_in(msg_out),  //*******
							  .data_out(inv_shift_out)); 

	KeyExpansion expand_that( .clk(CLK), 
							  .Cipherkey(AES_KEY), 
							  .KeySchedule(Full_Roundkey));

	addroundkey addroundkey0( .msg(msg_out), 	//******
							  .key(r_key) , .* );   //*****

//	InvMixColumns mix_that_powder(.in(single_inv_in), 
//								  .out(single_inv_out));

//	mux_32 mah_dawg(.s00(msg_out[31:0]) , .s01(msg_out[63:32]), .s10(msg_out[95:64]), 
//		.s11(msg_out[127:96]), .sel(INV_MUX), .dout(single_inv_in) );

//decoder happy_together(.clk(CLK), .din(single_inv_out) , 
//								.sel(INV_MUX), 
//								.dout0(inv_col_out[31:0]), 
//								.dout1(inv_col_out[63:32]),
//								.dout2(inv_col_out[95:64]), 
//								.dout3(inv_col_out[127:96])
//
//		);


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



	mux_128 mah_luv(.s00(add_roundkey_out), .s01(inv_shift_out) , .s10(inv_col_out) , .s11(inv_sub_out) , .sel(MSG_MUX),
					.dout(msg_in)

		);

	
	

	assign AES_MSG_DEC = msg_out;

endmodule
