// Daniel Oosterwijk & Tyler Marriner
// University of Waikato, 2018

`timescale 1ns / 1ps

module clock_scaler(
    input in,
    output reg out
    );
    
    reg [14:0] current;
    
	//(SHOULD run at 2400Hz but rounding means 2400.153609831Hz)
    parameter load_value = 1302; //6.25MHz / 2400 Hz, rounded and divided by 2 as 2 pulses is one clock cycle
    initial begin
        current = load_value;
        out = in;
    end
    
    always @(posedge in) begin
        current = current - 1;
        if (current == 0) begin
            out = ~out;
            current = load_value;
        end
    end
    
endmodule
