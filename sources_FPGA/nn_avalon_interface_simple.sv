/*
File: 			nn_avalon_interface.sv
Description:	This module instantiates 
Author:			Prawar Poudel
License:			No String Attached, use as you wish. Usability not guaranteed.
*/

/*
	Further description:
		S_Reg[0]: 	gcd is computed,  output
		S_Reg[1]:	loadA from inReg, input
		S_Reg[2]:	loadB from inReg, input
		S_Reg[3]:	start computation, input
*/

module nn_avalon_interface #(parameter W=32, parameter FRACTION_WIDTH = 4, parameter BIT_WIDTH = 9,
										parameter NUM_LAYERS = 2, parameter num_input_units = 2, parameter num_output_units = 1,
										parameter num_neurons = 4)
										
(input logic clock,reset,input logic [2:0] address, input logic [W-1:0] writedata, output logic [W-1:0] readdata, input write, read, chipselect);
	
	logic [BIT_WIDTH-1:0] inputValue[num_input_units-1:0];
	logic [BIT_WIDTH-1:0] outputPrediction[num_output_units-1:0];
	
	logic [W-1:0] S_reg;
	
	logic start,done;
	
	assign start = S_reg[3];
	
	myNeuralNet #(FRACTION_WIDTH , BIT_WIDTH, NUM_LAYERS,num_input_units,num_output_units,num_neurons)
						myNN (clock, reset,start,done,inputValue,outputPrediction);
						
	always@(posedge clock)
	begin
		if(reset)
		begin
			inputValue[0] = {BIT_WIDTH{1'b0}};
			inputValue[1] = {BIT_WIDTH{1'b0}};
		end
		else if(chipselect == 1'b1 && write == 1'b1)
		begin
			case(address)
				3'b000: 
					begin
						inputValue[0] = writedata[BIT_WIDTH-1:0];
					end
				3'b001: 
					begin
						inputValue[1] = writedata[BIT_WIDTH-1:0];
					end
				default:
					begin
						inputValue[0] = writedata[BIT_WIDTH-1:0];
					end
			endcase
		end
	end
			
	always_comb
	begin
		if(chipselect == 1'b1 && read == 1'b1)
		begin
			case(address)
				3'b000: readdata[BIT_WIDTH-1:0] = inputValue[0];
				3'b001: readdata[BIT_WIDTH-1:0] = inputValue[1];
				3'b010: readdata[BIT_WIDTH-1:0] = outputPrediction[0];
				default: readdata[BIT_WIDTH-1:0] = outputPrediction[0];
			endcase
		end
		else
			readdata[BIT_WIDTH-1:0] = outputPrediction[0];
	end	
endmodule