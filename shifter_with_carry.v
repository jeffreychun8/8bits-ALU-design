module shifter_with_carry (

input [7:0] A,
input Cin,
input Dir,
output [7:0] Result,
output shifter_cout
);

//bunch of 2-1 muxes
assign Result[0] = Dir? A[1] : Cin;
assign Result[1] = Dir? A[2] : A[0];
assign Result[2] = Dir? A[3] : A[1];
assign Result[3] = Dir? A[4] : A[2];
assign Result[4] = Dir? A[5] : A[3];
assign Result[5] = Dir? A[6] : A[4];
assign Result[6] = Dir? A[7] : A[5];
assign Result[7] = Dir?  Cin : A[6];

//cout line wired to flag reg
assign shifter_cout = Dir? A[0] : A[7]; 

endmodule
