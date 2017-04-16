
module slaveFIFO2b_fpga_top(
	reset_in_,            //input reset active low
	clk,                  //input clp 27 Mhz
//	sync,
	fdata,  
	faddr,                //output fifo address  
	slrd,                 //output read select
	slwr,                 //output write select
	flaga,
	flagb,
	flagc,
	flagd,
	sloe,                //output output enable select
	clk_out,             //output clk 100 Mhz and 180 phase shift
	slcs,                //output chip select
	pktend,              //output pkt end
	mode_p,
	PMODE,
	RESET,

); 

input reset_in_;
output [31:0] fdata; 
output [1:0] faddr; 
output       slrd;  
output reg      slwr;  

input        flaga;
input        flagb; 
input        flagc; 
input        flagd; 
input        clk;   
output       clk_out;   
output       sloe; 
output       slcs; 
output       pktend; 
output[1:0]  PMODE;  
output       RESET;
input [2:0]  mode_p;



reg [2:0] mode; 	

wire [31:0] fpga_master_data_out;
reg  [31:0] data_out;
reg  [1:0] oe_delay_cnt;	
reg  [1:0] fifo_address;   
reg  [1:0] fifo_address_d;   
reg       slrd_;
reg       slcs_;       
reg       slwr_;
reg      sloe_;
wire      clk_100;
reg[7:0] conter; 		
wire clk_out_temp;	
reg rd_oe_delay_cnt; 
reg first_time;
reg[15:0] index ;
reg[15:0] DataCount_i ;
reg slrd1_d_ ;
reg slrd2_d_ ;
wire reset_;

wire [31:0]data_out_stream_in;

reg flaga_d;
reg flagb_d;
reg flagc_d;
reg flagd_d;

reg [2:0]current_fpga_master_mode_d;

reg [2:0]current_fpga_master_mode;
reg [2:0]next_fpga_master_mode;
 


wire lock;
reg short_pkt_strob;

reg pktend_;


reg [31:0]fdata_d;


wire slwr_streamIN_;

wire stream_in_mode_selected;

reg [31:0] data_out_reg;

//parameters for transfers mode (fixed value)
parameter [2:0] STREAM_IN  = 3'd3;   //switch position on the Board 011


//parameters for fpga master mode state machine
parameter [2:0] fpga_master_mode_idle             = 3'd0;
parameter [2:0] fpga_master_mode_stream_in        = 3'd3;



//output signal assignment
assign slrd = slrd_;
//assign slwr = slwr_;   
always @ (posedge clk_100, negedge reset_)
begin
	if (~reset_)
		slwr <= 1'b1;
	else
		slwr <= slwr_;
end

assign faddr = fifo_address_d;
assign sloe = sloe_;
assign fdata = fpga_master_data_out;	
assign PMODE = 2'b11;		
assign RESET = 1'b1;	
assign slcs = slcs_;
assign pktend = pktend_;
	
reg sync_d;	



//clock generation(pll instantiation)
clk_wiz_v3_2_2 inst_clk
(
    .CLK_IN1(clk),  
    .CLK_OUT1(clk_100),
    .RESET(reset2pll),
    .LOCKED(lock)
);


//oddr2 is used to send out the clk(ODDR2 instantiation)
ODDR2 oddr_y                       
( 
  .D0(1'b0),
  .D1(1'b1),
  .C0 (clk_100),
  .C1(~clk_100),
  .Q(clk_out), 
  .CE(),
  .R(),
  .S()
); 



//instantiation of stream_in mode	
stream_to_fx3 stream_in_inst
(
 .reset_(reset_),
     .clk_100(clk_100),
     .stream_in_mode_selected(stream_in_mode_selected),
     .flaga_d(flaga_d),
     .flagb_d(flagb_d),
     .slwr_streamIN_(slwr_streamIN_),
     .data_out_stream_in(data_out_stream_in)
); 


assign reset2pll = !reset_in_;
assign reset_ = lock;




//floping the INPUT mode
always @(posedge clk_100, negedge reset_)begin
	if(!reset_)begin 
		mode <= 3'd0;
	end else begin
		mode <= mode_p;
	end	
end

///flopping the INPUTs flags
always @(posedge clk_100, negedge reset_)begin
	if(!reset_)begin 
		flaga_d <= 1'd0;
		flagb_d <= 1'd0;
		flagc_d <= 1'd0;
		flagd_d <= 1'd0;
	end else begin
		flaga_d <= flaga;
		flagb_d <= flagb;
		flagc_d <= flagc;
		flagd_d <= flagd;
	end	
end



//chip selection
always@(*)begin
	if(current_fpga_master_mode == fpga_master_mode_idle)begin
		slcs_ = 1'b1;
	end else begin
		slcs_ = 1'b0;
	end	
end

//selection of slave fifo address
always@(*)begin
	fifo_address = 2'b00;
	pktend_ = 1'b1;
end	

//flopping the output fifo address
always @(posedge clk_100, negedge reset_)begin
	if(!reset_)begin 
		fifo_address_d <= 2'd0;
 	end else begin
		fifo_address_d <= fifo_address;
	end	
end

//slrd an sloe signal assignments based on mode
always @(*)begin
	slrd_ = 1'b1;	//always write to fx3
	sloe_ = 1'b1;
end

//slwr signal assignment based on mode	
always @(*)begin
	case(current_fpga_master_mode)

	fpga_master_mode_stream_in:begin
		slwr_ = slwr_streamIN_;
	end

	default:begin
		slwr_ = 1'b1;
	end	
	endcase
end



//mode selection
assign stream_in_mode_selected  = (current_fpga_master_mode == fpga_master_mode_stream_in);


//Mode select state machine
always @(posedge clk_100, negedge reset_)begin
	if(!reset_)begin 
		current_fpga_master_mode <= fpga_master_mode_idle;
	end else begin
		current_fpga_master_mode <= next_fpga_master_mode;
	end	
end

//Mode select state machine combo   
always @(*)   
begin
	next_fpga_master_mode = current_fpga_master_mode;
	case (current_fpga_master_mode)
	fpga_master_mode_idle:begin
		case(mode)

		STREAM_IN:begin
			next_fpga_master_mode = fpga_master_mode_stream_in;
		end

		default:begin
			next_fpga_master_mode = fpga_master_mode_idle;
                end
		endcase
	end	
	fpga_master_mode_stream_in:begin
		if(mode == STREAM_IN)begin
			next_fpga_master_mode = fpga_master_mode_stream_in;
		end else begin 
			next_fpga_master_mode = fpga_master_mode_idle;
		end
	end	

	default:begin
		next_fpga_master_mode = fpga_master_mode_idle;
	end
	endcase

end



//selection of data_out based on current mode
always @(*)begin
	case(current_fpga_master_mode)
	
	fpga_master_mode_stream_in:begin
		data_out = data_out_stream_in;
	end
	default:begin
		data_out = 32'd0;
	end	
	endcase
end	

always @(posedge clk_100, negedge reset_)begin
	if(!reset_)begin 
		data_out_reg <= 32'd0;
 	end else begin
		data_out_reg <= data_out;
	end	
end

assign fpga_master_data_out = data_out_reg;

endmodule

