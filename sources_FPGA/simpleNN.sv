/*
File: simpleNN.sv
Input: as necessary, this file can act as testbench as well
Function: operation a simple NN
Output: output produced by a simple NN with activation
Parameters: Q: size of fractional part, N: width of each data			


Code Written by: Sorty MMith (sortymmith@outlook.com)
15 Nov 2019
*/

module simpleNN #(parameter FRACTION_WIDTH = 0, parameter BIT_WIDTH = 8,
						parameter NUM_LAYERS = 2, parameter INPUTS = 4, parameter OUTPUTS = 2)
						(input logic clk, reset,
						input logic start, 
						output logic done);
		// NUM_LAYERS = 2 means we will have 4 layers including input and output layers
		// considering each layer has as many neurons as INPUTS, we have [INPUT LAYER][HIDDEN LAYER 4 NEURONS][HIDDEN LAYER 4 NEURONS][OUTPUT LAYER]
		// thus weights can be [BIT_WIDTH-1:0] weights[NUM_LAYERS][INPUTS][INPUTS]
		//let us create a weight matrix for 
		logic [BIT_WIDTH-1:0] inputs[INPUTS-1:0];
		logic [BIT_WIDTH-1:0] outputs[OUTPUTS-1:0];
		logic [BIT_WIDTH-1:0] weights[NUM_LAYERS][INPUTS][INPUTS];
		logic [BIT_WIDTH-1:0] weights_final[INPUTS][OUTPUTS];
		//we need some interval registers as well
		logic [BIT_WIDTH-1:0] internalVal[NUM_LAYERS][INPUTS];
		logic [NUM_LAYERS+1:0] done_;
		
		// this is just some random initialization, just to test if everything is okay
		//assign some values to the weights
		genvar i,j,k;
		generate
			for(i=0;i<NUM_LAYERS;i = i+1)
			begin: w_gen
				for(j=0;j<INPUTS-1;j = j+1)
				begin: w_gen_
					for(k=0;k<INPUTS-1;k = k+1)
					begin: w_gen__
						assign weights[i][j][k] = 5;
					end
				end
			end
		endgenerate
		//generate weights at the interface between output and final layer
		genvar l,m;
		generate
			for(l=0;l<INPUTS-1;l = l+1)
			begin: o_gen
				for(m=0;m<OUTPUTS-1;m = m+1)
				begin: o_gen_
					assign weights_final[l][m] = 5;
				end
			end
		endgenerate
		//generate random input values
		genvar n;
		generate
			for(n=0;n<INPUTS-1;n = n+1)
			begin: i_gen
					assign inputs[n] = {7'b0,n[0]};
			end
		endgenerate
		
		//between input and first layer
		singleLayer #(FRACTION_WIDTH,BIT_WIDTH,INPUTS,INPUTS) l_input
							(.clk(clk),.rst(reset),
							.inputs(inputs),
							.weights(weights[0]),
							.start(start),
							.done(done_[0]),
							.outputs(internalVal[0])
							);
		genvar layers;
		generate
		for(layers=1;layers<NUM_LAYERS;layers = layers+1)
		begin: l1
		singleLayer #(FRACTION_WIDTH,BIT_WIDTH,INPUTS,INPUTS) l01
							(.clk(clk),.rst(reset),
							.inputs(internalVal[layers-1]),
							.weights(weights[layers]),
							.start(done_[layers-1]),
							.done(done_[layers]),
							.outputs(internalVal[layers])
							);
		end
		endgenerate
		//between final and output layer
		singleLayer #(FRACTION_WIDTH,BIT_WIDTH,INPUTS,OUTPUTS) l_output
							(.clk(clk),.rst(reset),
							.inputs(internalVal[NUM_LAYERS-1]),
							.weights(weights_final),
							.start(done_[NUM_LAYERS-1]),
							.done(done),
							.outputs(outputs)
							);
endmodule