module sensor_test(clk, reset, sensor_out, switch, s0, s1, s2, s3, an, seg);
    input clk;       
    input reset;    
    input sensor_out;
    input [1:0] switch;
    output reg s0;     
    output reg s1;      
    output reg s2;     
    output reg s3;      
    output reg[3:0] an;     
    output reg[6:0] seg;   

    parameter CLK_FREQ = 100_000_000; // 100 MHz 
    parameter MEASUREMENT_MS = 50;    // Measurement interval in ms
    parameter COUNTER_INTERVAL = (CLK_FREQ / 1000) * MEASUREMENT_MS;

    reg [31:0] counter = 0;
    reg [31:0] pulse_count = 0;
    reg [31:0] filter_count = 0;

    reg sensor_out_d1, sensor_out_d2;
    always @(posedge clk) begin
        sensor_out_d1 <= sensor_out;
        sensor_out_d2 <= sensor_out_d1;
    end

    wire rising_edge = (sensor_out_d1 & ~sensor_out_d2);

    always@(*) begin
        s0 = 1'b1; // Frequency scaling 
        s1 = 1'b0;

        if (switch[0]) begin 
        s2 = 1'b0; // red
        s3 = 1'b0;
        end

        else if (switch[1]) begin 
        s2 = 1'b0; // blue
        s3 = 1'b1;
        end

        else if (switch[2]) begin 
        s2 = 1'b1; // green
        s3 = 1'b1;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            counter <= 32'd0;
            pulse_count <= 32'd0;
            filter_count <= 32'd0;
        end else begin
            if (counter < COUNTER_INTERVAL - 32'd1) begin
                counter <= counter + 32'd1;
                if (rising_edge) pulse_count <= pulse_count + 32'd1;
            end else begin
                filter_count <= pulse_count; // Update blue count
                counter <= 32'd0;             // Reset counter
                pulse_count <= 32'd0;         // Reset pulse counter
            end
        end
    end

    wire [1:0] sel; 
    reg [19:0]refresh;
    always @(posedge clk) begin
        refresh <= refresh + 1;
    end
    
    assign sel = refresh[19:18];

    reg [3:0] digit_ones;       
    reg [3:0] digit_tens;       
    reg [31:0] refresh_counter; 
    reg [3:0] digit_hundredth;       


    parameter REFRESH_RATE = CLK_FREQ / 1000; 


    always @(*) begin
        digit_ones = filter_count % 10;
        digit_tens = (filter_count / 10) % 10;
        digit_hundredth = filter_count % 100;

    end

    always @(*) begin
        case (sel)
            2'b00 : an = 4'b0111;
            2'b01 : an = 4'b1011;
            2'b10 : an = 4'b1101;
            2'b11 : an = 4'b1110;
            default : an = 4'b0111;
        endcase
    end
    always @(*) begin
        case (an)
            4'b1110: begin 
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
                    default: seg = 7'b1111111; 
                endcase
            end
            4'b1101: begin 
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
                    default: seg = 7'b1111111; 
                endcase
            end
            4'b1011:begin
            case (digit_hundredth)
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
                    default: seg = 7'b1111111; 
                endcase
            end
            
            4'b0111: begin 
                seg = 7'b1111111;
            end
            default: seg = 7'b1111111; 
        endcase
end
endmodule
