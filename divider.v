`timescale 1ns/1ps
module div_M_N(
 input  wire clk_in,
 input  wire rst,
 output wire clk_out
);
// parameter M_N = 8'd22; 
// parameter c89 = 8'd16; // 2/3时钟切换点
// parameter div_e = 4'd2; //偶数周期
// parameter div_o = 4'd3; //奇数周期
// //*************code***********//

// reg[7:0]clk_count;
// reg[7:0]cnt;

// always @(posedge clk_in, negedge rst) begin
//     if(rst == 0)begin
//         clk_count <= 0;
//     end
//     else begin
//         clk_count <= clk_count==M_N-1 ? 0 : clk_count+1; 
//     end
// end

// wire div_class = clk_count < c89 ? 1 : 0;

// always @(posedge clk_in, negedge rst) begin
//     if(rst == 0)begin
//         cnt <= 0;
//     end
//     else if(div_class)begin
//         cnt <= cnt==(div_e-1) ? 0 : cnt+1;
//     end
//     else begin
//         cnt <= cnt==(div_o-1) ? 0 : cnt+1; 
//     end
// end

// reg clk_out_r;
// always @(posedge clk_in, negedge rst) begin
//     if(rst == 0)begin
//         clk_out_r <= 0;
//     end
//     else if(div_class)begin
//         clk_out_r <= (cnt < div_e>>1) ? 1 : 0;
//     end
//     else begin
//         clk_out_r <= (cnt < div_o>>1) ? 1 : 0;
//     end
// end

// assign clk_out = clk_out_r;
parameter M_N = 8'd22; 
parameter c89 = 8'd18; // 2/4时钟切换点
parameter div_e = 4'd2; //偶数周期
parameter div_o = 4'd4; //奇数周期
//*************code***********//

reg[7:0]clk_count;
reg[7:0]cnt;

always @(posedge clk_in, negedge rst) begin
    if(rst == 0)begin
        clk_count <= 0;
    end
    else begin
        clk_count <= clk_count==M_N-1 ? 0 : clk_count+1; 
    end
end

wire div_class = clk_count < c89 ? 1 : 0;

always @(posedge clk_in, negedge rst) begin
    if(rst == 0)begin
        cnt <= 0;
    end
    else if(div_class)begin
        cnt <= cnt==(div_e-1) ? 0 : cnt+1;
    end
    else begin
        cnt <= cnt==(div_o-1) ? 0 : cnt+1; 
    end
end

reg clk_out_r;
always @(posedge clk_in, negedge rst) begin
    if(rst == 0)begin
        clk_out_r <= 0;
    end
    else if(div_class)begin
        clk_out_r <= (cnt < div_e>>1) ? 1 : 0;
    end
    else begin
        clk_out_r <= (cnt < div_o>>1) ? 1 : 0;
    end
end

assign clk_out = clk_out_r;

endmodule

