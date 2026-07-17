module alu(
    input CLOCK_50,
    input [1:0] KEY,
    input [9:0] SW,
    output [9:0] LEDR
);

    wire reset_n;
    assign reset_n = KEY[1];   // press KEY1 to reset

    wire key0_pulse;

    reg phase;

    reg [7:0] A;
    reg [7:0] B;

    reg [1:0] op_upper;
    reg [1:0] op_lower;

    wire [3:0] full_opcode;
    assign full_opcode = {op_upper, op_lower};

    wire [7:0] adder_out;
    wire [7:0] logic_out;
    wire [7:0] shifter_out;
    wire [7:0] final_result;

    wire adder_cout;
    wire adder_overflow;
    wire shifter_cout;

    debounce_key0_simple debouncer ( //using the debounce_key0_simple file naming the module debouncer
        .clk(CLOCK_50),
        .key_in(KEY[0]),
        .key0_pulse(key0_pulse)
    );

    always @(posedge CLOCK_50 or negedge reset_n) begin
        if (!reset_n) begin
            phase <= 1'b0;
            A <= 8'b00000000;
            B <= 8'b00000000;
            op_upper <= 2'b00;
            op_lower <= 2'b00;
        end
        else if (key0_pulse) begin
            if (phase == 1'b0) begin
                A <= SW[7:0];
                op_upper <= SW[9:8];
                phase <= 1'b1;
            end
            else begin
                B <= SW[7:0];
                op_lower <= SW[9:8];
                phase <= 1'b0;
            end
        end
    end

    adder_subtractor arithmetic_unit ( //arithmetic unit
        .A(A),
        .B(B),
        .op0(full_opcode[0]),
        .sum(adder_out),
        .cout(adder_cout),
        .overflow(adder_overflow)
    );

    logic_block logic_unit ( //logic unit
        .A(A),
        .B(B),
        .op1(full_opcode[1]),
        .op0(full_opcode[0]),
        .logic_out(logic_out)
    );

    shifter_with_carry shift_unit ( //shifter unit
        .A(A),
        .Cin(1'b0),
        .Dir(full_opcode[0]),
        .Result(shifter_out),
        .shifter_cout(shifter_cout)
    );

    mux_4to1 output_mux ( //4-1 selection
        .adder_in(adder_out),
        .logic_in(logic_out),
        .shifter_in(shifter_out),
        .bypass_in(A),
        .sel(full_opcode[3:2]),
        .mux_out(final_result) //mux decides what to output based on the selected op bits
    );
 
    assign LEDR[7:0] = final_result;
    assign LEDR[8] = (final_result == 8'b00000000); // Zero flag
    assign LEDR[9] = (full_opcode[3:2] == 2'b10) ? shifter_cout : adder_cout; //overflow flag

endmodule
