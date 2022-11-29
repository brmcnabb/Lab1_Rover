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
task map (input [11:0] x, in_min, in_max, out_min, out_max, output [11:0] x_out);
    begin
        x_out = (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
    end
endtask

task constrain (input [11:0] x, a, b, output [11:0] x_out);
    begin
        if(x > b)
        begin
            x_out = b;
        end
        else
        begin
            if(x < a)
            begin
                x_out = a;
            end
            else
            begin
                x_out = x;
            end
        end
    end
endtask



module ColorSensor_Test(
    input clock100,
    input sensorOUT,
    output reg LED0,
    output reg LED1,
    output reg LED2,
    output reg LED3,
    output reg S0,
    output reg S1,
    output reg S2,
    output reg S3
    
    );
        reg clock25;
        reg clockset = 1'b0;
        reg sensorOUTC = 1;     
        reg calibrate = 0;
        reg[11:0] COUNTER;
        reg[27:0] COUNTERD;
        reg[11:0] greenMin;
        reg[11:0] greenMax;
        reg[11:0] redMin;
        reg[11:0] redMax;
        reg[11:0] blueMin;
        reg[11:0] blueMax;
        reg[11:0] redfreq;
        reg[11:0] greenfreq;
        reg[11:0] bluefreq;
        reg[11:0] redcolor;
        reg[11:0] greencolor;
        reg[11:0] bluecolor;
        reg[11:0] maxVal;
        parameter COUNT = 27'd10000000;
        
        
task pulseIn (input pin, value, output [11:0] freq);    //Measures length of frequency from input pin

endtask      
    initial begin
        S0 = 1;
        S1 = 0;
        LED0 = 0;
        LED1 = 0;
        LED2 = 0;
        LED3 = 0;
        #2000000000;
        LED0 = 1;
        #1000000000;
        S2 = 0;
        S3 = 0;
        pulseIn(sensorOUT, 0, redMin);
        #100000000;
        S2 = 1;
        S3 = 1;
        pulseIn(sensorOUT, 0, greenMin);
        #100000000;
        S2 = 0;
        S3 = 1;
        pulseIn(sensorOUT, 0, blueMin);
        #100000000;
        LED0 = 0;
        #2000000000;
        LED0 = 1;
        S2 = 0;
        S3 = 0;
        pulseIn(sensorOUT, 0, redMax);
        #100000000;
        S2 = 1;
        S3 = 1;
        pulseIn(sensorOUT, 0, greenMax);
        #100000000;
        S2 = 0;
        S3 = 1;
        pulseIn(sensorOUT, 0, blueMax);
        #100000000;
        LED0 = 0;
        
        
    end
    
    always@(posedge sensorOUT)begin
        sensorOUTC = 1;
    end
    
    always@(negedge sensorOUT)begin
        sensorOUTC = 0;
    end
    
    always@(posedge clock100)begin   
        COUNTERD = COUNTERD + 1;
        if(COUNTERD > COUNT)
        begin
            clock25 = ~clock25;
            COUNTERD = 11'd0;
        end
        if(sensorOUTC == 1)
        begin
            COUNTER = COUNTER + 1;
        end
        else if (S2 == 0 && S3 == 0)begin
            redfreq = COUNTER;
            map(redfreq, redMin, redMax, 0, 255, redcolor);
            constrain(redcolor, 0, 255, redcolor);
        end
        else if (S2 == 1 && S3 == 1)begin
            greenfreq = COUNTER;
            map(greenfreq, greenMin, greenMax, 0, 255, greencolor);
            contrain(greencolor, 0, 255, greencolor);
        end
        else if (S2 == 0 && S3 == 1)begin
            bluefreq = COUNTER;
            map(bluefreq, blueMin, blueMax, 0, 255, bluecolor);
            contrain(bluecolor, 0, 255, bluecolor);
        end
        if(calibrate == 0)begin //White calibration
            if (clock25 == 1) begin
                calibrate = calibrate + 1;
                S2 = 0;
                S3 = 0;
            end
        end
        else if(calibrate == 1)begin //Black calibration
            redMin = COUNTER;
        end
        else if(calibrate == 2)begin //Normal mode
        
        end
//        S2 = 0;
//        S3 = 0;
//        pulseIn(sensorOUT, 0, redfreq);
        
//        S2 = 1;
//        S3 = 1;
//        pulseIn(sensorOUT, 0, greenfreq);
        
//        S2 = 0;
//        S3 = 1;
//        pulseIn(sensorOUT, 0, bluefreq);
 
        if(redcolor > greencolor)
        begin
            maxVal = redcolor;
        end
        else
        begin
            maxVal = greencolor;
        end
        if(bluecolor > maxVal)
        begin
            maxVal = bluecolor;
        end
        map(redcolor, 0, maxVal, 0, 255, redcolor);
        map(greencolor, 0, maxVal, 0, 255, greencolor);
        map(bluecolor, 0, maxVal, 0, 255, bluecolor);
        constrain(redcolor, 0, 255, redcolor);
        contrain(greencolor, 0, 255, greencolor);
        contrain(bluecolor, 0, 255, bluecolor);




 if (redcolor > 250 && greencolor < 200 && bluecolor < 200) 
 begin
    LED0 = 1; //red
    LED1 = 0;
    LED2 = 0;
    LED3 = 0;
 end
 else if (redcolor < 200 && greencolor > 250 && bluecolor < 200) 
 begin
    LED0 = 0; //green
    LED1 = 1;
    LED2 = 0;
    LED3 = 0;
 end
 else if (redcolor < 200 /*&& greenColor < 200*/ && bluecolor > 250) 
 begin
    LED0 = 0; //blue
    LED1 = 0;
    LED2 = 1;
    LED3 = 0;
 end
 else 
 begin
    LED0 = 0; //unknown
    LED1 = 0;
    LED2 = 0;
    LED3 = 1;
 end
    end
endmodule
