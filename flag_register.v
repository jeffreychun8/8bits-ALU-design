// flag_register.v
// Synchronous flag register for an 8-bit ALU.
//
// Captures C, Z, V, N flags once per clock, based on the
// adder/subtractor and shifter outputs.
//
//   C (Carry)    = adder_cout OR shifter_cout
//   Z (Zero)     = 1 when sum[7:0] == 0
//   V (Overflow) = adder_overflow, registered as-is
//   N (Negative) = sum[7]  (sign bit of the result)

module flag_register (
    input  wire       clk,
    input  wire        adder_cout,
    input  wire        adder_overflow,
    input  wire [7:0]  sum,
    input  wire        shifter_cout,

    output reg  Carry_Flag,
    output reg  Zero_Flag,
    output reg  Overflow_Flag,
    output reg  Negative_Flag
);

    wire combined_carry;
    wire zero_calc;
    wire negative_calc;

    assign combined_carry = adder_cout | shifter_cout;
    assign zero_calc      = (sum == 8'b0000_0000);
    assign negative_calc  = sum[7];

    always @(posedge clk) begin
        Carry_Flag    <= combined_carry;
        Zero_Flag     <= zero_calc;
        Overflow_Flag <= adder_overflow;
        Negative_Flag <= negative_calc;
    end

endmodule