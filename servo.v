module servo_control(clk, reset, on, servo_pwm);
    input clk;              // 100 MHz clock
    input reset;            // Reset signal
    input on;              // Signal to activate servo
    output reg servo_pwm;    // PWM output

    parameter CLOCK_FREQ = 100_000_000; // 100 MHz clock
    parameter PWM_PERIOD = 20_000_000;  // 20 ms (20 ms * 100 MHz)
    parameter PULSE_MIN = 1_000_000;    // 1 ms pulse width (0 degrees)
    parameter PULSE_MAX = 2_000_000;    // 2 ms pulse width (180 degrees)
    parameter ROTATION_DELAY = CLOCK_FREQ / 10; // 0.1 seconds for smooth transition

    reg [31:0] counter = 0;   
    reg [31:0] pulse_width = 0; 
    reg [1:0] position = 0;     // Tracks servo position
    reg [31:0] delay_counter = 0;
    
    always @(posedge clk) begin
        if (reset) begin
            position <= 2'b00;
            pulse_width <= PULSE_MIN; // Start at 0 degrees
            counter <= 0;
            delay_counter <= 0;
            servo_pwm <= 0;
        end else begin
            if (on) begin
                // Manage the delay for each movement
                if (delay_counter < ROTATION_DELAY) begin
                    delay_counter <= delay_counter + 1;
                end else begin
                    delay_counter <= 0;
                    position <= position + 1; // Increment position to alternate between 0 and 180
                    if (position == 2) begin
                        position <= 0; // Reset position after completing 360 degrees
                    end
                end

                // Set pulse width based on the current position
                pulse_width <= (position == 0) ? PULSE_MIN : PULSE_MAX;
            end else begin
                pulse_width <= 0; // Stop PWM when not active
            end

            // Generate PWM signal
            counter <= counter + 1;
            if (counter >= PWM_PERIOD) begin
                counter <= 0;
            end

            if (pulse_width > 0 && counter < pulse_width) begin
                servo_pwm <= 1;
            end else begin
                servo_pwm <= 0;
            end
        end
    end
endmodule
