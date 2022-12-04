`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2022 01:01:30 PM
// Design Name: 
// Module Name: IPS_Test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//module top(S0, S1, S2, S3, LED0, LED1, LED2, LED3, SW1, sensorOUT, clock100, LEDPIN);
module top(/*SW1, SW2, SW3, pwmOUTR, pwmOUTG, pwmOUTB, */SW4, S0, S1, S2, S3, LED0, LED1, LED2, LED3, sensorOUT, clock100, LEDPIN);    
    input clock100;
    input sensorOUT;
//    input SW1;
//    input SW2;
//    input SW3;
    input SW4;
    
//    output pwmOUTR;
//    output pwmOUTG;
//    output pwmOUTB;
    output S0;
    output S1;
    output S2;
    output S3;
    output LED0;
    output LED1;
    output LED2;
    output LED3;
    output LEDPIN;
    
    color_count_compare sense(S0, S1, S2, S3, LED0, LED1, LED2, LED3, sensorOUT, clock100);
//    servo_control servo1(~SW1, pwmOUTR, clock100); //Set first val to 0 for 0 degrees/1 for 90 degrees, second val is pmod output
//    servo_control servo2(SW2, pwmOUTG, clock100);
//    servo_control servo3(SW3, pwmOUTB, clock100);
    assign LEDPIN = SW4;
    
endmodule

//module servo_control(SW2, pwmOUT, clock100);
//    input SW2;
//    input clock100;
    
//    output pwmOUT;
    
//    reg clock25;
//    reg [20:0] COUNTER;
//    reg [7:0] servotimer;
//    reg [1:0] servopwm;
//    reg [6:0] ClkCount;
//    reg ClkTick;
//    reg [11:0] PulseCount;
    
//    parameter COUNT = 4'd3;
//    parameter ClkDiv = 98;
    
//    wire switch;
    
//    assign switch = SW2;
    
//    initial begin
//        COUNTER = 21'd0;
//    end
    
//    always@(posedge clock100)begin          //Converts 100MHz clock to 25MHz clock
//        if(COUNTER == COUNT)
//        begin
//            clock25 = 1;
//            COUNTER <= 21'd0;
//        end
//        else
//        begin
//            COUNTER <= COUNTER + 1;
//            clock25 = 0;            
//        end
//    end
    
//    always@(posedge clock25)begin           //Next two always setup ClkTick with tick period of 1ms/256 = 3.9us
//        ClkTick <= (ClkCount==ClkDiv-2);
//    end
    
//    always@(posedge clock25)begin
//        if(ClkTick)begin
//            ClkCount <= 0;
//        end
//        else begin
//            ClkCount <= ClkCount + 1;
//        end
//    end
    
//    always@(posedge clock25)begin           //Every 256 ticks/1ms, PulseCount increases by 1. PulseCount rolls-over every 16ms, which is close enough to SG90 period of 20ms.
//        if(ClkTick)begin
//            PulseCount <= PulseCount + 1;
//        end            
//    end
    
//    always@(posedge clock25)begin           //Sets duty cycle depending on input
//        if(switch)begin
//            servotimer = 8'd255;  
//        end
//        else begin
//            servotimer = 8'd00;
//        end
//    end
        
//    always@(posedge clock25)begin                       //Each pulse starts when PulseCount = 0, ends when PulseCount is between 256 and 511.
//        servopwm = (PulseCount < {4'b0001, servotimer});//0001 is concatenated in front of servotimer, so servotimer is conveted from 0-255 to 256-511.    
//    end                                                 //Value between 256-511 determines duty cycle.
        
//    assign pwmOUT = ~servopwm[0]; //Since a BJT inverter is used to convert the 3.3v output to 5v, the signal must be inverted to counteract the bjt inverter.    
//endmodule

module color_count_compare(S0, S1, S2, S3, LED0, LED1, LED2, LED3, sensorOUT, clock100);
    
    input clock100;
    input sensorOUT;
    
    output S0;
    output S1;
    output S2;
    output S3;
    output LED0;
    output LED1;
    output LED2;
    output LED3;
    
    reg [28:0] timer; //1.5 seconds
    reg [28:0] delay; // 0.25 seconds
    
    reg [60:0] redc;
    reg [60:0] greenc;
    reg [60:0] bluec;
    
    reg red_on;
    reg green_on;
    reg blue_on;
    
    reg [3:0] temp_S;
    reg [4:0] temp_color = 4'd0;
    
    always@(posedge clock100)begin
        timer = timer + 1;
        
        if(timer > 28'd150000000)
            delay = delay + 1;
            
        if(timer > 28'd150000000 && delay > 28'd25000000)begin
            timer = 28'd0;
            delay = 28'd0;
            redc = 20'd0;
            greenc = 20'd0;
            bluec = 20'd0;
            red_on = 13'd0;
            green_on = 13'd0;
            blue_on = 13'd0;
        end
        
        
                
        if(timer < 28'd50000000 && sensorOUT == 1)begin
            temp_S = 4'b0001;
            if(sensorOUT == 1 && red_on == 0)begin
                redc = redc + 1;
                if(sensorOUT == 0)
                    red_on = 1;
            end
        end
        
        if(timer > 28'd50000000 && timer < 28'd100000000 && sensorOUT == 1)begin
            temp_S = 4'b1101;
            if(sensorOUT == 1 && green_on == 0)begin
                greenc = greenc + 1;
                if(sensorOUT == 0)
                    green_on = 1;
            end
        end
        
        if(timer > 28'd100000000 && timer < 28'd150000001 && sensorOUT == 1)begin
            temp_S = 4'b1001;
            if(sensorOUT == 1 && blue_on == 0)begin
                bluec = bluec + 1;
                if(sensorOUT == 0)
                    blue_on = 1;
            end
        end
        
        
        
        if(timer > 28'd150000000 && delay < 28'd25000000)begin
            
            if(redc < /*((8'd30*bluec)/8'd100)*/bluec && redc < /*((8'd50*greenc)/8'd100)*/greenc && (redc < 32'd100000000000 || bluec < 32'd100000 || greenc < 32'd100000))begin
                temp_color = 4'b0001;
                end
            else begin    
            if(bluec < /*((8'd70*redc)/8'd100)*/redc && bluec < /*((8'd70*greenc)/8'd100)*/greenc && (redc < 32'd100000000000 || bluec < 32'd100000000000 || greenc < 32'd100000000000))begin
                temp_color = 4'b0100;
                end            
            else begin    
            if(greenc < /*((8'd60*redc)/8'd100)*/redc /* && greenc < bluec*/ && greenc < bluec && (redc < 32'd100000000000 || bluec < 32'd100000000000 || greenc < 32'd100000000000))begin
                temp_color = 4'b0010;
                end

            else begin
                temp_color = 4'b1000;
            end    
            end
            end
        end
    end
   
    assign S0 = temp_S[0];
    assign S1 = temp_S[1];
    assign S2 = temp_S[2];
    assign S3 = temp_S[3]; 
    assign LED1 = temp_color[0];
    assign LED2 = temp_color[1];
    assign LED3 = temp_color[2];
   assign LED0 = temp_color[3]; 
endmodule
//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 11/15/2022 01:01:30 PM
//// Design Name: 
//// Module Name: IPS_Test
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////
//task map (input [27:0] x, in_min, in_max, out_min, out_max, output [27:0] x_out);
//    begin
//        x_out = (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
//    end
//endtask

//task constrain (input [27:0] x, a, b, output [27:0] x_out);
//    begin
//        if(x > b)
//        begin
//            x_out = b;
//        end
//        else
//        begin
//            if(x < a)
//            begin
//                x_out = a;
//            end
//            else
//            begin
//                x_out = x;
//            end
//        end
//    end
//endtask



//module ColorSensor_Test(
//    input clock100,
//    input sensorOUT,
//    input button_color,
//    input SW1,
//    output reg LED0,
//    output reg LED1,
//    output reg LED2,
//    output reg LED3,
//    output reg LED4,
//    output reg LED5,
//    output reg LED6,
//    output reg LED7,
//    output reg LED8,
//    output reg LED9,
//    output reg LED10,
//    output reg LED11,
//    output reg LED12,
//    output reg LED13,
//    output reg LED14,
//    output reg LED15,
//    output reg S0,
//    output reg S1,
//    output reg S2,
//    output reg S3,
//    output LEDPIN
    
//    );
//        reg clock25;
//        reg redon = 0;
//        reg greenon = 0;
//        reg blueon = 0;
//        reg clockset = 1'b0;
//        reg sensorOUTC;
//        reg measure = 0;     
//        reg [3:0] calibrated;
//        reg[27:0] COUNTER;
//        reg[27:0] COUNTERD;
//        reg[27:0] COUNTERCALI;
//        reg[27:0] greenMin;
//        reg[27:0] greenMax;
//        reg[27:0] redMin;
//        reg[27:0] redMax;
//        reg[27:0] blueMin;
//        reg[27:0] blueMax;
//        reg[27:0] freq;
//        reg[27:0] redfreq;
//        reg[27:0] greenfreq;
//        reg[27:0] bluefreq;
//        reg rcali = 0;
//        reg gcali = 0;
//        reg bcali = 0;
//        reg[27:0] redcolor = 28'd0;
//        reg[27:0] greencolor = 28'd0;
//        reg[27:0] bluecolor = 28'd0;
//        reg[27:0] maxVal;
//        reg [4:0] colorcheck;
//        reg start;
//        parameter COUNT = 27'd10000000;
//        parameter COUNT_2SEC = 27'd20;
        
              
//    initial begin
//        colorcheck = 4'd0;
//        calibrated = 4'd0;
//        sensorOUTC = 0;
//        COUNTER <= 0;
//        //start = 0;
//        S0 = 1;
//        S1 = 0;
//        LED0 = 0;
//        LED1 = 0;
//        LED2 = 0;
//        LED3 = 0;
//        LED4 = 0;
//        LED5 = 0;
//        LED6 = 0;
//        LED7 = 0;
//        LED8 = 0;
//        LED9 = 0;
//        LED10 = 0;
//        LED11 = 0;
        
//    end
    
//    assign LEDPIN = SW1;
//    //assign LED8 = sensorOUT;
//    //assign start = button_color;
    
////    always@(posedge sensorOUT)begin
////        sensorOUTC = 1;
////    end
    
////    always@(negedge sensorOUT)begin
////        sensorOUTC = 0;
////    end
    
    
    
//    always@(posedge clock100)begin   
//        if(COUNTERD == COUNT)
//        begin
//            clock25 <= 1;
//            COUNTERD <= 11'd0;
//        end
//        else
//        begin
//            clock25 <= 0;
//            COUNTERD <= COUNTERD + 1;            
//        end
//    end
    
//    always@(posedge clock100)begin
////    case(calibrated)
////            4'd0    :begin    //Red
////                        LED4 = 0;
////                        LED5 = 0;
////                        LED6 = 0;
////                        LED7 = 0;                        
////                    end
////            4'd1    :begin    //Red
////                        LED4 = 1;
////                        LED5 = 0;
////                        LED6 = 0;
////                        LED7 = 0;                        
////                    end
////            4'd2    :begin    //Green
////                        LED4 = 0;
////                        LED5 = 1;
////                        LED6 = 0;
////                        LED7 = 0;
////                    end
////            4'd3    :begin
////                        LED4 = 0;
////                        LED5 = 0;
////                        LED6 = 1;
////                        LED7 = 0;
////                    end
////            4'd4    :begin
////                        LED4 = 0;
////                        LED5 = 0;
////                        LED6 = 0;
////                        LED7 = 1;
////                    end        
////            default :begin
////                        LED4 = 1;
////                        LED5 = 1;
////                        LED6 = 1;
////                        LED7 = 1;
////                     end
////        endcase 
//    if(clock25)
//        begin
//        case(colorcheck)
//            4'd0    :begin    //Red
//                        LED0 = 1;
//                        LED1 = 0;
//                        LED2 = 0;
//                        LED3 = 0;
//                        LED4 = 0;
//                        LED5 = 0;
//                        LED6 = 0;
//                        LED7 = 0;
//                        redon = 0;
//                        blueon = 0;
//                        greenon = 0;
//                        redcolor = 28'd0;
//                        greencolor = 28'd0;
//                        bluecolor = 28'd0;
//                        colorcheck = 4'd1;                        
//                    end
//            4'd1    :begin
//                        S2 = 0;
//                        S3 = 0;
//                        colorcheck = 4'd2;
//                    end        
//            4'd2    :begin    //Green
//                        LED1 = 1;
//                        LED0 = 0;
//                        LED2 = 0;
//                        LED3 = 0;
//                        S2 = 1;
//                        S3 = 1;
//                        colorcheck = 4'd3;
//                    end
//            4'd3    :begin  //Blue
//                        LED0 = 0;
//                        LED1 = 0;
//                        LED2 = 1;
//                        LED3 = 0;
//                        S2 = 0;
//                        S3 = 1;
//                        colorcheck = 4'd4;
//                    end
//            4'd4    :begin
//                        LED0 = 0;
//                        LED1 = 0;
//                        LED2 = 0;
//                        LED3 = 1;
//                        colorcheck = 4'd5;
//                    end
//            4'd5    :begin
//                        if(redcolor > greencolor && redcolor > bluecolor)begin
//                            LED8 = 1;
//                            LED9 = 0;
//                            LED10 = 0;
//                            LED11 = 0;
//                        end
//                        else if(greencolor > redcolor && greencolor > bluecolor)begin
//                            LED8 = 0;
//                            LED9 = 1;
//                            LED10 = 0;
//                            LED11 = 0;
//                        end
//                        else if(bluecolor > redcolor && bluecolor > greencolor)begin
//                            LED8 = 0;
//                            LED9 = 0;
//                            LED10 = 1;
//                            LED11 = 0;
//                        end
//                        else begin
//                            LED8 = 0;
//                            LED9 = 0;
//                            LED10 = 0;
//                            LED11 = 1;
//                        end
//                        colorcheck = 4'd0;
//                    end               
//            default :begin
//                        colorcheck = 4'd0;
//                     end
//        endcase             
////        if(start == 1)begin
////            calibrated = 1;
////        end
//        if(button_color == 1 && calibrated == 4'd0)begin
//            calibrated = 4'd1;
//        end
//        if(calibrated == 4'd1)begin
//            if(COUNTERCALI == COUNT_2SEC)
//            begin
//                //LED4 = 0;
//                //LED5 = 1;
//                COUNTERCALI = 11'd0;
//                calibrated = 4'd2;
//            end
//            else
//            begin
//                COUNTERCALI = COUNTERCALI + 1;
//                //LED4 = 1;
//            end
            
//        end
        
//        if(calibrated == 4'd3)begin
//            COUNTERCALI = COUNTERCALI + 1;
//            if(COUNTERCALI > COUNT_2SEC)
//            begin
//                calibrated = 4'd4;
//                COUNTERCALI = 11'd0;
//            end
//        end
//        end
//        if(sensorOUT == 1 && colorcheck == 2 && redon == 0)
//        begin
//            redcolor = redcolor + 1;       
//        end    
//        else if(sensorOUT == 0 && colorcheck == 2)
//        begin
//            redon = 1;
//            LED5 = 1;    
//        end
//        if(sensorOUT == 1 && colorcheck == 3 && greenon == 0)
//        begin
//            greencolor = greencolor + 1;
//        end    
//        else if(sensorOUT == 0 && colorcheck == 3)
//        begin
//            greenon = 1;
//            LED6 = 1;    
//        end
//        if(sensorOUT == 1 && colorcheck == 4 && blueon == 0)
//        begin
//            bluecolor = bluecolor + 1;
//        end    
//        else if(sensorOUT == 0 && colorcheck == 4)
//        begin
//            blueon = 1;
//            LED7 = 1;    
//        end

        
////        if (S2 == 0 && S3 == 0 && calibrated == 4'd5 && colorcheck == 4'd1)begin
////            //map(freq, redMin, redMax, 8'd0, 8'd255, redcolor);
////            //constrain(redcolor, 8'd0, 8'd255, redcolor);
////            redcolor = freq;
////        end
////        if (S2 == 1 && S3 == 1 && calibrated == 4'd5 && colorcheck == 4'd2)begin
////            //map(freq, greenMin, greenMax, 8'd0, 8'd255, greencolor);
////            //constrain(greencolor, 8'd0, 8'd255, greencolor);
////            greencolor = freq;
////        end
////        if (S2 == 0 && S3 == 1 && calibrated == 4'd5 && colorcheck == 4'd3)begin
////            //map(freq, blueMin, blueMax, 8'd0, 8'd255, bluecolor);
////            //constrain(bluecolor, 8'd0, 8'd255, bluecolor);
////            bluecolor = freq;
////        end
////        if (S2 == 0 && S3 == 0 && calibrated == 4'd2)begin
////            redMin = freq;
////            //LED5 = 1;
////            rcali = 1;
////        end
////        else if (S2 == 1 && S3 == 1 && calibrated == 4'd2)begin
////            greenMin = freq;
////            //LED6 = 1;
////            gcali = 1;
////        end
////        else if (S2 == 0 && S3 == 1 && calibrated == 4'd2)begin
////            blueMin = freq;
////            //LED7 = 1;
////            bcali = 1;
////        end
////        else if (S2 == 0 && S3 == 0 && calibrated == 4'd4)begin
////            redMax = freq;
////            rcali = 1;
////        end
////        else if (S2 == 1 && S3 == 1 && calibrated == 4'd4)begin
////            greenMax = freq;
////            gcali = 1;
////        end
////        else if (S2 == 0 && S3 == 1 && calibrated == 4'd4)begin
////            blueMax = freq;
////            bcali = 1;
////        end
////        if(rcali == 1 && gcali == 1 && bcali == 1 && calibrated == 4'd2)begin
////            rcali = 0;
////            gcali = 0;
////            bcali = 0;
////            calibrated = 4'd3;
////        end
////        if(rcali == 1 && gcali == 1 && bcali == 1 && calibrated == 4'd4)begin
////            rcali = 0;
////            gcali = 0;
////            bcali = 0;
////            calibrated = 4'd5;
////        end

////        if(colorcheck == 4)begin 
//////            LED8 = COUNTER[8];
//////            LED9 = COUNTER[9];
//////            LED10 = COUNTER[10];
//////            LED11 = COUNTER[11];
//////            LED12 = COUNTER[12];
//////            LED13 = COUNTER[13];
//////            LED14 = COUNTER[14];
//////            LED15 = COUNTER[15];
            
//////            if(redcolor > greencolor && redcolor > bluecolor)begin
//////                LED8 = 1;
//////                LED9 = 0;
//////                LED10 = 0;
//////                LED11 = 0;
//////            end
//////            else if(greencolor > redcolor && greencolor > bluecolor)begin
//////                LED8 = 0;
//////                LED9 = 1;
//////                LED10 = 0;
//////                LED11 = 0;
//////            end
//////            else if(bluecolor > redcolor && bluecolor > greencolor)begin
//////                LED8 = 0;
//////                LED9 = 0;
//////                LED10 = 1;
//////                LED11 = 0;
//////            end
//////            else begin
//////                LED8 = 0;
//////                LED9 = 0;
//////                LED10 = 0;
//////                LED11 = 1;
//////            end
//////            if(redcolor > greencolor)
//////            begin
//////                //maxVal = redcolor;
//////                if(bluecolor > redcolor)
//////                begin
//////                    //maxVal = bluecolor;
//////                    LED8 = 1;
//////                    LED9 = 0;
//////                    LED10 = 0;
//////                    map(redcolor, 8'd0, bluecolor, 8'd0, 8'd255, redcolor);
//////                    map(greencolor, 8'd0, bluecolor, 8'd0, 8'd255, greencolor);
//////                    map(bluecolor, 8'd0, bluecolor, 8'd0, 8'd255, bluecolor);
//////                end
//////                else
//////                begin
//////                    map(redcolor, 8'd0, redcolor, 8'd0, 8'd255, redcolor);
//////                    map(greencolor, 8'd0, redcolor, 8'd0, 8'd255, greencolor);
//////                    map(bluecolor, 8'd0, redcolor, 8'd0, 8'd255, bluecolor);
//////                end
//////            end
//////            else
//////            begin
//////                //maxVal = greencolor;
//////                if(bluecolor > greencolor)
//////                begin
//////                    //maxVal = bluecolor;
//////                    map(redcolor, 8'd0, bluecolor, 8'd0, 8'd255, redcolor);
//////                    map(greencolor, 8'd0, bluecolor, 8'd0, 8'd255, greencolor);
//////                    map(bluecolor, 8'd0, bluecolor, 8'd0, 8'd255, bluecolor);
//////                end
//////                else
//////                begin
//////                    map(redcolor, 8'd0, greencolor, 8'd0, 8'd255, redcolor);
//////                    map(greencolor, 8'd0, greencolor, 8'd0, 8'd255, greencolor);
//////                    map(bluecolor, 8'd0, greencolor, 8'd0, 8'd255, bluecolor);
//////                end
//////            end
//////            if(bluecolor > maxVal)
//////            begin
//////                maxVal = bluecolor;
//////            end
//////            map(redcolor, 0, maxVal, 0, 255, redcolor);
//////            map(greencolor, 0, maxVal, 0, 255, greencolor);
//////            map(bluecolor, 0, maxVal, 0, 255, bluecolor);
//////            constrain(redcolor, 8'd0, 8'd255, redcolor);
//////            constrain(greencolor, 8'd0, 8'd255, greencolor);
//////            constrain(bluecolor, 8'd0, 8'd255, bluecolor);
//////            if (redcolor > 8'd230 && greencolor < 8'd200 && bluecolor < 8'd200) 
//////            begin
//////                LED8 = 1; //red
//////                LED9 = 0;
//////                LED10 = 0;
//////                LED11 = 0;
//////                LED12 = 0; 
//////                LED13 = 0;
//////                LED14 = 0;
//////                //LED15 = 0;
//////            end
//////            else if (redcolor < 8'd200 && greencolor > 8'd230 && bluecolor < 8'd200) 
//////            begin
//////                LED8 = 0; //green
//////                LED9 = 1;
//////                LED10 = 0;
//////                LED11 = 0;
//////                LED12 = 0; 
//////                LED13 = 0;
//////                LED14 = 0;
//////                //LED15 = 0;
//////            end
//////            else if (redcolor < 8'd200 && bluecolor > 8'd230) 
//////            begin
//////                LED8 = 0; //blue
//////                LED9 = 0;
//////                LED10 = 1;
//////                LED11 = 0;
//////                LED12 = 0; 
//////                LED13 = 0;
//////                LED14 = 0;
//////                //LED15 = 0;
//////            end
//////            else if (redcolor > 8'd230 && greencolor > 8'd230 && bluecolor > 8'd230) 
//////            begin
//////                LED8 = 0; //white
//////                LED9 = 0;
//////                LED10 = 0;
//////                LED11 = 1;
//////                LED12 = 0; 
//////                LED13 = 0;
//////                LED14 = 0;
//////                //LED15 = 0;
//////            end
//////            else if (redcolor < 8'd25 && greencolor < 8'd25 && bluecolor < 8'd25) 
//////            begin
//////                LED8 = 0; //black
//////                LED9 = 0;
//////                LED10 = 0;
//////                LED11 = 0;
//////                LED12 = 1; 
//////                LED13 = 0;
//////                LED14 = 0;
//////                //LED15 = 0;
//////            end
//////            else if (redcolor > 8'd200 && greencolor > 8'd200 && bluecolor < 8'd100) 
//////            begin
//////                LED8 = 0; //yellow
//////                LED9 = 0;
//////                LED10 = 0;
//////                LED11 = 0;
//////                LED12 = 0; 
//////                LED13 = 1;
//////                LED14 = 0;
//////                //LED15 = 0;
//////            end
//////            else if (redcolor > 8'd200 && greencolor > 8'd25) 
//////            begin
//////                LED8 = 0; //orange
//////                LED9 = 0;
//////                LED10 = 0;
//////                LED11 = 0;
//////                LED12 = 0; 
//////                LED13 = 0;
//////                LED14 = 1;
//////                //LED15 = 0;
//////            end
//////            else if (redcolor > 8'd200 && greencolor < 8'd100 && bluecolor > 8'd200) 
//////            begin
//////                LED8 = 0; //purple
//////                LED9 = 0;
//////                LED10 = 0;
//////                LED11 = 0;
//////                LED12 = 0; 
//////                LED13 = 0;
//////                LED14 = 0;
//////                //LED15 = 1;
//////            end
//////            else 
//////            begin
//////                LED8 = 0; //unknown
//////                LED9 = 0;
//////                LED10 = 0;
//////                LED11 = 0;
//////                LED12 = 0;
//////                LED13 = 0;
//////                LED14 = 0;
//////                //LED15 = 0;
//////            end
////        end



 
//    end
//    //end
////    always@(posedge clock25)begin
////        if(colorcheck == 0)begin    //Red
////            colorcheck = 1;
////            S2 = 0;
////            S3 = 0;
////        end
////        if(colorcheck == 1)begin    //Green
////            colorcheck = 2;
////            S2 = 1;
////            S3 = 1;
////        end
////        if(colorcheck == 2)begin    //Blue
////            colorcheck = 3;
////            S2 = 0;
////            S3 = 1;
////        end
////        if(colorcheck == 3)begin
////            colorcheck = 0;
////        end
////        if(start == 1)begin
////            calibrated = 1;
////        end
////        if(calibrated == 1)begin
////            COUNTERCALI = COUNTERCALI + 1;
            
////            if(COUNTERCALI > COUNT_2SEC && calibrated == 1)
////            begin
////                calibrated = 2;
////                start = 2;
                
////                COUNTERCALI = 11'd0;
////                calibrated = 8'd2;
////            end
            
////        end
        
////        if(calibrated == 3)begin
////            COUNTERCALI = COUNTERCALI + 1;
////            if(COUNTERCALI > COUNT_2SEC)
////            begin
////                calibrated = 4;
////                COUNTERCALI = 11'd0;
////            end
////        end
////    end
//endmodule