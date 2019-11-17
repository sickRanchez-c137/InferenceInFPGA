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

module matmul #(parameter FRACTION_WIDTH = 15, parameter BIT_WIDTH = 32,
				parameter d1 = 5, parameter d2 = 5,
				parameter d3 = 5)
(
	input logic clk,start,
	input logic [BIT_WIDTH-1:0] matA[d1-1:0][d2-1:0],
	input logic [BIT_WIDTH-1:0] matB[d2-1:0][d3-1:0],
	output logic [BIT_WIDTH-1:0] result[d1-1:0][d3-1:0],
	output logic done
);
			
		//check internal done signals
		logic [d2-1:0] done_in[d1-1:0];
		logic [d1-1:0] done_check;
		
		logic [BIT_WIDTH-1:0] matB_in[d3-1:0][d2-1:0];
		
		//assign done output
		genvar dn;
		generate
		for(dn=0;dn<d1;dn = dn+1)
		begin: dn_chk
			assign done_check[dn] = (&done_in[dn])?1'b1:1'b0;
		end
		endgenerate
		assign done = (&done_check)?1'b1:1'b0;
		
		// the matrix B to send to multiply is essentially transpose of the input matrix matB
		transpose #(FRACTION_WIDTH,BIT_WIDTH,d2,d3) transp(
										.inMat(matB),
										.outMat(matB_in)
									);
		
		genvar i,j;
		// we will lay out a collection of dot products since the result of matrix multiplication is a collection of dot products
		generate
		for(i=0;i<d1;i = i+1) begin: row
			for(j=0;j<d3;j = j+1) begin: col
				dotproduct #(FRACTION_WIDTH,BIT_WIDTH,d2) dp(
										.clk(clk),
										.start_dot(start),
										.a_vec(matA[i]),
										.b_vec(matB_in[j]),
										.result(result[i][j]),
										.done(done_in[i][j])
										); 
			end
		end
		endgenerate
		
endmodule

//following module finds the transpose of the input matrix
module transpose #(parameter FRACTION_WIDTH = 15, parameter BIT_WIDTH = 32, 
						parameter dRowIn = 5, parameter dColIn = 5)
(
input logic [BIT_WIDTH-1:0] inMat[dRowIn-1:0][dColIn-1:0],
output logic [BIT_WIDTH-1:0] outMat[dColIn-1:0][dRowIn-1:0]
);
	genvar i,j;
	generate
	for(i=0;i<dRowIn;i= i+1)
	begin: f1
		for(j=0;j<dColIn;j = j+1)
		begin: f2
			assign outMat[j][i] = inMat[i][j];
		end
	end
	endgenerate
endmodule