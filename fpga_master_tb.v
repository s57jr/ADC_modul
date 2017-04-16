`timescale 1ns/1ps

module testbench_lb;

// Inputs
reg flaga;
reg flagb;
reg flagc; //partial flag for IN EP
reg flagd; //full flag
reg clk;

// Outputs
wire [1:0] faddr1;
wire slrd1;
wire slwr1;
wire sloe1;
wire slcs1;
wire pktend1;

wire clk_out;
reg  reset_from_fx3;
reg [2:0] mode;

// Bidirs
wire [31:0] fdata1;
wire [31:0] fdata2;
reg  [31:0] fdata_out;
reg  [31:0] fdata_in;

// Instantiate the Unit Under Test (UUT)
slaveFIFO2b_fpga_top slavefifo_if (
	reset_from_fx3,            //input reset active low
	clk,                  //input clp 27 Mhz
//	sync,
	fdata1,  
	faddr1,                //output fifo address  
	slrd1,                 //output read select
	slwr1,                 //output write select
	flaga,
	flagb,
	flagc,
	flagd,
	sloe1,                //output output enable select
	clk_out,             //output clk 100 Mhz and 180 phase shift
	slcs1,                //output chip select
	pktend1,              //output pkt end
	mode,
	PMODE,
	RESET
);

initial // Clock generator
begin
    clk = 0;
forever #18.518 clk = !clk;
end

initial begin
	reset_from_fx3 = 1'b0;
	#100
	reset_from_fx3 = 1'b1;
	mode  = 3'd0;
	flaga = 0;
	flagb = 0;
	flagc = 0;
	flagd = 0;
	#3000
	mode  = 3'd3;
	flaga = 1;
	flagb = 1;
	#6000
	$finish();
	end


assign fdata1 = 32'hz;

endmodule

