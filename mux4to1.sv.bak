module mux4to1 #(parameter width = 16) //4 to 1 mux
(
	input logic [width-1:0] s00, s01, s10, s11,
   input logic [1:0] sel,					//input select bits
   output logic [width-1:0] out
);

always_comb
begin

	case (sel)
	       2'b00:
		       out = s00;
	       2'b01:
		       out = s01;
	       2'b10:
		       out = s10;
	       2'b11:
		       out = s11;
       endcase
end

endmodule
