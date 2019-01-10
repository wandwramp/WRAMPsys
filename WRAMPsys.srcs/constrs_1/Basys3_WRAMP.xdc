# Daniel Oosterwijk & Tyler Marriner
# University of Waikato, 2018

# This file maps the input and output signals of the wramp_wrapper module to the pins on the Basys3 FPGA.

# To expand functionality, add more signals to wramp_wrapper, uncomment the lines corresponding to the
# pins you want, and rename the used ports to match the new signals.

# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk100MHz]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk100MHz]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk100MHz]
 
# Switches
set_property PACKAGE_PIN V17 [get_ports {sw[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
set_property PACKAGE_PIN V16 [get_ports {sw[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
set_property PACKAGE_PIN W16 [get_ports {sw[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
set_property PACKAGE_PIN W17 [get_ports {sw[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]
set_property PACKAGE_PIN W15 [get_ports {sw[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[4]}]
set_property PACKAGE_PIN V15 [get_ports {sw[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]
set_property PACKAGE_PIN W14 [get_ports {sw[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]
set_property PACKAGE_PIN W13 [get_ports {sw[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]
set_property PACKAGE_PIN V2 [get_ports {sw[8]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[8]}]
set_property PACKAGE_PIN T3 [get_ports {sw[9]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[9]}]
set_property PACKAGE_PIN T2 [get_ports {sw[10]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[10]}]
set_property PACKAGE_PIN R3 [get_ports {sw[11]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[11]}]
set_property PACKAGE_PIN W2 [get_ports {sw[12]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[12]}]
set_property PACKAGE_PIN U1 [get_ports {sw[13]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[13]}]
set_property PACKAGE_PIN T1 [get_ports {sw[14]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[14]}]
set_property PACKAGE_PIN R2 [get_ports {sw[15]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[15]}]
 

# LEDs
set_property PACKAGE_PIN U16 [get_ports {led_out_hardware[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led_out_hardware[0]}]
set_property PACKAGE_PIN E19 [get_ports {led_out_hardware[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led_out_hardware[1]}]
set_property PACKAGE_PIN U19 [get_ports {led_out_hardware[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led_out_hardware[2]}]
set_property PACKAGE_PIN V19 [get_ports {led_out_hardware[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led_out_hardware[3]}]
set_property PACKAGE_PIN W18 [get_ports {led_out_hardware[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led_out_hardware[4]}]
set_property PACKAGE_PIN U15 [get_ports {led_out_hardware[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led_out_hardware[5]}]
set_property PACKAGE_PIN U14 [get_ports {led_out_hardware[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led_out_hardware[6]}]
set_property PACKAGE_PIN V14 [get_ports {led_out_hardware[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led_out_hardware[7]}]
set_property PACKAGE_PIN V13 [get_ports {led_out_hardware[8]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led_out_hardware[8]}]
set_property PACKAGE_PIN V3 [get_ports {led_out_hardware[9]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led_out_hardware[9]}]
set_property PACKAGE_PIN W3 [get_ports {led_out_hardware[10]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led_out_hardware[10]}]
set_property PACKAGE_PIN U3 [get_ports {led_out_hardware[11]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led_out_hardware[11]}]
set_property PACKAGE_PIN P3 [get_ports {led_out_hardware[12]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led_out_hardware[12]}]
set_property PACKAGE_PIN N3 [get_ports {led_out_hardware[13]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led_out_hardware[13]}]
set_property PACKAGE_PIN P1 [get_ports {led_out_hardware[14]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led_out_hardware[14]}]
set_property PACKAGE_PIN L1 [get_ports {led_out_hardware[15]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led_out_hardware[15]}]
	
	
# 7 segment display

set_property PACKAGE_PIN W7 [get_ports {seg[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]
set_property PACKAGE_PIN V7 [get_ports {seg[7]}]							
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[7]}]



# output select - active low
set_property PACKAGE_PIN U2 [get_ports {an[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]


# Buttons
# btnU
set_property PACKAGE_PIN T18 [get_ports buttons[0]] 			
	set_property IOSTANDARD LVCMOS33 [get_ports buttons[0]]
# btnR
set_property PACKAGE_PIN T17 [get_ports buttons[1]] 
	set_property IOSTANDARD LVCMOS33 [get_ports buttons[1]]
# btnC
set_property PACKAGE_PIN U18 [get_ports buttons[2]] 						
	set_property IOSTANDARD LVCMOS33 [get_ports buttons[2]]
# btnL
set_property PACKAGE_PIN W19 [get_ports buttons[3]] 
	set_property IOSTANDARD LVCMOS33 [get_ports buttons[3]]
# btnD
set_property PACKAGE_PIN U17 [get_ports buttons[4]]
	set_property IOSTANDARD LVCMOS33 [get_ports buttons[4]]



 
# USB-RS232 Interface (Serial port 1)
set_property PACKAGE_PIN B18 [get_ports Rx1]                        
    set_property IOSTANDARD LVCMOS33 [get_ports Rx1]
set_property PACKAGE_PIN A18 [get_ports Tx1]                        
    set_property IOSTANDARD LVCMOS33 [get_ports Tx1]

# Pmod Header JB
# Top-right Pmod expansion port (Serial port 2)    
set_property PACKAGE_PIN N17 [get_ports Rx2]                        
   set_property IOSTANDARD LVCMOS33 [get_ports Rx2]
set_property PACKAGE_PIN M18 [get_ports Tx2]
   set_property IOSTANDARD LVCMOS33 [get_ports Tx2]


##Pmod Header JA
##Sch name = JA1
#set_property PACKAGE_PIN J1 [get_ports {JA_low[0]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {JA_low[0]}]
###Sch name = JA2
#set_property PACKAGE_PIN L2 [get_ports {JA_low[1]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {JA_low[1]}]
###Sch name = JA3
#set_property PACKAGE_PIN J2 [get_ports {JA_low[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {JA_low[2]}]
###Sch name = JA4
#set_property PACKAGE_PIN G2 [get_ports {JA_low[3]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {JA_low[3]}]
##Sch name = JA7
#set_property PACKAGE_PIN H1 [get_ports {JA[4]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[4]}]
##Sch name = JA8
#set_property PACKAGE_PIN K2 [get_ports {JA[5]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[5]}]
##Sch name = JA9
#set_property PACKAGE_PIN H2 [get_ports {JA[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[6]}]
##Sch name = JA10
#set_property PACKAGE_PIN G3 [get_ports {JA[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[7]}]



##Pmod Header JB
# A14 - B16 are used for the second serial port
##Sch name = JB1
#set_property PACKAGE_PIN A14 [get_ports {JB[0]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[0]}]
##Sch name = JB2
#set_property PACKAGE_PIN A16 [get_ports {JB[1]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[1]}]
##Sch name = JB3
#set_property PACKAGE_PIN B15 [get_ports {JB[2]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[2]}]
##Sch name = JB4
#set_property PACKAGE_PIN B16 [get_ports {JB[3]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[3]}]
##Sch name = JB7
#set_property PACKAGE_PIN A15 [get_ports {JB[4]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[4]}]
##Sch name = JB8
#set_property PACKAGE_PIN A17 [get_ports {JB[5]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[5]}]
##Sch name = JB9
#set_property PACKAGE_PIN C15 [get_ports {JB[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[6]}]
##Sch name = JB10 
#set_property PACKAGE_PIN C16 [get_ports {JB[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[7]}]
 


##Pmod Header JC
##Sch name = JC1
#set_property PACKAGE_PIN K17 [get_ports {JC[0]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[0]}]
##Sch name = JC2
#set_property PACKAGE_PIN M18 [get_ports {JC[1]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[1]}]
##Sch name = JC3
#set_property PACKAGE_PIN N17 [get_ports {JC[2]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[2]}]
##Sch name = JC4
#set_property PACKAGE_PIN P18 [get_ports {JC[3]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[3]}]
##Sch name = JC7
#set_property PACKAGE_PIN L17 [get_ports {JC[4]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[4]}]
##Sch name = JC8
#set_property PACKAGE_PIN M19 [get_ports {JC[5]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[5]}]
##Sch name = JC9
#set_property PACKAGE_PIN P17 [get_ports {JC[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[6]}]
##Sch name = JC10
#set_property PACKAGE_PIN R18 [get_ports {JC[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[7]}]


#Pmod Header JXADC
#Sch name = XA1_P
#set_property PACKAGE_PIN J3 [get_ports {JX_low[3]}]				
#	set_property IOSTANDARD LVCMOS33 [get_ports {JX_low[3]}]
##Sch name = XA2_P
#set_property PACKAGE_PIN L3 [get_ports {JX_low[2]}]				
#	set_property IOSTANDARD LVCMOS33 [get_ports {JX_low[2]}]
##Sch name = XA3_P
#set_property PACKAGE_PIN M2 [get_ports {JX_low[1]}]				
#	set_property IOSTANDARD LVCMOS33 [get_ports {JX_low[1]}]
##Sch name = XA4_P
#set_property PACKAGE_PIN N2 [get_ports {JX_low[0]}]				
#	set_property IOSTANDARD LVCMOS33 [get_ports {JX_low[0]}]
##Sch name = XA1_N
#set_property PACKAGE_PIN K3 [get_ports {JX_hih[3]}]				
#	set_property IOSTANDARD LVCMOS33 [get_ports {JX_hih[3]}]
##Sch name = XA2_N
#set_property PACKAGE_PIN M3 [get_ports {JX_hih[2]}]				
#	set_property IOSTANDARD LVCMOS33 [get_ports {JX_hih[2]}]
##Sch name = XA3_N
#set_property PACKAGE_PIN M1 [get_ports {JX_hih[1]}]				
#	set_property IOSTANDARD LVCMOS33 [get_ports {JX_hih[1]}]
##Sch name = XA4_N
#set_property PACKAGE_PIN N1 [get_ports {JX_hih[0]}]				
#	set_property IOSTANDARD LVCMOS33 [get_ports {JX_hih[0]}]



##VGA Connector
#set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[0]}]
#set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[1]}]
#set_property PACKAGE_PIN J19 [get_ports {vgaRed[2]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[2]}]
#set_property PACKAGE_PIN N19 [get_ports {vgaRed[3]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[3]}]
#set_property PACKAGE_PIN N18 [get_ports {vgaBlue[0]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[0]}]
#set_property PACKAGE_PIN L18 [get_ports {vgaBlue[1]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[1]}]
#set_property PACKAGE_PIN K18 [get_ports {vgaBlue[2]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[2]}]
#set_property PACKAGE_PIN J18 [get_ports {vgaBlue[3]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[3]}]
#set_property PACKAGE_PIN J17 [get_ports {vgaGreen[0]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[0]}]
#set_property PACKAGE_PIN H17 [get_ports {vgaGreen[1]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[1]}]
#set_property PACKAGE_PIN G17 [get_ports {vgaGreen[2]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[2]}]
#set_property PACKAGE_PIN D17 [get_ports {vgaGreen[3]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[3]}]
#set_property PACKAGE_PIN P19 [get_ports Hsync]						
	#set_property IOSTANDARD LVCMOS33 [get_ports Hsync]
#set_property PACKAGE_PIN R19 [get_ports Vsync]						
	#set_property IOSTANDARD LVCMOS33 [get_ports Vsync]


##USB HID (PS/2)
#set_property PACKAGE_PIN C17 [get_ports PS2Clk]						
	#set_property IOSTANDARD LVCMOS33 [get_ports PS2Clk]
	#set_property PULLUP true [get_ports PS2Clk]
#set_property PACKAGE_PIN B17 [get_ports PS2Data]					
	#set_property IOSTANDARD LVCMOS33 [get_ports PS2Data]	
	#set_property PULLUP true [get_ports PS2Data]


##Quad SPI Flash
##Note that CCLK_0 cannot be placed in 7 series devices. You can access it using the
##STARTUPE2 primitive.
#set_property PACKAGE_PIN D18 [get_ports {QspiDB[0]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[0]}]
#set_property PACKAGE_PIN D19 [get_ports {QspiDB[1]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[1]}]
#set_property PACKAGE_PIN G18 [get_ports {QspiDB[2]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[2]}]
#set_property PACKAGE_PIN F18 [get_ports {QspiDB[3]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[3]}]
#set_property PACKAGE_PIN K19 [get_ports QspiCSn]					
	#set_property IOSTANDARD LVCMOS33 [get_ports QspiCSn]

