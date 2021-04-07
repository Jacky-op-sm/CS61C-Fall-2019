/*********************
**  Color Palette generator
** Skeleton by Justin Yokota
**********************/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <string.h>
#include "ColorMapInput.h"

//You don't need to call this function but it helps you understand how the arguments are passed in 
void usage(char* argv[])
{
	printf("Incorrect usage: Expected arguments are %s <inputfile> <outputfolder> <width> <heightpercolor>", argv[0]);
}

//Creates a color palette image for the given colorfile in outputfile. Width and heightpercolor dictates the dimensions of each color. Output should be in P3 format
int P3colorpalette(char* colorfile, int width, int heightpercolor, char* outputfile) {
    //YOUR CODE HERE
    int count = 0;
    uint8_t **input = FileToColorMap(colorfile, &count);
    if (input == NULL || width < 1 || heightpercolor < 1)
        return 1;
    FILE *output = fopen(outputfile, "w");
    int lines = heightpercolor * count;
    fprintf(output, "%s %d %d %d\n", "P3", width, lines, 255);
    for (int i = 0; i < lines; i++)
        for (int j = 0; j < width; j++) {
            int p = i / heightpercolor;
            if (j == width - 1)
                fprintf(output, "%d %d %d\n", input[p][0], input[p][1], input[p][2]);
            else
                fprintf(output, "%d %d %d ", input[p][0], input[p][1], input[p][2]);
        }
    /* free up the allocated memory. */
    for (int i = 0; i < count; i++)
        free(input[i]);
    free(input);
    fclose(output);
	return 0;
}

//Same as above, but with P6 format
int P6colorpalette(char* colorfile, int width, int heightpercolor, char* outputfile)
{
    //YOUR CODE HERE
    int count = 0;
    uint8_t **input = FileToColorMap(colorfile, &count);
    if (input == NULL || width < 1 || heightpercolor < 1)
        return 1;
    FILE *output = fopen(outputfile, "w");
    fprintf(output, "%s %d %d %d\n", "P6", width, heightpercolor * count, 255);
    for(int i = 0; i < count; i++)
        for(int j = 0; j < heightpercolor; j++)
            for(int k = 0; k < width; k++)
                fwrite(input[i], 1, 3, output);

    /* free up the allocated memory. */
    for (int i = 0; i < count; i++)
        free(input[i]);

    free(input);
    fclose(output);
    return 0;
}


//The one piece of c code you don't have to read or understand. Still, might as well read it, if you have time.
int main(int argc, char* argv[])
{
	if (argc != 5)
	{
		usage(argv);
		return 1;
	}
	int width = atoi(argv[3]);
	int height = atoi(argv[4]);
	char* P3end = "/colorpaletteP3.ppm";
	char* P6end = "/colorpaletteP6.ppm";
	char buffer[strlen(argv[2]) + strlen(P3end)+1];
	sprintf(buffer, "%s%s", argv[2], P3end);
	int failed = P3colorpalette(argv[1], width, height, buffer);
	if (failed)
	{
		printf("Error in making P3colorpalette");
		return 1;
	}
	sprintf(buffer, "%s%s", argv[2], P6end);
	failed = P6colorpalette(argv[1], width, height, buffer);
	if (failed)
	{
		printf("Error in making P6colorpalette");
		return 1;
	}
	printf("P3colorpalette and P6colorpalette ran without error, output should be stored in %s%s, %s%s", argv[2], P3end, argv[2], P6end);
	return 0;
}




