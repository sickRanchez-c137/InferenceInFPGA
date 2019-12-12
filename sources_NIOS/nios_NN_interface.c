/*
File: NIOS interface.c
This file implements a simple NN in C in nios and compares the time it takes for the NIOS C with
the peripheral implemented.
*/
// mandatory include statement
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
// base address for the NN accelerator in DE2-115 computer machine
#define nn_base ((volatile unsigned int*) 0x08200020)
#define nn_input_1 ((volatile unsigned int*) 0x08200020)
#define nn_input_2 ((volatile unsigned int*) 0x08200024)
#define nn_output ((volatile unsigned int*) 0x08200028)

// base address of the interval timer in DE2-115 machine
#define interval_timer_ptr ((volatile unsigned int *) 0xff202000)

// number of iterations to be done for profile operation
// .. final time is average of all the times measured
#define NUM_PROFILE 1
#define NUM_EXAMPLES 7
#define NUM_BITS 9
#define FRACTION_BITS 4

float input_array1[] = { 6.28,-5.63,4.14,5.0,3.5,0.0,5.0 };
float input_array2[] = { 6.27,-5.64,4.13,4.99,3.4,0.0,5.0 };

float weight_array0[] = { -0.1936, -1.2167, -0.4389, 0.3301, -0.4192, -0.0312, -0.1288, -1.2069 };
float weight_array1[] = { 0.0000, -0.1380, 0.6141, 0.1625, 0.0000, 1.0809, -0.7948, -0.7030, -0.0000, -0.2572, 1.8539, 2.5529, -0.0000, 1.3271, -1.5748, -1.5998 };
float weight_array2[] = { 0.0000,-1.8357,1.7187,2.4818 };

float bias0[] = { 1.09838152, -1.49831044, 2.72732628, -1.31490558 };
float bias1[] = { -0.831537276, -1.09912261, 0.000301989131 ,-0.000242028198 };
float bias2[] = { -1.90968533 };

unsigned int input_units = 2;
unsigned int neurons = 4;
unsigned int layers = 2;
unsigned int output_units = 1;

void matMul(float* a_mat[], float* b_mat[], float* output_mat[], unsigned int d1, unsigned int d2,unsigned int d3)
{
	float sum = 0;
	for (unsigned int i = 0; i < d1; i++)
	{
		for (unsigned int j = 0; j < d3; j++)
		{
			sum = 0;
			for (unsigned int k = 0; k < d2; k++)
			{
				sum += a_mat[i][k] * b_mat[k][j];
			}
			output_mat[i][j] = sum;
		}
	}
}

void relu(float* a_mat[], unsigned int d1, unsigned int d2)
{
	for (unsigned int i = 0; i < d1; i++)
	{
		for (unsigned int j = 0; j < d2; j++)
		{
			if (a_mat[i][j] < 0)
			a_mat[i][j] = 0;
		}
	}
}

void biasAdd(float* a_mat[], float* bias, unsigned int d1, unsigned int d2)
{
	for (unsigned int i = 0; i < d1; i++)
	{
		for (unsigned int j = 0; j < d2; j++)
		{
			a_mat[i][j] += bias[j];
		}
	}
}

unsigned long software_time = 0;
unsigned long hardware_time = 0;

