#include <time.h>
#include <stdio.h>
#include <x86intrin.h>
#include "common.h"

long long int sum(unsigned int vals[NUM_ELEMS]) {
	clock_t start = clock();

	long long int sum = 0;
	for(unsigned int w = 0; w < OUTER_ITERATIONS; w++) {
		for(unsigned int i = 0; i < NUM_ELEMS; i++) {
			if(vals[i] >= 128) {
				sum += vals[i];
			}
		}
	}
	clock_t end = clock();
	printf("Time taken: %Lf s\n", (long double)(end - start) / CLOCKS_PER_SEC);
	return sum;
}

long long int sum_unrolled(unsigned int vals[NUM_ELEMS]) {
	clock_t start = clock();
	long long int sum = 0;

	for(unsigned int w = 0; w < OUTER_ITERATIONS; w++) {
		for(unsigned int i = 0; i < NUM_ELEMS / 4 * 4; i += 4) {
			if(vals[i] >= 128) sum += vals[i];
			if(vals[i + 1] >= 128) sum += vals[i + 1];
			if(vals[i + 2] >= 128) sum += vals[i + 2];
			if(vals[i + 3] >= 128) sum += vals[i + 3];
		}

		//This is what we call the TAIL CASE
		//For when NUM_ELEMS isn't a multiple of 4
		//NONTRIVIAL FACT: NUM_ELEMS / 4 * 4 is the largest multiple of 4 less than NUM_ELEMS
		for(unsigned int i = NUM_ELEMS / 4 * 4; i < NUM_ELEMS; i++) {
			if (vals[i] >= 128) {
				sum += vals[i];
			}
		}
	}
	clock_t end = clock();
	printf("Time taken: %Lf s\n", (long double)(end - start) / CLOCKS_PER_SEC);
	return sum;
}

long long int sum_simd(unsigned int vals[NUM_ELEMS]) {
	clock_t start = clock();
	__m128i _127 = _mm_set1_epi32(127);		// This is a vector with 127s in it... Why might you need this?
	long long int result = 0;				// This is where you should put your final result!
											// DO NOT DO NOT DO NOT DO NOT WRITE ANYTHING ABOVE THIS LINE.
	for(unsigned int w = 0; w < OUTER_ITERATIONS; w++) {
		/* YOUR CODE GOES HERE */
		unsigned int arr[4];
		__m128i rs = _mm_setzero_si128();
		for(unsigned int i = 0; i < NUM_ELEMS / 4 * 4; i += 4) {
			__m128i data = _mm_loadu_si128((__m128i *) (vals + i));
			__m128i immediate = _mm_cmpgt_epi32(data, _127);
			data = _mm_and_si128(data, immediate);
			rs = _mm_add_epi32(data, rs);
		}
		_mm_storeu_si128((__m128i *) arr, rs);
		/* You'll need a tail case. */
		for(unsigned int i = NUM_ELEMS / 4 * 4; i < NUM_ELEMS; i++) {
			if (vals[i] >= 128) {
				arr[0] += vals[i];
			}
		}
		result = result + arr[0] + arr[1] + arr[2] + arr[3];
	}
	clock_t end = clock();
	printf("Time taken: %Lf s\n", (long double)(end - start) / CLOCKS_PER_SEC);
	return result;
}

long long int sum_simd_unrolled(unsigned int vals[NUM_ELEMS]) {
	clock_t start = clock();
	__m128i _127 = _mm_set1_epi32(127);
	long long int result = 0;
	for(unsigned int w = 0; w < OUTER_ITERATIONS; w++) {
		/* COPY AND PASTE YOUR sum_simd() HERE */
		/* MODIFY IT BY UNROLLING IT */
		unsigned int arr[4];
		__m128i rs = _mm_setzero_si128();
		for(unsigned int i = 0; i < NUM_ELEMS / 16 * 16; i += 16) {
			__m128i data_0 = _mm_loadu_si128((__m128i *) (vals + i));
			__m128i data_1 = _mm_loadu_si128((__m128i *) (vals + i + 4));
			__m128i data_2 = _mm_loadu_si128((__m128i *) (vals + i + 8));
			__m128i data_3 = _mm_loadu_si128((__m128i *) (vals + i + 12));
			data_0 = _mm_and_si128(data_0, _mm_cmpgt_epi32(data_0, _127));
			data_1 = _mm_and_si128(data_1, _mm_cmpgt_epi32(data_1, _127));
			data_2 = _mm_and_si128(data_2, _mm_cmpgt_epi32(data_2, _127));
			data_3 = _mm_and_si128(data_3, _mm_cmpgt_epi32(data_3, _127));
			rs = _mm_add_epi32(data_0, rs);
			rs = _mm_add_epi32(data_1, rs);
			rs = _mm_add_epi32(data_2, rs);
			rs = _mm_add_epi32(data_3, rs);
		}
		_mm_storeu_si128((__m128i *) arr, rs);
		/* You'll need 1 or maybe 2 tail cases here. */
		for(unsigned int i = NUM_ELEMS / 16 * 16; i < NUM_ELEMS; i++) {
			if (vals[i] >= 128) {
				arr[0] += vals[i];
			}
		}
		result = result + arr[0] + arr[1] + arr[2] + arr[3];
	}
	clock_t end = clock();
	printf("Time taken: %Lf s\n", (long double)(end - start) / CLOCKS_PER_SEC);
	return result;
}