`timescale 1ns/1ps
module top(
    input                   sysclk,
    input                   rst_n,
    input                   key1,
    input                   key2,
    output  reg     [3:0]   led
    );
    wire key_flag1;
    wire key_flag2;
    reg[3:0]    led_water;
    reg[3:0]    led_jump;
    reg[31:0]   timer;
	reg[31:0]	timedelay;	//计时0.5s  1s  2s   5s
	reg[2:0]	dt;	// 时间档位
	
	parameter IDLE  = 2'd0,//空闲状态
              WATER = 2'd1,//流水灯状态
              JUMP  = 2'd2;//跳转灯状态
	
	reg [1:0] cur_state;//当前状态
    reg [1:0] next_state;//下一状态
    
    // 按键消抖实例化
    key key_1(
        .sysclk     (sysclk),
        .rst_n      (rst_n),
        .key        (key1),
        .key_flag   (key_flag1)
    );
        
    key key_2(
        .sysclk     (sysclk),
        .rst_n      (rst_n),
        .key        (key2),
        .key_flag   (key_flag2)
    );
	
	//计时
    always@(posedge sysclk)
        if(!rst_n)
            timer <= 32'd0;
        else if(timer >=timedelay-32'd1)
            timer <= 32'd0;
        else
            timer <= timer + 32'd1;
    
    //流水灯
    always@(posedge sysclk)
        if(!rst_n)
            led_water <= 4'b0001;
        else if(timer >= timedelay-1 && cur_state == WATER)
            led_water <= {led_water[2:0],led_water[3]};
        else
            led_water <= led_water;
     
     //跳转灯
    always@(posedge sysclk)
        if(!rst_n)
            led_jump <= 4'b1010;
        else if(timer >= timedelay-1 && cur_state == JUMP)
            led_jump <= ~led_jump;
        else
            led_jump <= led_jump;
	
	/* state1 状态切换，时序逻辑 */
    always@(posedge sysclk)
        if(!rst_n)
            cur_state <= IDLE;
        else
            cur_state <= next_state;
	
	/* state2(根据当前状态和条件确定下一状态，组合逻辑) */
	always@(posedge key_flag1)begin
		next_state = IDLE;
		case(cur_state)
		IDLE:begin
			if(key_flag1)
				next_state = WATER;
			end
		WATER:begin
			if(key_flag1)
				next_state = JUMP;
            end
        JUMP:begin
			if(key_flag1)
				next_state = WATER;
            end
		default:next_state = IDLE;
		endcase
	end
	
	/* state3(根据状态确定输出，时序逻辑) */      
    always@(posedge sysclk)
        if(!rst_n)begin
            led <= 4'b0000;
            dt <= 3'd0;
        end
        else begin
            case(next_state)
                IDLE:begin
                    led <= led;
                    dt <= 3'd0;
                end
                
                WATER:begin
                    led <= led_water;
                    if(key_flag2)
                        if(dt >= 3'd3)
                            dt <= 3'd0;
                        else
                            dt <= dt + 1;
                    else
                        dt <= dt;
                end
                
                JUMP:begin
                    led <=  led_jump;
                    if(key_flag2)
                        if(dt >= 3'd3)
                            dt <= 3'd0;
                        else
                            dt <= dt + 1;
                    else
                        dt <= dt;
                end
                
                default:led <= led;
            endcase
            case(dt)
            3'd0:begin
                timedelay<= 32'd62_500_000;
                end
            3'd1:begin
                timedelay<= 32'd125_000_000;
                end
            3'd2:begin
                timedelay<= 32'd250_000_000;
                end
            3'd3:begin
                timedelay<= 32'd625_000_000;
                end
            default:timedelay <= 32'd62_500_000;
            endcase
		end
endmodule
