`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2022 02:42:33 AM
// Design Name: 
// Module Name: Motor_Driver
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


module Motor_Driver(
    input CLK, SW0, SW4, IPS1, IPS2, IRA, IRB, sensorOUT,
    output ENA, ENB, FwA, BkA, FwB, BkB, a, b, c, d, e, f, g, LED0, LED1, LED2, S0, S1, S2, S3, LEDPIN, pwmOUTR, pwmOUTG, pwmOUTB, [3:0]an
);
    localparam N = 17;
    localparam refresh = 19; // this is the bit size of the counter + 1 needed for the PWM counter
    localparam [2:0]
        State_Idle = 3'd0,
        State_Forward = 3'd1,
        State_Left = 3'd2,
        State_Right = 3'd3,
        State_Pivot = 3'd4,
        State_Color = 3'd5,
        State_Reading = 3'd6;
    reg [2:0] state_reg = State_Idle, state_next;
    reg [29:0] count_reg = 0, count_next;    
    reg [3:0] in0,in1,in2,in3;
    reg PWM_A, PWM_B;
    reg [refresh:0] Counter; // current refresh rate is: 100 Hz
    reg [refresh:0] cycle_A;
    reg [refresh:0] cycle_B;
    reg [6:0] sseg;
    reg [3:0] an_temp;
    reg [6:0] sseg_temp;
    reg [N-1:0] counter1;
    reg over_a, over_b;
    reg DirA, DirB, sensLeft, sensRight, ReadEn, EnRed;
    wire ColRed, ColBlue, ColGreen, L0;
    assign LED0 = sense.temp_color[0];
    assign LED1 = sense.temp_color[1];
    assign LED2 = sense.temp_color[2];
    assign LED3 = sense.temp_color[3];
    assign LEDPIN = SW4;
    
    color_count_compare sense(S0, S1, S2, S3,/* L0, ColRed, ColGreen, ColBlue,*/ sensorOUT, clock100);
    servo_control servo1(~sense.temp_color[0], pwmOUTR, clock100); //Set first val to 0 for 0 degrees/1 for 90 degrees, second val is pmod output
    servo_control servo2(sense.temp_color[1], pwmOUTG, clock100);
    servo_control servo3(sense.temp_color[2], pwmOUTB, clock100);
    
    
    always@(posedge CLK) begin
        sensLeft = !IPS1 || IRA;
        sensRight = !IPS2 || IRB;
        state_reg <= state_next;
        count_reg <= count_next;
        if(Counter >= 1000000)
            Counter <= 0;
        else
            Counter <= Counter + 1;

        if(counter1 >= 100000)
            counter1 <= 0;
        else
            counter1 <= counter1 + 1;

        if(Counter <= cycle_A)
            PWM_A <= 1;
        else
            PWM_A <= 0;
        
        if(Counter <= cycle_B)
            PWM_B <= 1;
        else
            PWM_B <= 0;

/*      if(SW0 && (IPS1 && IPS2)) begin
            DirA = 0; DirB = 0;
            cycle_A = 20'd800000;
            cycle_B = 20'd800000;
        end
        else if(SW0 && !IPS1 && !IPS2) begin
            count_reg = 100000000;
            while(count_reg > 0) begin
            count_next = count_reg - 1;
            if(count_reg >= 27'd90000000) begin
                    DirA = 1; DirB = 1;
                end else if(count_reg >= 27'd70000000) begin
                    DirA = 1; DirB = 0;
                    cycle_A = 20'd400000;
                    cycle_B = 20'd400000;
                end else if(count_reg >= 27'd20000000 && !(sensLeft || sensRight)) begin
                    DirA = 0; DirB = 0;
                    cycle_A = 20'd800000;
                    cycle_B = 20'd800000;
                end else begin
                    DirA = 1; DirB = 0;
                    cycle_A = 20'd400000;
                    cycle_B = 20'd400000;
                end
            end
        end
        else if(SW0 && IPS1 == 0) begin
            //move = 1;
            cycle_A = 20'd500000;
            cycle_B = 20'd500000;
            DirA = 1;
        end
        else if(SW0 && IPS2 == 0) begin
            //move = 2;
            cycle_A = 20'd500000;
            cycle_B = 20'd500000;
            DirB = 1;
        end
        else begin
            cycle_A = 20'd0;
            cycle_B = 20'd0;
            in0 = 11;
            in1 = 11;
            in2 = 0;
            in3 = 14;
        end    
*/
     end    
    //Movement State Machine Case
    always @* begin
        state_next = State_Idle;
        count_next = count_reg;
        
        case(state_reg)
            State_Idle: begin
                if(SW0) begin
                    if(ReadEn == 0) begin
                        state_next = State_Reading;
                        count_next = 30'd500000000;
                    end
                    else
                    state_next = State_Forward;
                    in0 = 1;
                    in1 = 1;
                    in2 = 14;
                    in3 = 14;
                end else begin
                    state_next = State_Idle;
                    cycle_A = 20'd0;
                    cycle_B = 20'd0;
                    in0 = 11;
                    in1 = 11;
                    in2 = 0;
                    in3 = 14;
                end
            end
            State_Reading: begin
                count_next = count_reg - 1;
                DirA = 0; DirB = 0;
                cycle_A = 20'd300000;
                cycle_B = 20'd300000;
                in0 = 14;
                in1 = 14;
                in2 = 14;
                in3 = 14;
                if(count_reg == 0) begin
                    state_next = State_Idle;
                    ReadEn = 1;
                end
                else
                    state_next = State_Reading;
            end
            State_Forward: begin
                DirA = 0; 
                DirB = 0;
                cycle_A = 20'd800000;
                cycle_B = 20'd800000;
                if(sensLeft && sensRight) begin
                    count_next = 28'd400000000; // total time for the pivot state to work with
                    state_next = State_Pivot; // calls what the next state will be next clock cycle
                end else if(sensLeft) begin
                    count_next = 28'd150000000; // total turn time for the state
                    state_next = State_Right; // calls what the next state will be next clock cycle
                end else if(sensRight) begin
                    count_next = 28'd150000000; // total turn time for the state
                    state_next = State_Left;  // calls what the next state will be next clock cycle
                end else if(SW0)
                    state_next = State_Forward;
                else
                    state_next = State_Idle;
            end
            State_Left: begin
                count_next = count_reg - 1;
                if(count_reg ==  0) begin
                    state_next  = State_Idle;
                end else begin
                    DirA = 0; DirB = 1;
                    cycle_A = 20'd800000;
                    cycle_B = 20'd800000;
                    state_next = State_Left;
                end    
            end
            State_Right: begin
                count_next = count_reg - 1;
                if(count_reg ==  0) begin
                    state_next  = State_Idle;
                end else begin
                    DirA = 1; DirB = 0;
                    cycle_A = 20'd800000;
                    cycle_B = 20'd800000;
                    state_next = State_Right;
                end    
            end
            State_Pivot: begin
                count_next = count_reg - 1;
                state_next = State_Pivot;
                if(count_reg == 0) begin
                    state_next = State_Idle;
                end else if(count_reg >= 28'd200000000) begin
                    DirA = 1; DirB = 1;
                end else if(count_reg >= 28'd0) begin
                    DirA = 1; DirB = 0;
                    cycle_A = 20'd800000;
                    cycle_B = 20'd800000;
                end /*else if(count_reg >= 28'd75000000 && !(sensLeft || sensRight)) begin
                    DirA = 0; DirB = 0;
                    cycle_A = 20'd800000;
                    cycle_B = 20'd800000;
                end else begin
                    DirA = 1; DirB = 0;
                    cycle_A = 20'd800000;
                    cycle_B = 20'd800000;
                end */
            end
            State_Color: begin
                
            end
        endcase
    end   
    //  Seven Segment Diplay Cases
    always @ (*) begin
        case(counter1[N-1:N-2])
            2'b00  :begin
                sseg = in0;
                an_temp = 4'b1110;
            end
            2'b01  :begin
                sseg = in1;
                an_temp = 4'b1101;
            end
            2'b10 :begin
                sseg = in2;
                an_temp = 4'b1011;
            end
            2'b11 :begin
                sseg = in3;
                an_temp = 4'b0111;
            end
        endcase
        
        case(sseg)
            4'd0 : sseg_temp = 7'b1000000; // display 0
            4'd1 : sseg_temp = 7'b1111001; // display 1
            4'd2 : sseg_temp = 7'b0100100; // display 2
            4'd3 : sseg_temp = 7'b0110000; // display 3
            4'd4 : sseg_temp = 7'b0011001; // display 4
            4'd5 : sseg_temp = 7'b0010010; // display 5
            4'd6 : sseg_temp = 7'b0000010; // display 6
            4'd7 : sseg_temp = 7'b1111000; // display 7
            4'd8 : sseg_temp = 7'b0000000; // display 8
            4'd9 : sseg_temp = 7'b0010000; // display 9
            4'd10 : sseg_temp = 7'b0000011; // dislplay b
            4'd11 : sseg_temp = 7'b0001110; // display F
            4'd12 : sseg_temp = 7'b1000111; // display L
            4'd13 : sseg_temp = 7'b0101111; // display r
                default : sseg_temp = 7'b0111111; // display -
        endcase
    end
    
    assign an = an_temp;
    assign {g, f, e, d, c, b, a} = sseg_temp;
    assign ENA = PWM_A;
    assign ENB = PWM_B;
    assign FwA = !DirA;
    assign BkA = DirA;
    assign FwB = !DirB;
    assign BkB = DirB;
endmodule

module color_count_compare(S0, S1, S2, S3,/* L0, L1, L2, L3,*/ sensorOUT, clock100);
    
    input clock100;
    input sensorOUT;
    
    output S0;
    output S1;
    output S2;
    output S3;
    
    //wire L0, L1, L2, L3;
    
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
        //assign L0 = temp_color[3];
        //assign L1 = temp_color[0];
        //assign L2 = temp_color[1];
        //assign L3 = temp_color[2]; 
    end
   
    assign S0 = temp_S[0];
    assign S1 = temp_S[1];
    assign S2 = temp_S[2];
    assign S3 = temp_S[3]; 
endmodule

module servo_control(SW2, pwmOUT, clock100);
    input SW2;
    input clock100;
    
    output pwmOUT;
    
    reg clock25;
    reg [20:0] COUNTER;
    reg [7:0] servotimer;
    reg [1:0] servopwm;
    reg [6:0] ClkCount;
    reg ClkTick;
    reg [11:0] PulseCount;
    
    parameter COUNT = 4'd3;
    parameter ClkDiv = 98;
    
    wire switch;
    
    assign switch = SW2;
    
    initial begin
        COUNTER = 21'd0;
    end
    
    always@(posedge clock100)begin          //Converts 100MHz clock to 25MHz clock
        if(COUNTER == COUNT)
        begin
            clock25 = 1;
            COUNTER <= 21'd0;
        end
        else
        begin
            COUNTER <= COUNTER + 1;
            clock25 = 0;            
        end
    end
    
    always@(posedge clock25)begin           //Next two always setup ClkTick with tick period of 1ms/256 = 3.9us
        ClkTick <= (ClkCount==ClkDiv-2);
    end
    
    always@(posedge clock25)begin
        if(ClkTick)begin
            ClkCount <= 0;
        end
        else begin
            ClkCount <= ClkCount + 1;
        end
    end
    
    always@(posedge clock25)begin           //Every 256 ticks/1ms, PulseCount increases by 1. PulseCount rolls-over every 16ms, which is close enough to SG90 period of 20ms.
        if(ClkTick)begin
            PulseCount <= PulseCount + 1;
        end            
    end
    
    always@(posedge clock25)begin           //Sets duty cycle depending on input
        if(switch)begin
            servotimer = 8'd255;  
        end
        else begin
            servotimer = 8'd00;
        end
    end
        
    always@(posedge clock25)begin                       //Each pulse starts when PulseCount = 0, ends when PulseCount is between 256 and 511.
        servopwm = (PulseCount < {4'b0001, servotimer});//0001 is concatenated in front of servotimer, so servotimer is conveted from 0-255 to 256-511.    
    end                                                 //Value between 256-511 determines duty cycle.
        
    assign pwmOUT = ~servopwm[0]; //Since a BJT inverter is used to convert the 3.3v output to 5v, the signal must be inverted to counteract the bjt inverter.    
endmodule