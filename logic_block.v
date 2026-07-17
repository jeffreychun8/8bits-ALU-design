module logic_block (
input [7:0] A,
input [7:0] B,
input op1,
input op0,
output [7:0] logic_out
);

assign logic_out = (op1 == 0 && op0 == 00)? (A & B): //and
						 (op1 == 0 && op0 == 1)? (A | B): //or
						 (op1 == 1 && op0 == 0)? (A ^ B): //xor
						 (~A); // else not
									

endmodule

