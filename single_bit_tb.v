`timescale 1ns/1ps

module tb;

    reg  clk_slow;
    reg  clk_fast;
    reg  data_from_slow;
    wire data_to_fast;

    parameter clk_slow_cycle = 10;
    parameter clk_fast_cycle = 3;
initial begin 
    clk_slow = 1'b1;
    clk_fast = 1'b1;
    data_from_slow = 1'b0;
end

initial begin 
    forever #clk_slow_cycle clk_slow = ~clk_slow;
end

initial begin 
    forever #clk_fast_cycle clk_fast = ~clk_fast;
end

initial begin 
    #200
    data_from_slow = 1'b0;
    @(posedge clk_slow)
    data_from_slow = 1'b1;
    @(posedge clk_slow)
    data_from_slow = 1'b0;
end

slow2fast_EdgeDetect u_slow2fast_EdgeDetect(
    .clk_slow       ( clk_slow       ),
    .clk_fast       ( clk_fast       ),
    .data_from_slow ( data_from_slow ),
    .data_to_fast   ( data_to_fast   )
);

endmodule

