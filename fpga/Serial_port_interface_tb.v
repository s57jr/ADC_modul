/**
*
*Date: 3.3.2017
*Author: Jost R. 
*
*GENERAL DESCRIPTION
*
* This is a testbench for module that interfaces with AD9648 serial port
* 
*
*/


`timescale 1ns / 1ps

module serial_interface_tb();

parameter sys_clk_period_ns = 19;   //app. 26 MHz
parameter sys_clk_divider   = 8'hFF;

reg     reset;

reg     sys_clk;
wire    data_from_adc;
wire    chip_select1;
wire    chip_select2;
reg     serial_data_in;
wire    serial_clk;

wire    serial_data_out;

reg     init1_finished      = 1'b0;

reg     [8-1:0]data_bit_num = 7'b0;
reg     rw_mode             = 1'b0;         // 1= read mode, 0=write mode
reg     [13-1:0]address     = 13'b0; 
reg     error               = 1'b0;

reg     [8-1:0]received     = 8'h00;

wire    rw_mode_debug;  //only temporary to monitor during simulation
wire    [8-1:0]bit_num_debug;

serial_interface #(.sys_clk_divider(sys_clk_divider)) interface1(chip_select1, chip_select2, serial_clk, serial_data_in,serial_data_out, sys_clk, reset, data_from_adc, rw_mode_debug, bit_num_debug); 

initial
begin
    #1000 reset = 1;
    #100 reset  = 0;
end

always @(*)
begin
    if(error == 1'b1)
    begin
        $finish;
    end
end

initial
begin
    sys_clk = 1'b1;
    forever #sys_clk_period_ns sys_clk=~sys_clk;
end


always @(posedge serial_clk)
begin
if(!init1_finished)
begin
    if (chip_select1 == 1'b0)
    begin
        data_bit_num = data_bit_num + 1'b1;
        if(rw_mode == 1'b1)             //read_ADC
        begin
            case(data_bit_num)
                8'h01: serial_data_in <= received[data_bit_num - 8'h01];
                8'h02: serial_data_in <= received[data_bit_num - 8'h01];
                8'h03: serial_data_in <= received[data_bit_num - 8'h01];
                8'h04: serial_data_in <= received[data_bit_num - 8'h01];
                8'h05: serial_data_in <= received[data_bit_num - 8'h01];
                8'h06: serial_data_in <= received[data_bit_num - 8'h01];
                8'h07: serial_data_in <= received[data_bit_num - 8'h01];
                8'h08: serial_data_in <= received[data_bit_num - 8'h01];
            endcase
            if(data_bit_num == 8'h09)
            begin
                rw_mode         <= 1'b0;
                data_bit_num    =  8'h00;
                init1_finished  <= 1'b1;
            end
        end else            //write to ADC
        begin
        case(data_bit_num)
            8'h01: rw_mode <= serial_data_out;
            8'h02: error = serial_data_out; //assume only one byte is always transferred - if not finish the simulation 
            8'h03: error = serial_data_out; //assume only one byte is always transferred - if not finish the simulation 
            8'h04: address <= {serial_data_out, address[11:0]};
            8'h05: address <= {address[12],serial_data_out, address[10:0]};
            8'h06: address <= {address[12:11],serial_data_out, address[9:0]};
            8'h07: address <= {address[12:10],serial_data_out, address[8:0]};   
            8'h08: address <= {address[12:9],serial_data_out, address[7:0]};
            8'h09: address <= {address[12:8],serial_data_out, address[6:0]};
            8'h0A: address <= {address[12:7],serial_data_out, address[5:0]};
            8'h0B: address <= {address[12:6],serial_data_out, address[4:0]};
            8'h0C: address <= {address[12:5],serial_data_out, address[3:0]};
            8'h0D: address <= {address[12:4],serial_data_out, address[2:0]};
            8'h0E: address <= {address[12:3],serial_data_out, address[1:0]};
            8'h0F: address <= {address[12:2],serial_data_out, address[0]};
            8'h10: address <= {address[12:1],serial_data_out};
            default: received[data_bit_num - 8'h11] <= serial_data_out;
        endcase     
        if(data_bit_num == 8'h19)
        begin
            data_bit_num     =  8'h00;
            rw_mode         <=  1'b1;
        end
        end
    end else
    begin
        data_bit_num    <= 1'b0;
    end
end
end


endmodule