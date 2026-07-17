module adder_subtractor (
input [7:0] A,
input [7:0] B,
input op0, //act as carry in (if doing subtraction, carry in = op0 = 1 for twos complement)

output [7:0] sum,
output cout,
output overflow

);

wire [7:0] b_mux = op0? ~B : B;

assign {cout,sum} = A + b_mux + op0; 
//concatenating 2 8 bits with one bit op0 (to complete 2s complement)
// the left most bit becomes cout (1 bit) and the rest is sum (8 bits)

assign overflow = (A[7] == b_mux[7]) && (sum[7]!= A[7]);
//checking if the two number entering the adder are the same sign
//checking if the sum has different sign than A (overflow happens when two same sign number are added together
//the result must have a different sign than the two


endmodule 