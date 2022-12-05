`timescale 1ns/1ps

module PulseSync(
    input  wire     rst,
    input  wire     clk_out,
    input  wire     clk_in,
    input  wire     data_in,
    output wire     data_out
    );

    reg  toggle_reg;
    reg  sync_reg1;
    reg  sync_reg2;
    reg  edge_detect_reg;


    always@(posedge clk_in, posedge rst) begin 
        if(rst) begin 
            toggle_reg <= 1'b0;
        end
        else begin
            toggle_reg <= (data_in)? ~toggle_reg : toggle_reg;
        end
    end

    always@(posedge clk_out, posedge rst) begin 
        if(rst) begin 
            sync_reg1 <= 1'b0;
            sync_reg2 <= 1'b0;
        end
        begin 
            sync_reg1 <= toggle_reg;
            sync_reg2 <= sync_reg1;
        end
    end

    always@(posedge clk_out, posedge rst) begin 
        if(rst) begin 
            edge_detect_reg <= 1'b0;
        end
        begin 
            edge_detect_reg <= sync_reg2;
        end
    end
    
    assign data_out = sync_reg2 ^ edge_detect_reg;

endmodule

//顶层例化
module handshake(
    input  wire     rst,
    input  wire     clk_fast,
    input  wire     clk_slow,
    input  wire     data_from_fast,
    output wire     data_to_slow,
    output wire     ack
    );

PulseSync u_PulseSync_fast2slow(
    .rst     ( rst     ),
    .clk_out ( clk_slow ),
    .clk_in  ( clk_fast  ),
    .data_in ( data_from_fast ),
    .data_out  ( data_to_slow  )
);

PulseSync u_PulseSync_slow2fast(
    .rst     ( rst     ),
    .clk_out ( clk_fast ),
    .clk_in  ( clk_slow  ),
    .data_in ( data_to_slow ),
    .data_out  ( ack  )
);

endmodule
