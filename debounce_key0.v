module debounce_key0_simple(
    input  clk,            // CLOCK_50
    input  key_in,         // raw KEY[0], active-low
    output key0_pulse      // 1-cycle pulse on press
);

    reg [19:0] counter = 0;     // ~21ms timer @ 50MHz
    reg        debounced = 1;   // idle = 1 (active-low button)
    reg        debounced_d = 1;

    always @(posedge clk) begin
        if (key_in == debounced) begin
            // input agrees with what we currently believe -> reset timer
            counter <= 0;
        end else begin
            // input disagrees -> count up; if it disagrees long enough, believe it
            counter <= counter + 1;
            if (counter == 20'hFFFFF)
                debounced <= key_in;
        end
        debounced_d <= debounced;
    end

    // press = 1 -> 0 transition
    assign key0_pulse = debounced_d & ~debounced;

endmodule

