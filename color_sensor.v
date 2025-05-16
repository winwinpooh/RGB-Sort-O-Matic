module color_sensor(clk, reset, sensor_out, SW, s0, s1, s2, s3, red_detected, blue_detected, green_detected, led0, led1);
    input clk;          // System clock (100 MHz)
    input reset;        // Active-high reset
    input sensor_out;   // TCS3200 OUT pin
    input [2:0] SW;           // User switches: SW0, SW1, SW2
    output reg s0;           // TCS3200 S0 pin
    output reg s1;           // TCS3200 S1 pin
    output reg s2;           // TCS3200 S2 pin
    output reg s3;           // TCS3200 S3 pin
    output reg red_detected;
    output reg blue_detected;
    output reg green_detected;
    output reg led0;        // chosen color undetected
    output reg led1;        // chosen color detected
    //output reg [3:0] AN;
    //output reg [6:0] seg;

    parameter CLK_FREQ        = 100_000_000; // 100 MHz clock
    parameter MEASUREMENT_MS  = 50;          // measurement interval in ms
    parameter counter_interval = (CLK_FREQ/1000)*MEASUREMENT_MS;

    parameter STATE_RED   = 2'd0;
    parameter STATE_GREEN = 2'd1;
    parameter STATE_BLUE  = 2'd2;
    
    always @(*) begin
        s0 = 1'b1; 
        s1 = 1'b0;        
    end
    
    reg [1:0] state;
    reg [31:0] counter;
    reg [31:0] pulse_count;

    reg [31:0] red_count;
    reg [31:0] green_count;
    reg [31:0] blue_count;

    reg sensor_out_d1, sensor_out_d2;
    always @(posedge clk) begin
        sensor_out_d1 <= sensor_out;
        sensor_out_d2 <= sensor_out_d1;
    end

    wire rising_edge = (sensor_out_d1 & ~sensor_out_d2);
    
    always @(posedge clk) begin
        if (reset) begin
            state       <= STATE_RED;
            counter     <= 0;
            pulse_count <= 0;
            red_count   <= 0;
            green_count <= 0;
            blue_count  <= 0;
        end else begin
            if (counter < counter_interval - 1) begin
                counter <= counter + 1;
                if (rising_edge) 
                    pulse_count <= pulse_count + 1;
            end else begin
                // interval done, store result and move to next color
                case (state)
                    STATE_RED: begin
                        red_count   <= pulse_count;
                        state       <= STATE_GREEN;
                        // set to green filter: S2=1, S3=1
                        s2          <= 1'b1;
                        s3          <= 1'b1;
                    end
                    STATE_GREEN: begin
                        green_count <= pulse_count;
                        state       <= STATE_BLUE;
                        // set to blue filter: S2=0, S3=1
                        s2          <= 1'b0;
                        s3          <= 1'b1;
                    end
                    STATE_BLUE: begin
                        blue_count  <= pulse_count;
                        state       <= STATE_RED;
                        // back to red filter: S2=0, S3=0
                        s2          <= 1'b0;
                        s3          <= 1'b0;
                    end
                endcase

                // reset counter and pulse_count for next measurement
                counter     <= 0;
                pulse_count <= 0;
            end
        end
    end

    //wire valid_detection = (red_count > MIN_THRESHOLD) || 
    //                   (green_count > MIN_THRESHOLD) || 
    //                   (blue_count > MIN_THRESHOLD);

    // determine dominant color
    wire red_dominant   = (red_count > green_count) && (red_count > blue_count) &&  (red_count > 32'd300);
    wire green_dominant = (green_count > red_count) && (green_count > blue_count) && (green_count > 32'd200);
    wire blue_dominant  = (blue_count > red_count) && (blue_count > green_count) && (blue_count > 32'd200);
    reg [27:0] counter_led;     // counter for clock division
    reg flicker_led;            // register to hold the flickering LED state

    always @(posedge clk) begin
        counter_led <= counter_led + 1;
        if (counter_led == 50_000_000) begin
            flicker_led <= ~flicker_led;
            counter_led <= 0;
        end
    end

    always @(*) begin
        if ((SW[0] && red_dominant) || (SW[1] && green_dominant) || (SW[2] && blue_dominant)) begin 
        led1 = 1'b1;
        led0 = 1'b0;
        end
        
        else if ((SW[0] && !red_dominant) || (SW[1] && !green_dominant) || (SW[2] && !blue_dominant))begin 
        led1 = 1'b0;
        led0 = 1'b1;        
        end
        
        else begin 
        led1 = flicker_led;
        led0 = 1'b0;        
        end
    end

    always @(*) begin 
        red_detected   = SW[0] && red_dominant;
        green_detected = SW[1] && green_dominant;
        blue_detected  = SW[2] && blue_dominant;
    end
 /*   // Add a counter for counting detected events
    reg [31:0] product_count; // Counter for valid detections
    reg [31:0] detection_timer; // Timer for sustained detection
    reg detected_latch; // Latch to prevent multiple counts for the same detection

    // Parameters
    parameter DETECTION_TIMEOUT = CLK_FREQ; // 1 second timer

    // Logic to count detection events
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            product_count   <= 0;
            detection_timer <= 0;
            detected_latch  <= 0;
        end else begin
            // Check if the condition is detected
            if ((SW[0] && red_dominant) || (SW[1] && green_dominant) || (SW[2] && blue_dominant)) begin
                // Increment timer during detection
                if (detection_timer < DETECTION_TIMEOUT) begin
                    detection_timer <= detection_timer + 1;
                end
                
                // Increment counter only if not latched
                if (!detected_latch) begin
                    product_count  <= product_count + 1;
                    detected_latch <= 1; // Latch to prevent repeated counting
                end
            end else begin
                // Reset timer and latch when the condition is no longer valid
                detection_timer <= 0;
                detected_latch  <= 0;
            end
        end
    end
/    wire [1:0] sel; // for mux selection
    reg [19:0]refresh;
    always @(posedge clk) begin
        refresh <= refresh + 1;
    end
    
    assign sel = refresh[19:18];
// Use 'servo_active_sync2' as the synchronized signal
    // Registers for display
    reg [3:0] digit_ones;       // Ones place
    reg [3:0] digit_tens;       // Tens place
    reg [31:0] refresh_counter; // Counter for refreshing the display

    // Parameters for display refresh
    parameter REFRESH_RATE = CLK_FREQ / 1000; // Refresh rate (1 kHz)

    // Extract the ones and tens digits from the count
    always @(*) begin
        digit_ones = product_count % 10;
        digit_tens = (product_count / 10) % 10;
    end
    // Generate the seven-segment code for the current digit
    always @(*) begin
        case (sel)
            2'b00 : AN = 4'b0111;
            2'b01 : AN = 4'b1011;
            2'b10 : AN = 4'b1101;
            2'b11 : AN = 4'b1110;
            default : AN = 4'b0111;
        endcase
    end
    always @(*) begin
        case (AN)
            4'b1110: begin // Display ones digit on AN0
                case (digit_ones)
                    4'd0: seg = 7'b1000000;
                    4'd1: seg = 7'b1111001;
                    4'd2: seg = 7'b0100100;
                    4'd3: seg = 7'b0110000;
                    4'd4: seg = 7'b0011001;
                    4'd5: seg = 7'b0010010;
                    4'd6: seg = 7'b0000010;
                    4'd7: seg = 7'b1111000;
                    4'd8: seg = 7'b0000000;
                    4'd9: seg = 7'b0010000;
                    default: seg = 7'b1111111; // Blank
                endcase
            end
            4'b1101: begin // Display tens digit on AN1
                case (digit_tens)
                    4'd0: seg = 7'b1000000;
                    4'd1: seg = 7'b1111001;
                    4'd2: seg = 7'b0100100;
                    4'd3: seg = 7'b0110000;
                    4'd4: seg = 7'b0011001;
                    4'd5: seg = 7'b0010010;
                    4'd6: seg = 7'b0000010;
                    4'd7: seg = 7'b1111000;
                    4'd8: seg = 7'b0000000;
                    4'd9: seg = 7'b0010000;
                    default: seg = 7'b1111111; // Blank
                endcase
            end
            4'b1011, 4'b0111: begin 
                seg = 7'b1111111;
            end
            default: seg = 7'b1111111; // Blank
        endcase
    end

*/
endmodule
