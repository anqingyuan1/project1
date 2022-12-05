`timescale 1ns/1ps
module div_M_N_tb(
 
);

reg clk_in;
reg rst;
wire clk_out;

initial begin
    clk_in <= 0;
    rst <= 0;

    #20 rst <= 1;
end

always begin
    #5 clk_in <= ~clk_in;
end

div_M_N dut(
    .clk_in(clk_in),
    .rst(rst),
    .clk_out(clk_out)
);

endmodule