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
					output logic [N-1:0] result,
					output logic done
					);
	//following will hold the element wise multiplication result of the two vectors
	logic [N-1:0] products[H-1:0];
	//following will come from prodOfVectors that will indicate the elementwise product completion
	logic prod_complete;
	//following will hold the done signal indicator
	logic sum_complete;
	//following will hold the final result value
	logic [N-1:0] sum_val;
	//following will count the number of times addition was performed
	integer Count;
	
	//instantiate element wise product of vectors here
	prodof2Vectors #(Q,N,H) pod (
								.clk(clk),
								.startMult(start_dot),
								.a_vec(a_vec),
								.b_vec(b_vec),
								.result(products),
								.done(prod_complete)
								);
	
	sumOfVectorElements #(Q,N,H) sov (
							.clk(clk),
							.start(prod_complete),
							.a_vec(products),
							.done(sum_complete)
							);

endmodule

/*
Following module computes the sum of all the elements in an array supplied.
*/
modle sumOfVectorElements #( parameter Q = 15,	parameter N = 32, parameter H = 10 
					(input logic clk, start,
					input [N-1:0] a_vec[H-1:0],
					output [N-1:0] result,
					output logic done
					);
	
	logic [N-1:0] sum[H-2:0];
	integer count,next_count;
	
	qadd #(Q,N) qa0 (
					.a(a_vec[0]),
					.b(a_vec[1]),
					.c(sum[0])
					);
					
	genvar gi;
	for(gi=2;gi<H;gi = gi+1) begin: sv
		qadd #(Q,N) qa (.a(sum[gi-2]),
						.b(a_vec[gi]),
						.c(sum[qi-1])
						);
	end
	
	//let us have a logic to count and predict when the sum if found out 
	always@(posedge clk)
	begin
		if(start)
		begin
			if(done==1'b1)
			begin
				next_count<=0;
				done<=1'b0;
			end
			else if(count<H)
				next_count = count+1;
			else
				done <= 1'b1;				
		end
	end
	
	always_comb
	begin
		count<=next_count;
	end
	
endmodule					
/*
Following module computes multiplication of each elements of hte two input arrays and populates the output array.
After the multiplication is complete, the output logic signal done is asserted high.

Read the result from the result register when the done signal is high.
*/
module prodof2Vectors #( parameter Q = 15,	parameter N = 32, parameter H = 10 
					(input logic clk, startMult
					input [N-1:0] a_vec[H-1:0],
					input [N-1:0] b_vec[H-1:0],
					output [N-1:0] result[H-1:0],
					output logic done
					);

	logic [H-1:0] is_complete;
	logic [H-1:0] is_overflow;
	
	assign done = (&is_complete)?1'b1:1'b0;

	//create parallel logic so that all the multiplication is performed at once
	// .. this will be true since there is no dependency between the results
	genvar gi;
	for(gi=0;gi<H;gi=gi+1) begin: mp
		qmults #(Q,N) q1 (
						.i_multiplicand(a_vec[gi]),
						.i_multiplier(b_vec[gi]),
						.i_start(startMult),
						.i_clk(clk),
						.o_result(result[gi]),
						.o_complete(is_complete[gi]),
						.o_overflow(is_overflow[gi])
					);		
	end
endmodule