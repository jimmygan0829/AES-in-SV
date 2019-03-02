module reg_128(
	input logic CLK, RESET, load,
	input logic [127:0] din,msg,
	output logic [127:0] dout
	);

always_ff @ (posedge CLK)
begin
	if(RESET)
		dout<=128'h0;
	else if(load)
		dout<=din;
	else if(!load)
		dout<=msg;
		
end

endmodule