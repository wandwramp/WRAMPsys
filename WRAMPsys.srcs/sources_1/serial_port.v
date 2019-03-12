/*
########################################################################
# This file is part of WRAMPsys, a Verilog implimentaion of WRAMP.
#
# Copyright (C) 2019 The University of Waikato, Hamilton, New Zealand.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
########################################################################
*/

`timescale 1ns / 1ps

module serial_port(
  	input rst_n,
    input clk,

    input read_enable,
    input write_enable,
    inout [31:0] data_bus,
    input [19:0] address_bus,

    output reg serial_irq_n,

    output Tx,
    input Rx
	); 
	
	//module internal memory
	reg [7:0] TxData, next_TxData;
	reg [7:0] RxData, next_RxData;
	reg [10:0] ctrl, next_ctrl;
	reg [4:0] stat, next_stat;
	reg [2:0] int_ack, next_int_ack;
	
	wire finishedTX, startRX, finishedRX, parityErr, frammingErr;
    wire [7:0] newRxData;

	reg [14:0] baudRate; //reg to store the current value to count to dependent on the ctrl values		

	reg [31:0] data;
	assign data_bus = read_enable ? data : 32'hzzzzzzzz;

	reg [1:0] TXstat; //the finished status of the reciever    for the last two clk cycles
	reg [1:0] RXstat; //the finished status of the transmitter for the last two clk cycles

	reg startTX, next_startTX;


	initial TxData = 0;
	initial RxData = 0;
	initial ctrl = 10'h3C7; //no parity, 1 stop bit, 38400 baudrate
	initial stat = 2; //ready to send, nothing to read
	initial int_ack = 0;
	
	
	always @(posedge clk) begin
		if (!rst_n) begin     
			RxData <= 0;
			TxData <= 0;

			ctrl <= 10'h3C7; //no parity, 1 stop bit, 38400 baudrate
			//this is not the defualt restart conditions but wrampMon will immediatly set to this, so wont hurt to be here

			int_ack <= 0;
			stat <= 2;      //ready to send, nothing to read

			TXstat <= 0;
			RXstat <= 0;
			startTX <= 0;

		end 
		else begin
			RxData <= next_RxData;
			TxData <= next_TxData;
			ctrl <= next_ctrl;
			int_ack <= next_int_ack;
			stat <= next_stat;

			TXstat[1:0] <= {TXstat[1],finishedTX}; //shift finished status and load new value
			RXstat[1:0] <= {RXstat[1],finishedRX};

			startTX <= next_startTX;
		end
	end		
		
		
	always @(*) begin
//////////////////////////////////////////////////////////////////////////////////////////////////
/*
Baudrate numbers pulled from python3 script
offset is the number used in the index offset of the clk scaler in wramp_wrapper.v
wire clk = clk_counter[3];
			
def baudRate(offset):			
    hz = 100000000 / (1 << (offset+1))
    bs = 300
    for n in range(0,8):
        print("3'b",format(n, '03b'),": begin //",(2**n)*bs,"bps",sep='')
        print("\tbaudRate <= ",round(hz/((2**n)*bs)),";",sep='')
        print("end") 

        >>> baudrate(3) 
*/ 
//////////////////////////////////////////////////////////////////////////////////////////////////
		case (ctrl[2:0])
		 	3'b000: begin //300bps
                 baudRate <= 20833;
            end
            3'b001: begin //600bps
                baudRate <= 10417;
            end
            3'b010: begin //1200bps
                baudRate <= 5208;
            end
            3'b011: begin //2400bps
                baudRate <= 2604;
            end
            3'b100: begin //4800bps
                baudRate <= 1302;
            end
            3'b101: begin //9600bps
                baudRate <= 651;
            end
            3'b110: begin //19200bps
                baudRate <= 326;
            end
            3'b111: begin //38400bps
                baudRate <= 163;
            end
		endcase
//////////////////////////////////////////////////////////////////////////////////////////////////
            
		 next_RxData = RxData;
		 next_TxData = TxData;
		 next_ctrl = ctrl;
		 next_int_ack = int_ack;		 
		 next_stat = stat;
		 next_startTX = 0;

		 if (RXstat == 2'b01) begin		//the edge of RX finishing
		 	
		 	
		 			 
            next_stat[4] = parityErr;
            next_stat[3] = frammingErr;
		 	next_stat[2] = stat[0];		//overrun error if prev byte not read
		 	
		 	next_stat[0] = 1; 			//set receive status
		 	next_int_ack[0] = ctrl[8];	//set receive interrupt
		 	next_RxData = newRxData;	//read the new data

			 next_int_ack[2] = ctrl[10] & (parityErr | frammingErr | stat[0]); 
		 end

		 if (TXstat == 2'b01) begin		//the edge of TX finishing
		 	next_stat[1] = 1;			//set transmit status
		 	next_int_ack[1] = ctrl[9];	//set transmit interrupt
		 end
		
	
		 data = 32'h00000000;
		 case (address_bus[11:0])
		 	0: begin //TX register
		 		if (write_enable) begin
		 			 next_stat[1] = 0; 				//unset flag for writing ready
		             next_TxData = data_bus[7:0];	//load transmit data 
		             next_startTX = 1;				//begin transmitting
		         end else begin 
		         	data[7:0] = 0;					//return 0, not readable
		         end
		 	end
			
		 	1: begin //Rx register 
		 		if (read_enable) begin
		            next_stat[0] = 0;				//unset flag for data read ready
		 			data[7:0] = RxData;		
		         end
		 	end
			
		 	2: begin //ctrl register 
		 		if (write_enable) begin
		 			next_ctrl = data_bus[10:0];			
		 		end
		 		else data[10:0] = ctrl;
		 	end
			
		 	3: begin //status register
		 		if (read_enable) begin
                 	data = stat;					//read only
		 		end
		 	end
			
		 	4: begin //int/ack register 
                 if (write_enable) begin
		 			next_int_ack = data_bus[2:0];
		 			next_stat = stat & 3;		
					//not 100% sure on the ordering of int_acks and status writes 
					//may cause issues, none encounted 
		 		end
		 		else data[2:0] = int_ack;
		 	end			
		 endcase
		 serial_irq_n = int_ack == 0; //trigger interrupt if exception 
	end
	
	transmitter transmitter(
        .rst_n(rst_n),
        .clk(clk),
        .TxD(TxData),
        .ctrl(ctrl),
        .startTx(startTX),
        .finished(finishedTX),
        .Tx(Tx),
        .baudRate(baudRate)
	);
		
	receiver receiver(
		.rst_n(rst_n),
		.clk(clk),
		.RxD(newRxData),
		.ctrl(ctrl),
		.startRx(startRX),
		.finished(finishedRX),
		.Rx(Rx),
		.parityErr(parityErr), 
		.frammingErr(frammingErr),
		.baudRate(baudRate)
	);
endmodule






