/*********************
**  Mandelbrot fractal movie generator
** clang -Xpreprocessor -fopenmp -lomp -o Mandelbrot Mandelbrot.c
** by Dan Garcia <ddgarcia@cs.berkeley.edu>
** Modified for this class by Justin Yokota and Chenyu Shi
**********************/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include "ComplexNumber.h"
#include "Mandelbrot.h"
#include "ColorMapInput.h"
#include <sys/types.h>
#include <string.h>

void printUsage(char* argv[])
{
  printf("Usage: %s <threshold> <maxiterations> <center_real> <center_imaginary> "
         "<initialscale> <finalscale> <framecount> <resolution> <output_folder> <colorfile>\n", argv[0]);
  printf("    This program simulates the Mandelbrot Fractal, and creates an iteration map of the given center, scale, and resolution, then saves it in output_file\n");
}


/*
This function calculates the threshold values of every spot on a sequence of frames. The center stays the same throughout the zoom. First frame is at initialscale, and last frame is at finalscale scale.
The remaining frames form a geometric sequence of scales, so 
if initialscale=1024, finalscale=1, framecount=11, then your frames will have scales of 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1.
As another example, if initialscale=10, finalscale=0.01, framecount=5, then your frames will have scale 10, 10 * (0.01/10)^(1/4), 10 * (0.01/10)^(2/4), 10 * (0.01/10)^(3/4), 0.01 .
*/
void MandelMovie(double threshold, u_int64_t max_iterations, ComplexNumber* center, double initialscale, double finalscale, int framecount, u_int64_t resolution, u_int64_t ** output){
    //YOUR CODE HERE
    double step = pow(exp(1), log(finalscale / initialscale) / (framecount - 1));
    double scale;
    for (int i = 0; i < framecount; i++) {
        scale = initialscale * pow(step, i);
        Mandelbrot(threshold, max_iterations, center, scale, resolution, output[i]);
    }
}

void color_transform(uint64_t *iters, uint64_t size, uint8_t **colormap, int color_count, uint8_t *s);
/**************
**This main function converts command line inputs into the format needed to run MandelMovie.
**It then uses the color array from FileToColorMap to create PPM images for each frame, and stores it in output_folder
***************/
int main(int argc, char* argv[])
{
	//Tips on how to get started on main function: 
	//MandelFrame also follows a similar sequence of steps; it may be useful to reference that.
	//Mayke you complete the steps below in order. 

	//STEP 1: Convert command line inputs to local variables, and ensure that inputs are valid.
	/*
	Check the spec for examples of invalid inputs.
	Remember to use your solution to B.1.1 to process colorfile.
	*/

	//YOUR CODE HERE 
    if (argc != 11) {
        printf("%s: Wrong number of arguments, expecting 10\n", argv[0]);
        printUsage(argv);
        return 1;
    }
    int framecount;
    double threshold, scale;
    ComplexNumber *center;
    double initialscale, finalscale;
    u_int64_t max_iterations, resolution;
    char *output_folder, *colorfile;

    /*Read parameters in argv, similar to the procedure in reference code.*/
    threshold = atof(argv[1]);
    max_iterations = (u_int64_t)atoi(argv[2]);
    center = newComplexNumber(atof(argv[3]), atof(argv[4]));
    initialscale = atof(argv[5]);
    finalscale = atof(argv[6]);
    framecount = atoi(argv[7]);
    resolution = (u_int64_t)atoi(argv[8]);
    output_folder = argv[9];
    colorfile = argv[10];

    //check for threshold, scale, max_iterations.
    if (threshold <= 0 || initialscale <= 0 || finalscale <= 0 || max_iterations <= 0) {
        printf("The threshold, scale, and max_iterations must be > 0");
        printUsage(argv);
        return 1;
    }

    //check for frame count.
    if (framecount > 10000 || framecount <= 0) {
        printf("The framecount should be in the range of 1 to 9999");
        printUsage(argv);
        return 1;
    }

    //check for resolution.
    if (resolution < 0) {
        printf("The resolution must be none-negative");
        printUsage(argv);
        return 1;
    }

    //check for scale condition.
    if (framecount == 1 && initialscale != finalscale) {
        printf("The initialscale must be equal to finalscale when frame count = 1");
        printUsage(argv);
        return 1;
    }

    int color_count;
    u_int64_t size = 2 * resolution + 1;
    uint8_t** input = FileToColorMap(colorfile, &color_count);

	//STEP 2: Run MandelMovie on the correct arguments.
	/*
	MandelMovie requires an output array, so make sure you allocate the proper amount of space. 
	If allocation fails, free all the space you have already allocated (including colormap), then return with exit code 1.
	*/

	//YOUR CODE HERE 
    u_int64_t **output = (u_int64_t **)calloc(framecount, sizeof(u_int64_t *));

    //Check whether calloc fails
    if (output == NULL) {
        printf("The calloc for output fails");
        free_input(input, color_count);
        return 1;
    }

    //Allocate memory for output and check whether it fails
    for (int i = 0; i < framecount; i++) {
        output[i] = (u_int64_t *)calloc(size * size, sizeof(u_int64_t));
        if (output[i] == NULL) {
            for (int j = 0; j < i; j++) {
                free(output[j]);
                printf("The calloc for output data fails");
                return 1;
            }
        }
    }

    MandelMovie(threshold, max_iterations, center, initialscale, finalscale, framecount,
                resolution, output);

	//STEP 3: Output the results of MandelMovie to .ppm files.
	/*
	Convert from iteration count to colors, and output the results into output files.
	Use what we showed you in Part B.1.2, create a seqeunce of ppm files in the output folder.
	Feel free to create your own helper function to complete this step.
	As a reminder, we are using P6 format, not P3.
	*/

	/* My general Idea:
	 * colorPalette.c doesn't help a lot here. Instead, it just gives some intuition
	 * of how to finish this task.
	 * Better draw the INPUT and OUTPUT in a notebook, and the function
	 * transform_color is to connect these two and convert the result in a single
	 * uint_8 array. Then use fwrite similar in P6, the task can be simply done.
	 * 
	 */

	//YOUR CODE HERE
	uint8_t *s = (uint8_t *)malloc(3 * size * size * sizeof(uint8_t));
	char buffer[strlen(output_folder) + strlen("/frame00000.ppm") + 1];

	for (int i = 0; i < framecount; i++) {
	    sprintf(buffer, "%s%s%05d%s", output_folder, "/frame", i, ".ppm");
	    FILE *file = fopen(buffer, "w+");
	    color_transform(output[i], size, input, color_count, s);
	    fprintf(file, "%s %llu %llu %d\n", "P6", size, size, 255);
	    fwrite(s, 1, 3 * size * size, file);
	    fclose(file);
	}

	//STEP 4: Free all allocated memory
	/*
	Make sure there's no memory leak.
	*/
	//YOUR CODE HERE 

	free(s);
	free_input(input, color_count);
	for (int i = 0; i < framecount; i++)
	    free(output[i]);
	free(output);
	freeComplexNumber(center);

	return 0;
}

/* transform the iterate number into corresponding color to the uint_8 s. */
void color_transform(uint64_t *iters, uint64_t size, uint8_t **colormap, int color_count, uint8_t *s)
{
    int select;
    int index = 0;
    for (int i = 0; i < size * size; i++) {
        select = iters[i] % color_count - 1;
        if (select < 0) {
            for (int j = 0; j < 3; j++) {
                s[index] = 0;
                index++;
            }
        } else {
            for (int j = 0; j < 3; j++) {
                s[index] = colormap[select][j];
                index++;
            }
        }
    }
}

