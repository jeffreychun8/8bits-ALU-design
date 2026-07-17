module mux_4to1(

input [7:0] adder_in,
input [7:0] logic_in,
input [7:0] shifter_in,
input [7:0] bypass_in,
input [1:0] sel,
output [7:0] mux_out
);

assign mux_out = (sel == 2'b00)? adder_in :
					  (sel == 2'b01)? logic_in :
					  (sel == 2'b10)? shifter_in:
											bypass_in;
										
endmodule
