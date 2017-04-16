/*
*GENERAL DESCRIPTION
*
*ad9648_con module test bench, simulates behaviour of AD9648 ADC chip 
*
*/


`timescale 1ns / 1ps

module ad9648_con_tb();

parameter clk_a_period_ns = 10;
parameter clk_b_period_ns = 10;

reg     clk_a_in;
reg     clk_b_in;

reg   [14-1:0] data_a_in;
reg   [14-1:0] data_b_in;

wire    sync;
wire    overrange_a_in;
wire    overrange_b_in;

wire enable1;

integer     file_a;
integer     file_b;

integer     scan_a;
integer     scan_b;

ad9648_con #(.bit_width(2'd14)) check(clk_a_in, clk_b_in, enable1, data_a_in, data_b_in, overrange_a_in, overrange_b_in);

initial
begin
    clk_a_in = 1'b1;
    forever #clk_a_period_ns clk_a_in = ~clk_a_in;
end

initial
begin
    clk_b_in = 1'b1;
    forever #clk_b_period_ns clk_b_in = ~clk_b_in;
end


initial
begin
    file_a = $fopen("/home/mujo/radar_projekt/input_lut_a.txt","r");
    if(file_a == 1'd0)
    begin
        $display("file NULL");
        $finish;
    end
end

initial
begin
    file_b = $fopen("/home/mujo/radar_projekt/input_lut_b.txt","r");
    if(file_b == 1'd0)
    begin
        $display("file NULL");
        $finish;
    end
end

always @(negedge clk_b_in)
begin
    scan_b = $fscanf(file_b,"%d\n",data_b_in);
    if($feof(file_b))
    begin
        $finish;         
    end
end

always @(negedge clk_a_in)
begin
    scan_a = $fscanf(file_a,"%d\n",data_a_in);
    if($feof(file_a))
    begin
        $finish;         
    end
end


endmodule
