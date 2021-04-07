/*********************
**  Color Map generator
** Skeleton by Justin Yokota
**********************/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <string.h>
#include "ColorMapInput.h"


/**************
**This function reads in a file name colorfile.
**It then uses the information in colorfile to create a color array, with each color represented by an int[3].
***************/
uint8_t** FileToColorMap(char* colorfile, int* colorcount)
{
	//YOUR CODE HERE
	int count;
	int a , b, c;

	a = b = c = 0;
    FILE* file = fopen(colorfile, "r");
    if (file == NULL)
    {
        printf("no such file.");
        return NULL;
    }
    if (fscanf(file, "%d", &count) != 1)
    {
        printf("unfit the pattern specified");
        return NULL;
    }
    uint8_t** rs = (uint8_t**)calloc(count, sizeof(uint8_t *));
    for (int i = 0; i < count; i++){
        if(fscanf(file, "%d %d %d", &a, &b, &c) != 3) {
            printf("unfit the pattern specified");
            /*free all the memory allocated before. */
            for(int j = 0; j < i; j++)
                free(rs[j]);
            free(rs);
            return NULL;
        }
        rs[i] = (uint8_t*) calloc(3, sizeof(uint8_t));
        rs[i][0] = a;
        rs[i][1] = b;
        rs[i][2] = c;
    }
    *colorcount = count;
    fclose(file);
    return rs;
}

void free_input(uint8_t **input, int color_count)
{
    for (int i = 0; i < color_count; i++)
        free(input[i]);
    free(input);
}
