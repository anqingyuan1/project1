`timescale 1ns/1ps

  module afifo_tb();
  reg        wclk;
  reg        rclk;
  reg        wrst_n;
  reg        rrst_n;
  reg        winc;
  reg        rinc;
  reg  [7:0] wdata;
  wire [7:0] rdata;
  wire       rempty;
  wire       wfull;
  
afifo u6(
         .wclk(wclk),
         .rclk(rclk), 
         .wrst_n(wrst_n),
         .rrst_n(rrst_n),
         .winc(winc),
         .rinc(rinc),
         .wdata(wdata),
         .rdata(rdata),
         .rempty(rempty),
         .wfull(wfull)
);
                       
initial begin                    //设置写时钟，写周期是20ns，50Mhz
                   wclk=0;
                   forever    #10     wclk=~wclk;
          end
          
initial begin                    //设置读时钟，读周期是10ns，100Mhz
                   rclk=0;
                   forever    #5      rclk=~rclk;
          end
          
initial begin
                 
wrst_n=1'b0;     //写复位
rrst_n=1'b0;     //读复位
winc =1'b0;     //写无效
rinc =1'b0;     //读无效
wdata=0;        //初始写数据为0
                           
#28     wrst_n=1'b1;    //松开写复位
rrst_n=1'b1;    //松开读复位
winc =1'b1;     //写有效
wdata=1;        //输入数据为1
@(posedge wclk);//写入数据     

    repeat(7)       //接着写入2，3，4，5，6，7，8这些数据
        begin
            #18;
            wdata=wdata+1'b1;
            @(posedge wclk);  
        end
        #18    wdata=wdata+1'b1;  //此时异步FIFO已经写满了，在往同步FIFO中写数据8
                                     //8这个数据不会被写进
                            
        @(posedge rclk);   
                                
        #8  rinc=1'b1;      //读使能，写无效 
            winc=1'b0;
        @(posedge rclk);     //第一个读出的数为1
            repeat(7)        //读取剩余的数
            begin
            @(posedge rclk);   
            end
            #2;
            rinc=1'b0;        //结束读操作
                                    
        end    
endmodule