void myNNSoftware()
{
	// create space for input values
	float **input_vals = (float**)malloc(1 * sizeof(float*));
	for (unsigned int i = 0; i < 1; i++)
	{
		input_vals[i] = (float*)malloc(input_units * sizeof(float));
	}
	// create weights parameter for Input-H1
	float **w0 = (float**)malloc(input_units * sizeof(float*));
	for (unsigned int i = 0; i < input_units; i++)
	{
		w0[i] = (float*)malloc(neurons * sizeof(float));
	}
	// assign weights here: Input-H1
	for (unsigned int i = 0; i < input_units; i++)
	{
		for (unsigned int j = 0; j < neurons; j++)
			w0[i][j] = weight_array0[i*neurons + j];
	}
	// create space for intermediate values: Input to H1
	float **l1_outs = (float**)malloc(1 * sizeof(float*));
	for (unsigned int i = 0; i < 1; i++)
	{
		l1_outs[0] = (float*)malloc(neurons * sizeof(float));
	}
	// create weights here for H1-H2
	float **w1 = (float**)malloc(neurons * sizeof(float*));
	for (unsigned int i = 0; i < neurons; i++)
	{
		w1[i] = (float*)malloc(neurons * sizeof(float));
	}
	// assign weights here: H1-H2
	for (unsigned int i = 0; i < neurons; i++)
	{
		for (unsigned int j = 0; j < neurons; j++)
			w1[i][j] = weight_array1[i*neurons + j];
	}
	// create space for intermediate values: Output of H1 input of H2
	float **l2_outs = (float**)malloc(1 * sizeof(float*));
	for (unsigned int i = 0; i < 1; i++)
	{
		l2_outs[0] = (float*)malloc(neurons * sizeof(float));
	}
	// create weights here: H2-Output
	float **w2 = (float**)malloc(neurons * sizeof(float*));
	for (unsigned int i = 0; i < neurons; i++)
	{
		w2[i] = (float*)malloc(output_units * sizeof(float));
	}
	// assign weights here: H2:Op
	for (unsigned int i = 0; i < neurons; i++)
	{
		for (unsigned int j = 0; j < output_units; j++)
			w2[i][j] = weight_array2[i*output_units + j];
	}
	// create space for intermediate values: Output of H2
	float **l3_outs = (float**)malloc(1 * sizeof(float*));
	for (unsigned int i = 0; i < 1; i++)
	{
		l3_outs[0] = (float*)malloc(output_units * sizeof(float));
	}
	// we will count the number of cc here
	software_time = 0;
	for (unsigned int times_ = 0; times_ < NUM_PROFILE; times_++)
	{
		for (unsigned int iter = 0; iter < NUM_EXAMPLES; iter++)
		{
			//.. since the timer will count downwards, let us give maximum 32-bit value
			*(interval_timer_ptr + 2) = 0xffff;
			*(interval_timer_ptr + 3) = 0xffff;

			// continuous mode and start counting
			*(interval_timer_ptr + 1) = 0x06;

			input_vals[0][0] = input_array1[iter];
			input_vals[0][1] = input_array2[iter];

			// following implements the layer between the input and H1
			matMul(input_vals, w0, l1_outs, 1, input_units, neurons);
			biasAdd(l1_outs, bias0, 1, neurons);
			relu(l1_outs, 1, neurons);

			// following implements the layer between the H1 and H2
			matMul(l1_outs, w1, l2_outs, 1, neurons, neurons);
			biasAdd(l2_outs, bias1, 1, neurons);
			relu(l2_outs, 1, neurons);

			// following implements the layer between the H2 and output
			matMul(l2_outs, w2, l3_outs, 1, neurons, output_units);
			biasAdd(l3_outs, bias2, 1, output_units);
			relu(l3_outs, 1, output_units);

			//once the opration is done, we will grab the snapshot value
			*(interval_timer_ptr + 4) = 1;

			//let us stop it
			*(interval_timer_ptr + 1) = 0x08;
			software_time += (4294967295 - (*(interval_timer_ptr + 5)) * 65536 -
			*(interval_timer_ptr + 4));
			printf("SW (%d): For ip1=%4.4f and ip2=%4.4f, \n\tpredicted is %4.4f (Class %d)\n", iter, input_array1[iter], input_array2[iter], l3_outs[0][0], l3_outs[0][0] > 0 ? 1 : 0);
		}
	}
	// freeing stuffs
	for (unsigned int i = 0; i < 1; i++)
	{
		free(input_vals[i]);
	}
	free(input_vals);
	for (unsigned int i = 0; i < input_units; i++)
	{
		free(w0[i]);
	}
	free(w0);
	free(l1_outs[0]);
	free(l1_outs);
	free(l2_outs[0]);
	free(l2_outs);
	free(l3_outs[0]);
	free(l3_outs);
	for (unsigned int i = 0; i < neurons; i++)
	{
		free(w1[i]);
	}
	free(w1);
	for (unsigned int i = 0; i < neurons; i++)
	{
		free(w2[i]);
	}
	free(w2);
}
// this function converts the input float to fixed point representation
unsigned int convertFixedPoint(float myIn)
{
	unsigned int retVal = 0;
	float fractPart = 0;
	if (myIn < 0)
	{
		retVal = 0x01;
	}
	myIn = fabsf(myIn);
	fractPart = myIn - ((long)myIn);
	// let us first deal with the whole number part
	for (int bitCount = NUM_BITS - FRACTION_BITS - 1 - 1; bitCount >= 0; bitCount--)
	{
		//shift one position to the left
		retVal <<= 1;
		if (myIn >= (0x01 << bitCount))
		{
			retVal |= 0x01;
			myIn -= 0x01 << bitCount;
		}
	}
	float div = 0.5;
	// for the fractional part
	for (unsigned int bitCount = FRACTION_BITS; bitCount > 0; bitCount--)
	{
		//shift one position to the left
		retVal <<= 1;
		if (fractPart >= (div))
		{
			retVal |= 0x01;
			fractPart -= div;
		}
		div /= 2;
	}
	return retVal;
}

