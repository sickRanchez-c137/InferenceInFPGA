/*
File: relu.sv
Input: an input fixed point number
Function: find the output of relu function applied to the input number
Output: Return the product AXB
Parameters: Q: size of fractional part, N: width of each data			

This implements leaky ReLU

Code Written by: Sorty MMith (sortymmith@outlook.com)
15 Nov 2019
*/

module relu #(parameter Q=15, parameter N=32)
(
	input [N-1:0] in_x,
	output [N-1:0] out_val
);

// relu-> max(0.1x,x)
//if +ve, then in_x is output
// if -ve, then 0.1 means we shift right by 3 times (0.125*x)
assign out_val = in_x[N-1]?{3'b100,in_x[N-2:0]>>3}:in_x;

endmodule