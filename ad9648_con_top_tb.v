/*
*GENERAL DESCRIPTION
*
*ad9648_con_top module test bench, simulates behaviour of AD9648 ADC chip 
*
*/


`timescale 1ns / 1ps

module ad9648_con_tb();

parameter clk_a_period_ns = 10;
parameter clk_b_period_ns = 10;
parameter clk_c_period_ns = 10;
parameter clk_d_period_ns = 10;

reg     clk_a_in;
reg     clk_b_in;
reg     clk_c_in;
reg     clk_d_in;

reg   [14-1:0] data_a_in;
reg   [14-1:0] data_b_in;
reg   [14-1:0] data_c_in;
reg   [14-1:0] data_d_in;

wire    sync_1;
wire    sync_2;

wire    overrange_a_in;
wire    overrange_b_in;
wire    overrange_c_in;
wire    overrange_d_in;

wire enable_1;
wire enable_2;

integer     file_a;
integer     file_b;
integer     file_c;
integer     file_d;

integer     scan_a;
integer     scan_b;
integer     scan_c;
integer     scan_d;


ad9648_con #(.bit_width(2'd14)) check(clk_a_in, clk_b_in, enable_1, data_a_in, data_b_in, overrange_a_in, overrange_b_in);
ad9648_con #(.bit_width(2'd14)) check(clk_c_in, clk_d_in, enable_2, data_c_in, data_d_in, overrange_c_in, overrange_d_in);


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
    clk_c_in = 1'b1;
    forever #clk_c_period_ns clk_c_in = ~clk_c_in;
end

initial
begin
    clk_d_in = 1'b1;
    forever #clk_d_period_ns clk_d_in = ~clk_d_in;
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
    file_c = $fopen("/home/mujo/radar_projekt/input_lut_c.txt","r");
    if(file_c == 1'd0)
    begin
        $display("file NULL");
        $finish;
    end
end

initial
begin
    file_d = $fopen("/home/mujo/radar_projekt/input_lut_d.txt","r");
    if(file_d == 1'd0)
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



always @(negedge clk_a_in)
begin
    scan_a = $fscanf(file_a,"%d\n",data_a_in);
    if($feof(file_a))
    begin         
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

always @(negedge clk_c_in)
begin
    scan_c = $fscanf(file_c,"%d\n",data_c_in);
    if($feof(file_c))
    begin
        $finish;         
    end
end

always @(negedge clk_d_in)
begin
    scan_d = $fscanf(file_d,"%d\n",data_d_in);
    if($feof(file_d))
    begin
        $finish;         
    end
end

endmodule
