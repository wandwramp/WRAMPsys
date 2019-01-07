# `WRAMPsys`

WRAMPsys is the Verilog implementation of the Wramp architecture, written for 
Vivado and designed with the Basys3 in mind.

The program counter is initialized to 0x80000 upon reset of the board.
This is the first memory location of ROM, ROM is populated by the Vivado build process. 
By default, this uses the monitor.mem source file included in this repo.
Rebuilding monitor.mem requires WRAMPmon and the entire toolchain to process the source (WRAMPtoolchain, wcc, trim). 

## Usage

WRAMPsys.xpr can be opened with the Vivado design suite.

## Building

The Vivado design suite is used to build the .bin/.bit files, which then can be
either uploaded to the Basys3 board or flash the internal memory.