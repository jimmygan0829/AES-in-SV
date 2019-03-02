module decoder(
	input logic clk,
	input logic [31:0] din,
	input logic [1:0] sel,
	output logic [31:0] dout0,dout1,dout2,dout3
	);

always_ff @(posedge clk)
begin

	if(sel == 2'b00)
		dout0 <= din;
	else if(sel == 2'b01)
		dout1 <= din;
	else if(sel == 2'b10)
		dout2 <= din;
	else if(sel == 2'b11)
		dout3 <= din;
	else
		begin
		dout0 <= 32'b0;
		dout1 <= 32'b0;
		dout2 <= 32'b0;
		dout3 <= 32'b0;
		end

end

endmodule
