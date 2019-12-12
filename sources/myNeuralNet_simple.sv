/* 
File: myNeuralNet_simple.sv 
Input: 
Function: operation a simple NN 
Output: Output is the prediction. If a digit 0 is detected, BIT0 is 1 and all others are 0 and so on 
Parameters: Q: size of fractional part, N: width of each data			 


Code Written by: Sorty MMith (sortymmith@outlook.com)
 2019-12-09 

*/
module myNeuralNet #(parameter FRACTION_WIDTH = 4, parameter BIT_WIDTH = 9,
						parameter NUM_LAYERS = 2, parameter num_input_units = 2, parameter num_output_units = 1,
                        parameter num_neurons = 4)
						(input logic clk, rst,
						input logic start, 
						output logic done,
                        input logic [BIT_WIDTH-1:0] inputs[num_input_units-1:0], 
                        output logic [BIT_WIDTH-1:0] outputs[num_output_units-1:0]); 
                        
logic [BIT_WIDTH-1:0] weights_input_layer[num_input_units-1:0][num_neurons-1:0];
logic [BIT_WIDTH-1:0] weights_output_layer[num_neurons-1:0][num_output_units-1:0];
logic [BIT_WIDTH-1:0] weights_0[num_neurons-1:0][num_neurons-1:0];


logic [BIT_WIDTH-1:0] inter_0[num_neurons-1:0];
logic done_0;
logic [BIT_WIDTH-1:0] inter_1[num_neurons-1:0];
logic done_1;


assign weights_input_layer[0][0]=9'b100000011;
assign weights_input_layer[0][1]=9'b100010011;
assign weights_input_layer[0][2]=9'b100000111;
assign weights_input_layer[0][3]=9'b000000101;
assign weights_input_layer[1][0]=9'b100000110;
assign weights_input_layer[1][1]=9'b100000000;
assign weights_input_layer[1][2]=9'b100000010;
assign weights_input_layer[1][3]=9'b100010011;


assign weights_0[0][0]=9'b000000000;
assign weights_0[0][1]=9'b100000010;
assign weights_0[0][2]=9'b000001001;
assign weights_0[0][3]=9'b000000010;
assign weights_0[1][0]=9'b000000000;
assign weights_0[1][1]=9'b000010001;
assign weights_0[1][2]=9'b100001100;
assign weights_0[1][3]=9'b100001011;
assign weights_0[2][0]=9'b000000000;
assign weights_0[2][1]=9'b100000100;
assign weights_0[2][2]=9'b000011101;
assign weights_0[2][3]=9'b000101000;
assign weights_0[3][0]=9'b000000000;
assign weights_0[3][1]=9'b000010101;
assign weights_0[3][2]=9'b100011001;
assign weights_0[3][3]=9'b100011001;


assign weights_output_layer[0][0]=9'b000000000;
assign weights_output_layer[1][0]=9'b100011101;
assign weights_output_layer[2][0]=9'b000011011;
assign weights_output_layer[3][0]=9'b000100111;


singleLayerInput #(FRACTION_WIDTH,BIT_WIDTH,num_input_units,num_neurons) 
        sL_input (clk,rst,inputs,weights_input_layer,start,done_0,inter_0);

singleLayer #(FRACTION_WIDTH,BIT_WIDTH,num_neurons,num_neurons) 
        sL_1 (clk,rst,inter_0,weights_0,start,done_1,inter_1);

singleLayerOutput #(FRACTION_WIDTH,BIT_WIDTH,num_neurons,num_output_units) 
        sL_output (clk,rst,inter_1,weights_output_layer,start,done,outputs);


endmodule

