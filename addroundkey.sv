module addroundkey(
	input logic [127:0] msg,key,
	output logic [127:0] add_roundkey_out
	);

	assign add_roundkey_out = msg^key;

endmodule

