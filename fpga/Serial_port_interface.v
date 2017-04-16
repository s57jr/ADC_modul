/**
*
*Date: 3.3.2017
*Author: Jost R. 
*
*GENERAL DESCRIPTION
*
* This module interfaces with AD9648 serial port
* 
*
*/



`timescale 1ns / 1ps


module serial_interface

    #(parameter sys_clk_divider = 8'hFF)   //serial clock = sys_clk / sys_clk_divider

(
    output reg  chip_select1,
    output reg  chip_select2,
    output reg  serial_clock,
    
    input       serial_data_in,
    output reg  serial_data_out,
  
    input       sys_clk,                        //for now 26MHz
    
    input       reset,

    
   // input       data_for_adc,
    output      data_from_adc,
    
    output reg  rw_mode_deb,   //only temporary to monitor during simulation
    output reg  [8-1:0]bit_num_debug
    
);

reg [8-1:0]divider_cnt      = 1'b0;
reg serial_clk              = 1'b0;
reg init1_finished          = 1'b0;
reg init2_finished          = 1'b0;
reg [8-1:0]bit_num          = 8'b0;
reg rw_mode                 = 1'b0;  // initial state is write

reg data_direction          = 1'b0;  // Direction of serial_data, 1 = set output, 0 = read input

reg cs1                     = 1'b1;
reg cs2                     = 1'b1;

reg [15-1:0]data_for_adc_i  = 15'b010101010101000;  //without LSB which is rw_mode
reg [8-1:0]data_for_adc_d   = 8'b00100101;  


reg out, in;                    //io port handling

assign data_from_adc = in;


always @(posedge sys_clk)
begin
    bit_num_debug   <= bit_num;
    serial_clock    <= serial_clk;
    rw_mode_deb     <= rw_mode;
    data_direction  <= ~rw_mode;     //set inout port to be input or output according to read/write operation
end

always @(posedge sys_clk)   //create serial_clk
begin
    if(reset)
    begin
        cs1             <= 1'b1;
        cs2             <= 1'b1;
        bit_num         <= 8'b0;
        init1_finished  <= 1'b0;
        init2_finished  <= 1'b0;
   
        serial_clk       <= 1'b0;
        divider_cnt      <= 8'b0;
    end else
    begin
        divider_cnt = divider_cnt + 1'b1;
        if(divider_cnt == sys_clk_divider)
        begin
            divider_cnt <= 1'b0;
            serial_clk  <= ~serial_clk;
        end
    end
end

always @(negedge serial_clk)
begin
    chip_select1 <= cs1;
    chip_select2 <= cs2;
end

always @(posedge serial_clk)
begin
if(reset)
begin
cs1             <= 1'b1;
cs2             <= 1'b1;
bit_num         <= 8'b0;
init1_finished  <= 1'b0;
init2_finished  <= 1'b0;
end
    else
    begin
    if(!init1_finished)            
    begin
        if(rw_mode == 1'b0)      //first write to the register
        begin
            if(cs1 == 1'b1)
            begin
                cs1     <= 1'b0;
                bit_num <= 1'b0;
            end
            bit_num <= bit_num + 1'b1;
            case(bit_num)
                8'h01: serial_data_out <= rw_mode;
                8'h02: serial_data_out <= data_for_adc_i[bit_num-2];
                8'h03: serial_data_out <= data_for_adc_i[bit_num-2];
                8'h04: serial_data_out <= data_for_adc_i[bit_num-2];
                8'h05: serial_data_out <= data_for_adc_i[bit_num-2];
                8'h06: serial_data_out <= data_for_adc_i[bit_num-2];
                8'h07: serial_data_out <= data_for_adc_i[bit_num-2];
                8'h08: serial_data_out <= data_for_adc_i[bit_num-2];
                8'h09: serial_data_out <= data_for_adc_i[bit_num-2];
                8'h0A: serial_data_out <= data_for_adc_i[bit_num-2];
                8'h0B: serial_data_out <= data_for_adc_i[bit_num-2];
                8'h0C: serial_data_out <= data_for_adc_i[bit_num-2];
                8'h0D: serial_data_out <= data_for_adc_i[bit_num-2];
                8'h0E: serial_data_out <= data_for_adc_i[bit_num-2];
                8'h0F: serial_data_out <= data_for_adc_i[bit_num-2];
                8'h10: serial_data_out <= data_for_adc_i[bit_num-2];
                default: serial_data_out <= data_for_adc_d[(bit_num-1) & 8'h0F];
            endcase
            if(bit_num == 8'h19)
            begin
                bit_num         <=  8'h00;
                cs1             <=  1'b1;
                rw_mode         <=  1'b1;
                serial_data_out <=  1'bz;

                
            end
        end else if(rw_mode == 1'b1) //now read the register
        begin
            if(cs1 == 1'b1)
            begin
                cs1     <= 1'b0;
                bit_num <= 1'b0;
            end
            bit_num <= bit_num + 1'b1;
            case(bit_num)
                8'h01: in <= serial_data_in;
                8'h02: in <= serial_data_in;
                8'h03: in <= serial_data_in;
                8'h04: in <= serial_data_in;
                8'h05: in <= serial_data_in;
                8'h06: in <= serial_data_in;
                8'h07: in <= serial_data_in;
                8'h08: in <= serial_data_in;
            endcase
            if(bit_num == 8'h09)
            begin
                bit_num         <= 8'h00;
                cs1             <= 1'b1;
                init1_finished  <= 1'b1;
                rw_mode         <= 1'b0;
                in              <= serial_data_in;
            end
        end
    end else if(!init2_finished)
    begin
        
    end 
    end
end
endmodule