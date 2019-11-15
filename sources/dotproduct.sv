/*
File: dotproduct.sv
Input: Two vectors of H elements
Function: Compute dot product of input vectors and
Output: Return the dot product.
Parameters: Q: size of fractional part, N: width of each data, H: size of the vectors.

Code Written by: Sorty MMith (sortymmith@outlook.com)
15 Nov 2019
*/
module dotproduct #( parameter Q = 15,	parameter N = 32, parameter H = 10 ) //Parameterized values 
(
input logic clk,
input logic start_dot,
input logic [N-1:0] a_vec [H-1:0],
input logic [N-1:0] b_vec [H-1:0],
output logic [N-1:0] result
);
// following holds result of each product between elements of a and b vectors
logic [N-1:0] temp_product [H-1:0];
//following checks if each product is complete
logic [H-1:0] is_complete;
// following checks if there is any overflow in any of the product
logic [H-1:0] is_overflow;
// our temp result value
logic [N-1:0] temp_result[H-1:0];
integer i;

//temp_sum is what will be assigne to result
assign result = (&is_complete)?temp_result[H-1]:0;

// since we have parameterized length of vector, let us use for loop to dynamically create 
// .. logics that will compute product of each elements of the two input arrays
	qmults #(Q,N) qH (
					.i_multiplicand(a_vec[H-1]),
					.i_multiplier(b_vec[H-1]),
					.i_start(start_dot),
					.i_clk(clk),
					.o_result(temp_product[H-1]),
					.o_complete(is_complete[H-1]),
					.o_overflow(is_overflow[H-1])
					);
	qadd #(Q,N) qA (
					.a(temp_product[H-1]),
					.b(temp_result[H-2]),
					.c(temp_result[H-1])
					);
genvar gi;
for(gi=0;gi<H-1;gi+=1) begin: dp
	qmults #(Q,N) q1 (
					.i_multiplicand(a_vec[gi]),
					.i_multiplier(b_vec[gi]),
					.i_start(start_dot),
					.i_clk(clk),
					.o_result(temp_product[gi]),
					.o_complete(is_complete[gi]),
					.o_overflow(is_overflow[gi])
					);
	qadd #(Q,N) d1 (
					.a(temp_product[gi]),
					.b(temp_product[gi+1),
					.c(temp_result[gi])
					);
end

endmodule