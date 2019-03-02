//16 32-bit registiers
module regs
(	input logic Clk, Reset, LD_REG,
	input logic [4:0] select,
   input logic [31:0]  D_in,
   output logic [31:0]  D_out);

logic[31:0] din[16];
	
always_ff @ (posedge Clk)
begin
	if (Reset) //reset registers
	begin
		din[0] = 32'h0000;
		din[1] = 32'h0000;
		din[2] = 32'h0000;
		din[3] = 32'h0000;
		din[4] = 32'h0000;
		din[5] = 32'h0000;
		din[6] = 32'h0000;
		din[7] = 32'h0000;
		din[8] = 32'h0000;
		din[9] = 32'h0000;
		din[10] = 32'h0000;
		din[11] = 32'h0000;
		din[12] = 32'h0000;
		din[13] = 32'h0000;
		din[14] = 32'h0000;
		din[15] = 32'h0000;
	end
	else if (LD_REG)
		din[select] = D_in;
end

assign D_out = din[select];

endmodule