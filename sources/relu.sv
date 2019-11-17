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

module relu #(parameter FRACTION_WIDTH=15, parameter BIT_WIDTH=32)
(
	input [BIT_WIDTH-1:0] in_x,
	output [BIT_WIDTH-1:0] out_val
);

	// relu-> max(0.1x,x)
	//if +ve, then in_x is output
	// if -ve, then 0.1 means we shift right by 3 times (0.125*x)
	assign out_val = in_x[BIT_WIDTH-1]?{1'b1,in_x[BIT_WIDTH-2:1]>>3}:in_x;

endmodule