`timescale 1ns/1ps

module wptr_wfull #(
                               parameter ADDRSIZE=4)
(  
 input                                        winc,
 input                                        wclk,
 input                                        wrst_n,
 input         [ADDRSIZE:0]                   wq2_rptr,
 output reg                                   wfull,
 output reg    [ADDRSIZE:0]                   wptr,
 output        [ADDRSIZE-1:0]                 waddr
 );
 wire              full_value;
 wire [ADDRSIZE:0] wbinnext , wgraynext;
 reg  [ADDRSIZE:0] wbin;
  //写地址产生     
  assign wbinnext=wbin+(winc&!wfull);                                              
  always@(posedge wclk or negedge wrst_n)  
  begin
           if(wrst_n==1'b0) 
                wbin<=0;           
           else
               wbin<=wbinnext;        
  end
  assign waddr=wbin[ADDRSIZE-1:0];        
  
  //写指针产生    
  assign wgraynext=wbinnext^(wbinnext>>1);
  always @(posedge wclk or negedge wrst_n) 
  begin
           if(wrst_n==1'b0)
                 wptr <=0;
           else
                 wptr<=wgraynext;
  end
  
  //满信号产生
  assign  full_value=wgraynext == ({~wq2_rptr[ADDRSIZE:ADDRSIZE-1],wq2_rptr[ADDRSIZE-2:0]});
  always@(posedge wclk or negedge wrst_n)
  begin
       if(wrst_n==1'b0)
           wfull<=1'b0;
      else
          wfull<=full_value; 
 end
 endmodule

 module rptr_rempty #(
                               parameter ADDRSIZE=4)
(  
input                                        rinc,
input                                        rclk,
input                                        rrst_n,
input        [ADDRSIZE:0]                    rq2_wptr,
output reg                                   rempty,
output reg   [ADDRSIZE:0]                    rptr,
output       [ADDRSIZE-1:0]                  raddr
);
wire empty_value;
wire [ADDRSIZE:0] rbinnext , rgraynext;
reg  [ADDRSIZE:0] rbin;

//读地址产生     
assign rbinnext=rbin+(rinc&!rempty);
always@(posedge rclk or negedge rrst_n)                   
begin
        if(rrst_n ==1'b0)                   
            rbin <=0;            
        else
            rbin <=rbinnext;        
end
assign raddr=rbin[ADDRSIZE-1:0];

//读指针产生    
 assign rgraynext=rbinnext^(rbinnext>>1);
 always@(posedge rclk or negedge rrst_n)
 begin
         if(rrst_n ==1'b0)           
             rptr <=0; 
         else
             rptr<=rgraynext;
  end
              
//空信号产生
assign  empty_value=rgraynext == rq2_wptr;
always@(posedge rclk or negedge rrst_n)
begin
      if(rrst_n==1'b0)
         rempty<=1'b0;
      else
         rempty<=empty_value; 
end
endmodule

module sync_r2w #(
                    parameter ADDRSIZE=4)
                  (  
                        input                       wclk,
                        input                       wrst_n,
                        input       [ADDRSIZE:0]    rptr,
                        output reg  [ADDRSIZE:0]    wq2_rptr
            );
            
reg [ADDRSIZE:0] wq1_rptr;
always@(posedge wclk or negedge wrst_n)
begin
     if(wrst_n==1'b0)
                       {wq2_rptr, wq1_rptr}<=2'b0;
     else
                       {wq2_rptr, wq1_rptr}<= {wq1_rptr, rptr} ;       
 end
 endmodule

module sync_w2r #(
                           parameter ADDRSIZE=4)
                 (  
                    input                                    rclk,
                    input                                    rrst_n,
                    input         [ADDRSIZE:0]               wptr,
                    output reg    [ADDRSIZE:0]               rq2_wptr
                   );
reg [ADDRSIZE:0] rq1_wptr;
always@(posedge rclk or negedge rrst_n)
begin
      if(rrst_n==1'b0)
         {rq2_wptr, rq1_wptr}<=2'b0;
      else
         {rq2_wptr, rq1_wptr}<= {rq1_wptr, wptr};       
end
endmodule

module fifomem #(
                      parameter ADDRSIZE=4,
                      parameter DATASIZE=8)
(
   input                                   winc,
   input                                   wclk,
   input                                   wfull,
   input   [ADDRSIZE-1:0]   waddr , raddr,
   input   [DATASIZE-1:0]   wdata ,  
   output  [DATASIZE-1:0]   rdata
  );
  localparam DEPTH=1<<ADDRSIZE;
  reg [DATASIZE-1:0] mem [0:DEPTH-1];
  assign rdata=mem[raddr];
  always@(posedge wclk)
  begin
           if(! wfull & winc)
                             mem[waddr]<= wdata;
  end
endmodule


 module afifo #(
                parameter ADDRSIZE=4,
                parameter DATASIZE=8)
               (
                  input   wclk,
                  input   rclk,
                  input   wrst_n,
                  input   rrst_n,
                  input   winc,
                  input   rinc,
                 input    [DATASIZE-1:0]  wdata,
                 
                 output   [DATASIZE-1:0]  rdata,
                 
                 output   rempty,
                 output   wfull
                );
        wire [ ADDRSIZE:0] wq2_rptr;
        wire [ ADDRSIZE:0] wptr;
        wire [ ADDRSIZE-1:0] waddr;
        
        wire [ ADDRSIZE:0] rq2_wptr;
        wire [ ADDRSIZE:0] rptr;
        wire [ ADDRSIZE-1:0] raddr;
        
         wptr_wfull u1(
                       .winc(winc),
                       .wclk(wclk),
                       .wrst_n(wrst_n),
                       .wq2_rptr(wq2_rptr),
                       .wfull(wfull),
                       .wptr(wptr),
                       .waddr(waddr)
                       );
        rptr_rempty u2(  
                       .rinc(rinc),
                       .rclk(rclk),
                       .rrst_n(rrst_n),
                       .rq2_wptr(rq2_wptr),
                       .rempty(rempty),
                       .rptr(rptr),
                       .raddr(raddr)
                );
          sync_r2w  u3(  
                        .wclk(wclk),
                        .wrst_n(wrst_n),
                        .rptr(rptr),
                        .wq2_rptr(wq2_rptr)
               );
          sync_w2r u4(
                        .rclk(rclk),
                        .rrst_n(rrst_n),
                        .wptr(wptr),
                        .rq2_wptr(rq2_wptr)
               );
          fifomem u5(
                        .winc(winc),
                        .wclk(wclk),
                        .wfull(wfull),
                        .waddr(waddr), 
                        .raddr(raddr),
                        .wdata(wdata),  
                        .rdata(rdata)
               );
          
  endmodule
