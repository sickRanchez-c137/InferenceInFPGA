/*
File: relu.sv
Input: an input fixed point number
Function: find the output of relu function applied to the input number
Output: Return the product AXB
Parameters: Q: size of fractional part, N: width of each data			

Code Written by: Sorty MMith (sortymmith@outlook.com)
15 Nov 2019
*/

module relu #(parameter Q=15, parameter N=32)
(
	input [N-1:0] in_x,
	output [N-1:0] out_val
);

// relu-> max(0,x)
assign out_val = (|in_x)?in_x:{N{1'b0}};

endmodule