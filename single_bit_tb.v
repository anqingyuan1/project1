`timescale 1ns/1ps

module tb;

    reg  rst;
    reg  clk_slow;
    reg  clk_fast;
    reg  data_from_fast;
    wire data_to_slow;
    wire ack;

    parameter clk_slow_cycle = 10;
    parameter clk_fast_cycle = 3;
initial begin 
    rst = 1'b1;
    clk_slow = 1'b1;
    clk_fast = 1'b1;
    data_from_fast = 1'b0;
end

initial begin 
    forever #clk_slow_cycle clk_slow = ~clk_slow;
end

initial begin 
    forever #clk_fast_cycle clk_fast = ~clk_fast;
end

initial begin 
    #100
    rst = 1'b0;
    #100
    data_from_fast = 1'b0;
    @(posedge clk_fast)
    data_from_fast = 1'b1;
    repeat(50)@(posedge clk_fast)
    data_from_fast = 1'b0;

    @(posedge clk_fast)
    data_from_fast = 1'b1;
    @(posedge clk_fast)
    data_from_fast = 1'b0;
    @(negedge ack)
    data_from_fast = 1'b1;
    @(posedge clk_fast)
    data_from_fast = 1'b0;
end

handshake u_handshake(
    .rst            ( rst            ),
    .clk_fast       ( clk_fast       ),
    .clk_slow       ( clk_slow       ),
    .data_from_fast ( data_from_fast ),
    .data_to_slow   ( data_to_slow   ),
    .ack            ( ack            )
);

endmodule
