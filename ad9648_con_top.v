/**
*
*Date: 27.2.2017
*Author: Jost R. 
*
*GENERAL DESCRIPTION
*
* This module wraps 2 of the ad9648_con modules since in this 
* project we use two of those ADC chips 
*
*/


`timescale 1ns / 1ps


module ad9648_con_top

    #(parameter
        bit_width = 4'd14
    )
    (
    input   clk_a_1,
    input   clk_a_2,

    input   clk_b_1,    
    input   clk_b_2,
    
    output  enable_1,      //active low!
    output  enable_2,      //active low!

    
    input   [bit_width-1:0]data_a_bus_1,
    input   [bit_width-1:0]data_b_bus_1,
    
    input   [bit_width-1:0]data_a_bus_2,    
    input   [bit_width-1:0]data_b_bus_2,
        
    output   [bit_width-1:0]data_a_bus_1_out,
    output   [bit_width-1:0]data_b_bus_1_out,
    
    output   [bit_width-1:0]data_a_bus_2_out,    
    output   [bit_width-1:0]data_b_bus_2_out,
        
    input   overrange_a_1,
    input   overrange_a_2,
        
    input   overrange_b_1,
    input   overrange_b_2
);

ad9648_con #(.bit_width(bit_width)) ad9648_con_1(clk_a_1, clk_b_1, enable_1, data_a_bus_1, data_b_bus_1, data_a_bus_1_out, data_b_bus_1_out, overrange_a_1, overrange_b_1);
ad9648_con #(.bit_width(bit_width)) ad9648_con_2(clk_a_2, clk_b_2, enable_2, data_a_bus_2, data_b_bus_2, data_a_bus_2_out, data_b_bus_2_out, overrange_a_2, overrange_b_2);


endmodule
