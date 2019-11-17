/*
File: dotproduct.sv
Input: Two vectors of H elements
Function: Compute dot product of input vectors and
Output: Return the dot product.
Parameters: Q: size of fractional part, N: width of each data, H: size of the vectors.

Code Written by: Sorty MMith (sortymmith@outlook.com)
15 Nov 2019
*/
module dotproduct #( parameter FRACTION_WIDTH = 15,	parameter BIT_WIDTH = 32, parameter VECTOR_SIZE = 10 ) //Parameterized values 
					(
					input logic clk,
					input logic start_dot,
					input logic [BIT_WIDTH-1:0] a_vec [VECTOR_SIZE-1:0],
					input logic [BIT_WIDTH-1:0] b_vec [VECTOR_SIZE-1:0],
					output logic [BIT_WIDTH-1:0] result,
					output logic done
					);
	//following will hold the element wise multiplication result of the two vectors
	logic [BIT_WIDTH-1:0] products[VECTOR_SIZE-1:0];
	//following will come from prodOfVectors that will indicate the elementwise product completion
	logic prod_complete;
	//following will hold the done signal indicator
	logic sum_complete;
	//following will hold the final result value
	logic [BIT_WIDTH-1:0] sum_val;
	//following will count the number of times addition was performed
	integer Count;
	
	//instantiate element wise product of vectors here
	prodof2Vectors #(FRACTION_WIDTH,BIT_WIDTH,VECTOR_SIZE) pod (
								.clk(clk),
								.startMult(start_dot),
								.a_vec(a_vec),
								.b_vec(b_vec),
								.result(products),
								.done(prod_complete)
								);
	
	sumOfVectorElements #(FRACTION_WIDTH,BIT_WIDTH,VECTOR_SIZE) sov (
							.clk(clk),
							.start(prod_complete),
							.a_vec(products),
							.result(result),
							.done(sum_complete)
							);
	assign done = sum_complete;

endmodule

/*
Following module computes the sum of all the elements in an array supplied.
*/
module sumOfVectorElements #( parameter FRACTION_WIDTH = 15,	parameter BIT_WIDTH = 32, parameter VECTOR_SIZE = 10) 
					(input logic clk, start,
					input [BIT_WIDTH-1:0] a_vec[VECTOR_SIZE-1:0],
					output [BIT_WIDTH-1:0] result,
					output logic done
					);
	
	logic [BIT_WIDTH-1:0] sum[VECTOR_SIZE-2:0];
	integer count,next_count;
	
	qadd #(FRACTION_WIDTH,BIT_WIDTH) qa0 (
					.a(a_vec[0]),
					.b(a_vec[1]),
					.c(sum[0])
					);
					
	genvar gi;
	generate
	for(gi=2;gi<VECTOR_SIZE-1;gi = gi+1) begin: sv
		qadd #(FRACTION_WIDTH,BIT_WIDTH) qa (.a(sum[gi-2]),
						.b(a_vec[gi]),
						.c(sum[gi-1])
						);
	end
	endgenerate
	
	qadd #(FRACTION_WIDTH,BIT_WIDTH) qah (
				.a(sum[VECTOR_SIZE-3]),
				.b(sum[VECTOR_SIZE-2]),
				.c(result)
				);

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
			else if(count<VECTOR_SIZE)
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
module prodof2Vectors #( parameter FRACTION_WIDTH = 15,	parameter BIT_WIDTH = 32, parameter VECTOR_SIZE = 10)
					(input logic clk, startMult,
					input [BIT_WIDTH-1:0] a_vec[VECTOR_SIZE-1:0],
					input [BIT_WIDTH-1:0] b_vec[VECTOR_SIZE-1:0],
					output [BIT_WIDTH-1:0] result[VECTOR_SIZE-1:0],
					output logic done
					);

	logic [VECTOR_SIZE-1:0] is_complete;
	logic [VECTOR_SIZE-1:0] is_overflow;
	
	assign done = (&is_complete)?1'b1:1'b0;

	//create parallel logic so that all the multiplication is performed at once
	// .. this will be true since there is no dependency between the results
	genvar gi;
	generate
	for(gi=0;gi<VECTOR_SIZE;gi=gi+1) begin: mp
		qmults #(FRACTION_WIDTH,BIT_WIDTH) q1 (
						.i_multiplicand(a_vec[gi]),
						.i_multiplier(b_vec[gi]),
						.i_start(startMult),
						.i_clk(clk),
						.o_result_out(result[gi]),
						.o_complete(is_complete[gi]),
						.o_overflow(is_overflow[gi])
					);		
	end
	endgenerate
endmodule