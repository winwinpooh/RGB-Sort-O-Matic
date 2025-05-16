module top(clk, rst, sensor_out, SW, vgaRed, vgaGreen, vgaBlue, hsync, vsync, s0, s1, s2, s3, led0, led1, servo_pwm_out, seg, an);
   input clk;
   input rst;
   input sensor_out;            // TCS3200 OUT pin
   input [2:0] SW;              // switches for color selection
   output [3:0] vgaRed;
   output [3:0] vgaGreen;
   output [3:0] vgaBlue;
   output hsync;
   output vsync;
   output s0;                   // TCS3200 S0 pin
   output s1;                   // TCS3200 S1 pin
   output s2;                   // TCS3200 S2 pin
   output s3;                   // TCS3200 S3 pin
   output led0;                 // for undesirable color, will flicker if no color selected
   output led1;                 // for desirable color
   output  [6:0] seg;
   output  [3:0] an;
   output servo_pwm_out;        // PWM signal for  servo

    wire red_detected;
    wire green_detected;
    wire blue_detected;
    color_sensor color_sensor_inst(
        .clk(clk), 
        .reset(rst), 
        .sensor_out(sensor_out), 
        .SW(SW), 
        .s0(s0), 
        .s1(s1), 
        .s2(s2), 
        .s3(s3), 
        .red_detected(red_detected), 
        .blue_detected(blue_detected), 
        .green_detected(green_detected), 
        .led0(led0),
        .led1(led1)
        //.AN(an), 
        //.seg(seg)
    );

    /*wire valid;
    wire [9:0] h_cnt;
    wire [9:0] v_cnt;
    wire clk_25mhz;
    clock_divider clk_divider_inst(
        .clk_out(clk_25mhz),
        .clk(clk)
    );
    
    vga_controller vga_inst(
        .pclk(clk_25MHz),
        .reset(rst),
        .hsync(hsync),
        .vsync(vsync),
        .valid(valid),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt)
    );    

    pixel_gen pixel_gen_inst(
        .h_cnt(h_cnt),
        .valid(valid),
        .sensorRed(red_detected), 
        .sensorBlue(blue_detected), 
        .sensorGreen(green_detected), 
        .vgaRed(vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue(vgaBlue)
    );*/
    
   servo_control servo_inst(
        .clk(clk), 
        .reset(rst),
        .on(red_detected || green_detected || blue_detected), 
        .servo_pwm(servo_pwm_out)
    );
    
endmodule