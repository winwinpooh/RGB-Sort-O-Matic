module MotorBControl (
    input motor_switch,      // Input from an FPGA switch
    input clk,               // FPGA clock input
    output motor_in3,        // IN3 control
    output motor_in4,        // IN4 control
    output motor_enb,        // ENB (PWM output for motor B)
    output motor_in1,        // IN1 control
    output motor_in2,        // IN2 control
    output motor_ena         // ENA (PWM output for motor A)
);

    // Parameters for slower PWM
    parameter CLK_FREQ = 100_000_000;     // FPGA clock frequency (100 MHz)
    parameter PWM_FREQ = 500;            // Slightly higher PWM frequency (500 Hz)
    parameter DUTY_CYCLE = 10;           // Slightly higher duty cycle (10% for smoother operation)

    parameter SLOW_PWM_DIV = CLK_FREQ / (PWM_FREQ * 2); // Clock divider for 500 Hz PWM

    reg [31:0] clk_div_counter = 0;       // 32-bit counter for clock divider
    reg pwm_clk = 0;                      // Slow clock for PWM
    reg [7:0] pwm_counter = 0;            // 8-bit PWM counter
    reg pwm_signal;                       // PWM output signal

    // Clock divider for slow PWM clock
    always @(posedge clk) begin
        if (clk_div_counter >= SLOW_PWM_DIV) begin
            clk_div_counter <= 0;
            pwm_clk <= ~pwm_clk; // Toggle slow clock
        end else begin
            clk_div_counter <= clk_div_counter + 1;
        end
    end

    // PWM generation using the slow clock
    always @(posedge pwm_clk) begin
        if (pwm_counter < DUTY_CYCLE) begin
            pwm_signal <= 1;
        end else begin
            pwm_signal <= 0;
        end

        if (pwm_counter >= 100) begin
            pwm_counter <= 0; // Reset counter for 100-step duty cycle
        end else begin
            pwm_counter <= pwm_counter + 1;
        end
    end

    // Assign motor outputs
    assign motor_in3 = motor_switch;  
    assign motor_in4 = 0;            
    assign motor_enb = pwm_signal;   // Use slow PWM signal for ENB

    assign motor_in1 = motor_switch;  
    assign motor_in2 = 0;            
    assign motor_ena = pwm_signal;   // Use slow PWM signal for ENA

endmodule