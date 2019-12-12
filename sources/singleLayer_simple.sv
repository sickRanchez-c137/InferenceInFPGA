/*
File: singleLayer_simple.sv
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
			logic [BIT_WIDTH-1:0] outputsAfterBias[numNeurons-1:0];
			logic [BIT_WIDTH-1:0] biasVal[numNeurons-1:0];
			
			assign biasVal[0] = 9'b100001101;
			assign biasVal[1] = 9'b100010001;
			assign biasVal[2] = 9'b000000000;
			assign biasVal[3] = 9'b100000000;
			
			//call matrix multiplication module
			vecMatProd #(FRACTION_WIDTH,BIT_WIDTH,inputSize,numNeurons) vecMMul(
											.clk(clk),
											.start(start),
											.matA(inputs),
											.matB(weights),
											.result(beforeActivation),
											.done(done_mul)
											);			// let us call for activation here
			genvar activation_var;
			generate
			for(activation_var = 0;activation_var<numNeurons;activation_var = activation_var+1)
			begin: act1
				relu #(FRACTION_WIDTH,BIT_WIDTH) act1 (outputsAfterBias[activation_var],outputs[activation_var]);
				qadd #(FRACTION_WIDTH,BIT_WIDTH) qa0 (
					.a(biasVal[activation_var]),
					.b(beforeActivation[activation_var]),
					.c(outputsAfterBias[activation_var])
					);
			end
			endgenerate
			
endmodule
module singleLayerInput #(parameter FRACTION_WIDTH=15, parameter BIT_WIDTH=32,
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
			logic [BIT_WIDTH-1:0] outputsAfterBias[numNeurons-1:0];
			logic [BIT_WIDTH-1:0] biasVal[numNeurons-1:0];
			
			assign biasVal[0] = 9'b000010001;
			assign biasVal[1] = 9'b100010111;
			assign biasVal[2] = 9'b000101011;
			assign biasVal[3] = 9'b100010101;
			
			//call matrix multiplication module
			vecMatProdInput #(FRACTION_WIDTH,BIT_WIDTH,inputSize,numNeurons) vecMMul(
											.clk(clk),
											.start(start),
											.matA(inputs),
											.matB(weights),
											.result(beforeActivation),
											.done(done_mul)
											);			// let us call for activation here
			genvar activation_var;
			generate
			for(activation_var = 0;activation_var<numNeurons;activation_var = activation_var+1)
			begin: act1
				relu #(FRACTION_WIDTH,BIT_WIDTH) act1 (outputsAfterBias[activation_var],outputs[activation_var]);
				qadd #(FRACTION_WIDTH,BIT_WIDTH) qa0 (
					.a(biasVal[activation_var]),
					.b(beforeActivation[activation_var]),
					.c(outputsAfterBias[activation_var])
					);
			end
			endgenerate
			
endmodule
module singleLayerOutput #(parameter FRACTION_WIDTH=15, parameter BIT_WIDTH=32,
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
			logic [BIT_WIDTH-1:0] outputsAfterBias[numNeurons-1:0];
			logic [BIT_WIDTH-1:0] biasVal[numNeurons-1:0];
			
			assign biasVal[0] = 9'b100011110;
			
			//call matrix multiplication module
			vecMatProdOutput #(FRACTION_WIDTH,BIT_WIDTH,inputSize,numNeurons) vecMMul(
											.clk(clk),
											.start(start),
											.matA(inputs),
											.matB(weights),
											.result(beforeActivation),
											.done(done_mul)
											);			// let us call for activation here
			genvar activation_var;
			generate
			for(activation_var = 0;activation_var<numNeurons;activation_var = activation_var+1)
			begin: act1
				relu #(FRACTION_WIDTH,BIT_WIDTH) act1 (outputsAfterBias[activation_var],outputs[activation_var]);
				qadd #(FRACTION_WIDTH,BIT_WIDTH) qa0 (
					.a(biasVal[activation_var]),
					.b(beforeActivation[activation_var]),
					.c(outputsAfterBias[activation_var])
					);
			end
			endgenerate
			
endmodule