float convertToFloat(unsigned int inVal)
{
	float retVal = 0;
	float mul = 0.5;
	for (int i = FRACTION_BITS - 1; i >= 0; i--)
	{
		if (inVal&(1 << i))
		{
		retVal += mul;
		}
		mul /= 2;
	}
	for (unsigned int i = FRACTION_BITS; i < NUM_BITS - 1; i++)
	{
		if (inVal&(1 << i))
		{
		retVal += (1 << (i - FRACTION_BITS));
		}
	}
	if (inVal&(1 << (NUM_BITS - 1)))
		retVal = 0 - retVal;
	return retVal;
}

void myNNHardware()
{
	// we will count the number of cc here
	hardware_time = 0;
	unsigned int myOut = 5;
	unsigned int myIn1 = 0;
	unsigned int myIn2 = 0;
	for (unsigned int times_ = 0; times_ < NUM_PROFILE; times_++)
	{
		for (unsigned int iter = 0; iter < NUM_EXAMPLES; iter++)
		{
			myIn1 = convertFixedPoint(input_array1[iter]);
			myIn2 = convertFixedPoint(input_array2[iter]);
			//.. since the timer will count downwards, let us give maximum 32-bit value
			*(interval_timer_ptr + 2) = 0xffff;
			*(interval_timer_ptr + 3) = 0xffff;
			// continuous mode and start counting
			*(interval_timer_ptr + 1) = 0x06;
			//convert to fixed point representation
			*nn_input_1 = myIn1;
			*nn_input_2 = myIn2;
			// a simple delay
			// for(volatile unsigned int i=0;i<2;i++);
			myOut = *nn_output;
			//once the opration is done, we will grab the snapshot value
			*(interval_timer_ptr + 4) = 1;
			//let us stop it
			*(interval_timer_ptr + 1) = 0x08;
			hardware_time += (4294967295 - (*(interval_timer_ptr + 5)) * 65536 -
			*(interval_timer_ptr + 4));
			printf("HW(%d): For ip1=%4.4f(0x%x) and ip2=%4.4f(0x%x), \n\tpredicted is %4.4f(0x%x) (Class %d)\n", iter, input_array1[iter], *nn_input_1, input_array2[iter], *nn_input_2,convertToFloat(myOut), myOut, myOut > 0 ? 1 : 0);
		}
	}
}
int main(void)
{
	printf("Welcome to the NN machine in DE2-115 machine\n");
	printf("---------------------------------------------\n");
	char userIp = 'N';
	while (1)
	{
		printf("This code profiles time taken to run the software implementation vs hardware implementation\n");
		printf("Software Implementation Follows\n");
		software_time = 0;
		myNNSoftware();
		printf("Software Implementation took %lu clock cycles\n", software_time);
		hardware_time = 0;
		myNNHardware();
		printf("Hardware Implementation took %lu clock cycles\n", hardware_time);
		printf("Do you want to go again to measure?\n");
		scanf("%c", &userIp);
		if (userIp != 'Y' && userIp != 'y')
		break;
	}
	printf("Thank you for using the NN accelerator\n");
	return 0;
}