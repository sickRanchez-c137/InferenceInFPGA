/*
File: sigmoid.sv
Input: an input fixed point number
Function: find the output of sigmoid function applied to the input number
Output: Return the product AXB
Parameters: Q: size of fractional part, N: width of each data			

This module uses piece-wise linear approximation of sigmoid function.
https://pdfs.semanticscholar.org/5a23/cbee35cf0efdb63fc279f5c625b7b1ab05d3.pdf
http://islab.soe.uoguelph.ca/sareibi/TEACHING_dr/ENG6530_RCS_html_dr/outline_W2017/docs/PAPER_REVIEW_dr/Floating_Fixed_dr/IEEETransANN-Savich.pdf

Y = 1 for X>=5
Y = 0 for X<=-5
Y =  0.03125 .| X | + 0.84375 for X between 2.375 and 5
Y = 0.125.|X| + 0.625 for X between 1 and 2.375
Y =  0.25.|X| + 0.5 for X between 0 and 1

Code Written by: Sorty MMith (sortymmith@outlook.com)
15 Nov 2019
*/

//module sigmoid #(parameter Q=15, parameter N=32)
//(
//	input [N-1:0] in_x,
//	output [N-1:0] out_val
//);
//
//// following are multiplier and adder
//	logic [N-1:0] mult,adder;
//	logic [N-1:0] out_val_noSign,out_val_temp;
//	
//	
//	assign adder = (in_x[N-2:Q-1]>=(N-Q-1)'d5)?0:(in_x[Q-1:0]>=(Q-1)'d5)?1:0;
//	assign mult = (in_x[N-2:Q-1]>=(N-Q-1)'d5)?0:1;
//	
//	qmult #(Q,N) m1 (mult,{1'b1,in_x[N-2:0]},out_val_temp);
//	qadd #(Q,N) a1 (adder,out_val_temp,out_val);
//
//endmodule