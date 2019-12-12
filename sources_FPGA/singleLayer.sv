/*
File: singleLayer.sv
Input: a vector of inputs, a matrix of weights
Function: operation in a single layer of NN
Output: output produced by the single layer of NN with activation
Parameters: Q: size of fractional part, N: width of each data			

This implements the operation that happens in a single layer of NN

Code Written by: Sorty MMith (sortymmith@outlook.com)
15 Nov 2019
*/

module singleLayer #(parameter FRACTION_WIDTH=15, parameter BIT_WIDTH=32,
							parameter inputSize = 5,
							parameter numNeurons = 5)
							(
							input logic clk,rst,
							input logic [BIT_WIDTH-1:0] inputs[inputSize-1:0],
							input logic [BIT_WIDTH-1:0] weights[inputSize-1:0][numNeurons-1:0],
							input logic start,
							output logic done,
							output logic [BIT_WIDTH-1:0] outputs[numNeurons-1:0]
							);
		
			//logic to indicate multiplication is done
			logic done_mul;			
			assign done = done_mul;
			//logic to hold intermediate values before activation
			logic [BIT_WIDTH-1:0] beforeActivation[numNeurons-1:0];
			
			//call matrix multiplication module
			vecMatProd #(FRACTION_WIDTH,BIT_WIDTH,inputSize,numNeurons) vecMMul(
											.clk(clk),
											.start(start),
											.matA(inputs),
											.matB(weights),
											.result(beforeActivation),
											.done(done_mul)
											);
											
			// let us call for activation here
			genvar activation_var;
			generate
			for(activation_var = 0;activation_var<numNeurons;activation_var = activation_var+1)
			begin: act1
				relu #(FRACTION_WIDTH,BIT_WIDTH) act1 (beforeActivation[activation_var],outputs[activation_var]);
			end
			endgenerate
			
endmodule							