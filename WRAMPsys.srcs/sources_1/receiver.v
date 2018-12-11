// Daniel Oosterwijk & Tyler Marriner
// University of Waikato, 2018

`timescale 1ns / 1ps

module receiver(
    	input rst_n,
    	input clk,
		output reg [7:0] RxD,
		input [10:0] ctrl,
		input startRx,
		output reg finished,
    	input  Rx,
    	output reg parityErr,
    	output reg frammingErr,
    	input [14:0] baudRate
    );
    
    //statenames
    parameter idle 			=  0;  		//uses one-hot encoding 
	parameter start 		=  1;
    parameter Data0 		=  2;
    parameter Data1 		=  4;
    parameter Data2 		=  8;
    parameter Data3 		=  16;
    parameter Data4 		=  32;
    parameter Data5 		=  64;
    parameter Data6 		=  128;
    parameter Data7 		=  256;
    parameter EvenParity 	=  512;
    parameter OddParity 	=  1024;
    parameter firstStopBit 	=  2048;
    parameter secondStopBit =  4096;
    parameter errState 		=  8192;
    	
		
	reg [14:0] next_counter, counter; //19 bits counter to count the baud rate, counter = clock / baud rate
		
	reg [14:0] RXstate,next_RXstate,RXafterDataState, next_RXafterDataState; // initial & next state variable

	reg [7:0] next_RxD;
	reg next_finished, next_parityErr, next_frammingErr, EvenParityBit, next_EvenParityBit;
	
	always @ (posedge clk) begin
		if(~rst_n) begin			
			counter <= 0; // counter for baud rate is reset to 0 
			RXstate <= idle; // state is idle (state = 0)			
			RxD <= 0;
			finished <= 0;			
			frammingErr <= 0;
			parityErr <= 0;
			RXafterDataState <= firstStopBit;
		end
		else begin
			counter <= next_counter; 
			RXstate <= next_RXstate;
			RxD <= next_RxD;
			finished <= next_finished;		
			frammingErr <= next_frammingErr;
			parityErr <= next_parityErr;
			EvenParityBit <= next_EvenParityBit;
			RXafterDataState <= next_RXafterDataState;
		end

	end

	//UART receive logic
	always @(*) begin 		
		next_RXstate = RXstate;
		
		next_RxD = RxD;
		next_finished = 0;
		
		next_frammingErr = frammingErr;
		next_parityErr = parityErr;

		casez (ctrl[5:4])		//weather to have a parity bit or not		
			2'b10: begin
				next_RXafterDataState = EvenParity;
			end
			
			2'b11 : begin
				next_RXafterDataState = OddParity;
			end
			
			2'b0Z : begin //no parity				
				next_RXafterDataState = firstStopBit;
			end
		endcase		
		
		next_counter = counter + 1; //counter for baud rate generator start counting 

		if (counter >= baudRate) begin //fixed cycle of data rate
			next_counter = 5; 
			// reset couter to 5 to reduce time per byte, ensures reciever is NEVER slower than recieving byte
		end 
		
        case(RXstate) 
            idle: begin
                next_counter = baudRate >> 1; //only sit in the first data bit for half the time
				//(the counter starts halfway when the next clk comes around, the other states depend on this
				//counter excedding the baudrate but IDLE does not)
				
				next_frammingErr = 0;
				next_parityErr = 0;

                if (Rx == 0) begin
                    next_RXstate = start;
                end
                else begin
                    next_RXstate = idle;
                end
            end

            start: begin            
                if (counter >= baudRate) begin 
                    next_RXstate = Data0;
    
                    next_EvenParityBit = 0;
                    next_RxD = 8'hxx; //xx for debugging in sim purposes, same as 00 for synth but looks differnt in sim
                end                
            end

            Data0: begin
                if (counter >= baudRate) begin 
                    next_RxD[0] = Rx;
                    next_EvenParityBit = EvenParityBit ^ Rx;
                    next_RXstate = Data1;
                end
            end

            Data1: begin
                if (counter >= baudRate) begin 
                    next_RxD[1] = Rx;
                    next_EvenParityBit = EvenParityBit ^ Rx;    
                    next_RXstate = Data2;
                end
            end

            Data2: begin
                if (counter >= baudRate) begin 
                    next_RxD[2] = Rx;
                    next_EvenParityBit = EvenParityBit ^ Rx;    
                    next_RXstate = Data3;
                end
            end

            Data3: begin
                if (counter >= baudRate) begin 
                    next_RxD[3] = Rx;
                    next_EvenParityBit = EvenParityBit ^ Rx;    
                    next_RXstate = Data4;
                end
            end

            Data4: begin
                if (counter >= baudRate) begin 
                    next_RxD[4] = Rx;
                    next_EvenParityBit = EvenParityBit ^ Rx;
    
                    if (ctrl[7:6] != 2'b00) begin //if only 5bits to transmit
                        next_RXstate = Data5;
                    end	else begin
                        next_RXstate = RXafterDataState;
                    end
                end		
            end

            Data5: begin
                if (counter >= baudRate) begin 
                    next_RxD[5] = Rx;
                    next_EvenParityBit = EvenParityBit ^ Rx;
    
                    if (ctrl[7:6] != 2'b01) begin //if only 6bits to transmit
                        next_RXstate = Data6;
                    end
                    else begin
                        next_RXstate = RXafterDataState;
                    end
                end
            end

            Data6: begin
                if (counter >= baudRate) begin 
                    next_RxD[6] = Rx;
                    next_EvenParityBit = EvenParityBit ^ Rx;
    
                    if (ctrl[7:6] != 2'b10) begin //if only 7bits to transmit
                        next_RXstate = Data7;
                    end
                    else begin
                        next_RXstate = RXafterDataState;
                    end
                end
            end

            Data7: begin
                if (counter >= baudRate) begin 
                    next_RxD[7] = Rx;
                    next_EvenParityBit = EvenParityBit ^ Rx;    
                    next_RXstate = RXafterDataState;
                end
            end

            EvenParity: begin
                if (counter >= baudRate) begin 
                    if (Rx != EvenParityBit) begin
                        next_parityErr = 1;
                    end
    
                    next_RXstate = firstStopBit;
                end
            end
            
            OddParity: begin
                if (counter >= baudRate) begin 
                    if (Rx != ~EvenParityBit) begin
                        next_parityErr = 1;
                    end
    
                    next_RXstate = firstStopBit;
                end
            end

            firstStopBit: begin
                if (counter >= baudRate) begin 
                    if (Rx != 1) begin 
                        next_frammingErr = 1;
                    end 
    
                    if(ctrl[3] == 1'b1) begin
                        next_RXstate = secondStopBit;
                    end else begin
                        next_finished = 1;
                        next_RXstate = idle;
                    end
                end
            end

            secondStopBit: begin
                if (counter >= baudRate) begin 
                    if (Rx != 1) begin 
                        next_frammingErr = 1;
                    end
                    
                    next_finished = 1;
    
                    if (Rx == 0) begin
                        next_RXstate = Data0;
                    end
                    else begin
                        next_RXstate = idle;
                    end
                end
            end			
        endcase
	end 
endmodule