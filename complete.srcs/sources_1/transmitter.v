// Daniel Oosterwijk & Tyler Marriner
// University of Waikato, 2018

`timescale 1ns / 1ps

module transmitter(
    	input rst_n,
    	input clk,
		input [7:0] TxD,
		input [10:0] ctrl,
		input startTx,
		output reg finished,
    	output reg Tx,
    	input [14:0] baudRate
    );
    
    //statenames
    parameter idle 			=  15;//F
	parameter start 		=  1;
    parameter Data0 		=  2;
    parameter Data1 		=  3;
    parameter Data2 		=  4;
    parameter Data3 		=  5;
    parameter Data4 		=  6;
    parameter Data5 		=  7;
    parameter Data6 		=  8;
    parameter Data7 		=  9;
    parameter EvenParity 	= 10;//A
    parameter OddParity 	= 11;//B
    parameter firstStopBit 	= 12;//C
    parameter secondStopBit = 13;//D
    parameter errState 		= 14;//E
    	
	
	//initial TxC = 0;
	
	reg [14:0] next_counter, counter; //19 bits counter to count the baud rate, counter = clock / baud rate
		
	reg [3:0] TXstate,next_TXstate,TXafterDataState, next_TXafterDataState; 
	// initial & next state variable

	reg next_Tx;
	reg next_finished, EvenParityBit, next_EvenParityBit;
	
	always @ (posedge clk) begin
		if(~rst_n) begin			
			counter <= 1; // counter for baud rate is reset to 0 
			TXstate <= idle; // state is idle (state = 0)			
			Tx <= 1;
			finished <= 0;			
			TXafterDataState <= firstStopBit;
		end
		else begin
			counter <= next_counter; 
			TXstate <= next_TXstate;
			Tx <= next_Tx;
			finished <= next_finished;		
			EvenParityBit <= next_EvenParityBit;
			TXafterDataState <= next_TXafterDataState;
		end

	end

	//UART transmission logic
	always @(*) begin 		
		next_TXstate = TXstate;
		
		next_Tx = Tx;
		next_finished = 0;

		casez (ctrl[5:4])				
			2'b10: begin
				next_TXafterDataState = EvenParity;
			end
			
			2'b11 : begin
				next_TXafterDataState = OddParity;
			end
			
			2'b0Z : begin //no parity				
				next_TXafterDataState = firstStopBit;
			end
		endcase		
		
		next_counter = counter + 1; //counter for baud rate generator start counting 

		if (counter >= baudRate) begin //fixed cycle of data rate
			next_counter = 1; // reset couter to 1
		end 
		
        case(TXstate) 
            idle: begin // idle state                
                if (startTx) begin
                    next_TXstate = start;
					next_counter = 1;
                end
                else begin
                    next_TXstate = idle;
                end
            end

            start: begin
            
                if (counter >= baudRate) begin 
                    next_TXstate = Data0;    
                    next_EvenParityBit = 0;
                    next_Tx = 0; //start bit
                end
                
            end

            Data0: begin
                if (counter >= baudRate) begin 
                    next_Tx = TxD[0];
                    next_EvenParityBit = EvenParityBit ^ TxD[0];
                    next_TXstate = Data1;
                end
            end

            Data1: begin
                if (counter >= baudRate) begin 
                    next_Tx = TxD[1];
                    next_EvenParityBit = EvenParityBit ^ TxD[1];
                    next_TXstate = Data2;
                end
            end

            Data2: begin
                if (counter >= baudRate) begin 
                    next_Tx = TxD[2];
                    next_EvenParityBit = EvenParityBit ^ TxD[2];
                    next_TXstate = Data3;
                end
            end

            Data3: begin
                if (counter >= baudRate) begin 
                    next_Tx = TxD[3];
                    next_EvenParityBit = EvenParityBit ^ TxD[3];
                    next_TXstate = Data4;
                end
            end

            Data4: begin
                if (counter >= baudRate) begin 
                    next_Tx = TxD[4];
                    next_EvenParityBit = EvenParityBit ^ TxD[4];
    
                    if (ctrl[7:6] != 2'b00) begin //if only 5bits to transmit
                        next_TXstate = Data5;
                    end	else begin
                        next_TXstate = TXafterDataState;
                    end
                end		
            end

            Data5: begin
                if (counter >= baudRate) begin 
                    next_Tx = TxD[5];
                    next_EvenParityBit = EvenParityBit ^ TxD[5];
    
                    if (ctrl[7:6] != 2'b01) begin //if the opcode number of bits is not 0x (6bits)
                        next_TXstate = Data6;
                    end
                    else begin
                        next_TXstate = TXafterDataState;
                    end
                end
            end

            Data6: begin
                if (counter >= baudRate) begin 
                    next_Tx = TxD[6];
                    next_EvenParityBit = EvenParityBit ^ TxD[6];
    
                    if (ctrl[7:6] != 2'b10) begin //if the opcode number of bits is not 0x (6bits)
                        next_TXstate = Data7;
                    end
                    else begin
                        next_TXstate = TXafterDataState;
                    end
                end
            end

            Data7: begin
                if (counter >= baudRate) begin 
                    next_Tx = TxD[7];
                    next_EvenParityBit = EvenParityBit ^ TxD[7];
    
                    next_TXstate = TXafterDataState;
                end
            end

            EvenParity: begin
                if (counter >= baudRate) begin 
                    next_Tx = EvenParityBit;    
                    next_TXstate = firstStopBit;
                end
            end
            
            OddParity: begin
                if (counter >= baudRate) begin 
                    next_Tx = ~EvenParityBit;    
                    next_TXstate = firstStopBit;
                end
            end

            firstStopBit: begin
                if (counter >= baudRate) begin 
					next_Tx = 1;
                    if(ctrl[3] == 1'b1) begin
                        next_TXstate = secondStopBit;
                    end else begin
                        next_finished = 1;
                        next_TXstate = idle;
                    end
                end
            end

            secondStopBit: begin
                if (counter >= baudRate) begin 
                    next_Tx = 1;                    
                    next_finished = 1;
                    next_TXstate = idle;
                end
            end			
        endcase
	end 
endmodule