/*********************
**  Mandelbrot fractal
** clang -Xpreprocessor -fopenmp -lomp -o Mandelbrot Mandelbrot.c
** by Dan Garcia <ddgarcia@cs.berkeley.edu>
** Modified for this class by Justin Yokota and Chenyu Shi
**********************/

#include <stdio.h>
#include <stdlib.h>
#include "ComplexNumber.h"
#include "Mandelbrot.h"
#include <sys/types.h>

/*
This function returns the number of iterations before the initial point >= the threshold.
If the threshold is not exceeded after maxiters, the function returns 0.
*/
u_int64_t MandelbrotIterations(u_int64_t maxiters, ComplexNumber * point, double threshold)
{
    //YOUR CODE HERE
    u_int64_t iter_num;
    ComplexNumber *initial, *p;
    ComplexNumber *mul_rs;

    initial = newComplexNumber(0, 0);
    iter_num = 0;
    while (ComplexAbs(initial) < threshold && iter_num < maxiters) {
    	p = initial;
    	mul_rs = ComplexProduct(p, p);
        initial = ComplexSum(mul_rs, point);
    	freeComplexNumber(mul_rs);
    	freeComplexNumber(p);
    	iter_num++;
    }

    double distance = ComplexAbs(initial);
    freeComplexNumber(initial);
    if (distance >= threshold) 
    	return iter_num;
    return 0;
}

/*
This function calculates the Mandelbrot plot and stores the result in output.
The number of pixels in the image is resolution * 2 + 1 in one row/column. It's a square image.
Scale is the the distance between center and the top pixel in one dimension.
*/
void Mandelbrot(double threshold, u_int64_t max_iterations, ComplexNumber* center, double scale, u_int64_t resolution, u_int64_t * output){
    //YOUR CODE HERE
    u_int64_t position;
    ComplexNumber *temp, *initial;
    double step = scale / resolution;

    u_int64_t len = 2 * resolution + 1;
    for(u_int64_t i = 0; i < len; i++) {
    	initial = newComplexNumber(Re(center) - scale, Im(center) + scale - step * i);
    	for(u_int64_t j = 0; j < len; j++) {
    		position = len * i + j;
    		temp = newComplexNumber(Re(initial) + j * step, Im(initial));
    		output[position] = MandelbrotIterations(max_iterations, temp, threshold);
    		freeComplexNumber(temp);
    	}
    	freeComplexNumber(initial);
    }
}

