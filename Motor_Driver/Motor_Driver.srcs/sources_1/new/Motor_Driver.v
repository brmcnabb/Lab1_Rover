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
    input CLK, SW0, IPS1, IPS2,
    output ENA, ENB, FwA, BkA, FwB, BkB, a, b, c, d, e, f, g, [3:0]an
);
    localparam N = 17;
    localparam refresh = 19; // this is the bit size of the counter + 1 needed for the PWM counter
    localparam [2:0]
        State_Idle = 3'd0,
        State_Forward = 3'd1,
        State_Left = 3'd2,
        State_Right = 3'd3,
        State_Pivot = 3'd4;
    reg [2:0] state_reg = State_Idle, state_next;
    reg [27:0] count_reg = 0, count_next;    
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
    reg DirA, DirB, sensLeft, sensRight;
    
    initial begin
        DirA = 0;
        DirB = 0;
        PWM_A = 0;
        PWM_B = 0;
        cycle_A = 0;
        cycle_B = 0;
        Counter = 0;
        in0 = 0;
        in1 = 0;
        in2 = 0;
        in3 = 0;
        counter1 = 0;
        sseg = 0;
        an_temp = 0;
        sseg_temp = 0;
    end
    
    always@(posedge CLK) begin
        sensLeft = !IPS1;
        sensRight = !IPS2;
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
            State_Forward: begin
                DirA = 0; 
                DirB = 0;
                cycle_A = 20'd800000;
                cycle_B = 20'd800000;
                if(sensLeft && sensRight) begin
                    count_next = 28'd250000000; // total time for the pivot state to work with
                    state_next = State_Pivot; // calls what the next state will be next clock cycle
                end else if(sensLeft) begin
                    count_next = 28'd250000000; // total turn time for the state
                    state_next = State_Right; // calls what the next state will be next clock cycle
                end else if(sensRight) begin
                    count_next = 28'd250000000; // total turn time for the state
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
                end else if(count_reg >= 28'd220000000) begin
                    DirA = 1; DirB = 1;
                end else if(count_reg >= 28'd125000000) begin
                    DirA = 1; DirB = 0;
                    cycle_A = 20'd800000;
                    cycle_B = 20'd800000;
                end else if(count_reg >= 28'd75000000 && !(sensLeft || sensRight)) begin
                    DirA = 0; DirB = 0;
                    cycle_A = 20'd800000;
                    cycle_B = 20'd800000;
                end else begin
                    DirA = 1; DirB = 0;
                    cycle_A = 20'd800000;
                    cycle_B = 20'd800000;
                end
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
