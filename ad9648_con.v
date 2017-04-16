/*
Date: 25.2.2017
Author: Jost R. 

GENERAL DESCRIPTION

This module provides direct interface to AD9648 ADC

*/

`timescale 1ns / 1ps

module ad9648_con

    #(parameter
        bit_width = 5'd14
    )
    (
    input   clk_a,
    input   clk_b,
    
    output reg enable,      //active low!
    
    input   [bit_width-1:0]data_a_bus,
    input   [bit_width-1:0]data_b_bus,
    
    output reg   [bit_width-1:0]data_a_bus_out,
    output reg   [bit_width-1:0]data_b_bus_out,
    
    input   overrange_a,
    input   overrange_b
);

reg     [bit_width-1:0]data_b;
reg     [bit_width-1:0]data_a;

//always enable = 1'b0;      //active low!

always @(posedge clk_a)
begin
    if(enable == 1'b0)
    begin
        data_a          <= data_a_bus;
        data_a_bus_out  <= data_a;
    end
end


always @(posedge clk_b)
begin
    if(enable == 1'b0)
    begin
        data_b          <= data_b_bus;   
        data_b_bus_out  <= data_b; 
    end
end

endmodule