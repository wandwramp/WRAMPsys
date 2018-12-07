// Daniel Oosterwijk & Tyler Marriner
// University of Waikato, 2018

`timescale 1ns / 1ps

module tb();

    reg clk = 0;
    always #5 clk = ~clk; //100MHz
    reg [15:0] sw = 16'h8000;
    wire [15:0] led;
    reg [4:0] buttons = 0;
    wire [7:0] seg;
    wire [3:0] an;
    reg Rx = 1;
    wire Tx;
    reg Rx2 = 1;
    wire Tx2;
    
    wramp_wrapper wramp(
        clk,
        sw,
        led,
        buttons,
        seg,
        an,
        Tx,
        Rx,
        Tx2,
        Rx2
    );

endmodule
