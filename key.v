`timescale 1ns/1ps
module key(
    input           sysclk,
    input           rst_n,
    input           key,
    output          reg key_flag
    );
    parameter DELAY = 250_000_0;//计时20ms
    reg[31:0] cnt;
    
    //------------计时模块-----------------------
    always@(posedge sysclk)
        if(!rst_n)
            cnt <= 32'd0;
        else if(key)begin
            if(cnt >= DELAY)
                cnt <= cnt;
            else
                cnt <= cnt +32'd1;
        end
        else
            cnt = 32'd0;
     //------------------key_falg------------------------
     always@(posedge sysclk)
        if(!rst_n)
            key_flag <= 0;
        else if(cnt == DELAY-1)
            key_flag <= 1;
        else
            key_flag <= 0;      
            
endmodule

