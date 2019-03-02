module mux_128 #(parameter width = 128) //4 to 1 mux
(
	input logic [width-1:0] s00, s01, s10, s11,
   input logic [1:0] sel,					//input select bits
   output logic [width-1:0] dout
);

always_comb
begin

	case (sel)
	       2'b00:
		       dout = s00;
	       2'b01:
		       dout = s01;
	       2'b10:
		       dout = s10;
	       2'b11:
		       dout = s11;
       endcase
end

endmodule
