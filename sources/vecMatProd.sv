/*
File: mamul.sv
Input: Two matrices of H elements. Each matrix is a 3d logic. matA of dim1Xdim2 and matB of dim2Xdim3
Function: Compute product of matrixes (AXB)
Output: Return the product AXB
Parameters: Q: size of fractional part, N: width of each data, 
			d1: num of rows of A, d2: num of columns of A, d3 num of col of B
			

Code Written by: Sorty MMith (sortymmith@outlook.com)
15 Nov 2019
*/

module vecMatProd #(parameter FRACTION_WIDTH = 15, parameter BIT_WIDTH = 32,
				parameter NUM_COL_VEC = 5,	parameter NUM_COL_MAT = 5)
(
	input logic clk,start,
	input logic [BIT_WIDTH-1:0] matA[NUM_COL_VEC-1:0],
	input logic [BIT_WIDTH-1:0] matB[NUM_COL_VEC-1:0][NUM_COL_MAT-1:0],
	output logic [BIT_WIDTH-1:0] result[NUM_COL_MAT-1:0],
	output logic done
);
			
		//check internal done signals
		logic [NUM_COL_MAT-1:0] done_check;		
		logic [BIT_WIDTH-1:0] matB_in[NUM_COL_MAT-1:0][NUM_COL_VEC-1:0];
		
		assign done = (&done_check)?1'b1:1'b0;
		
		// the matrix B to send to multiply is essentially transpose of the input matrix matB
		transpose #(FRACTION_WIDTH,BIT_WIDTH,NUM_COL_VEC,NUM_COL_MAT) transp(
										.inMat(matB),
										.outMat(matB_in)
									);
		
		genvar i,j;
		// we will lay out a collection of dot products since the result of matrix multiplication is a collection of dot products
		generate
			for(j=0;j<NUM_COL_MAT;j = j+1) begin: col
				dotproduct #(FRACTION_WIDTH,BIT_WIDTH,NUM_COL_VEC) dp(
										.clk(clk),
										.start_dot(start),
										.a_vec(matA),
										.b_vec(matB_in[j]),
										.result(result[j]),
										.done(done_check[j])
										); 
		end
		endgenerate
		
endmodule
