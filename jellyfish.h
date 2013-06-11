#ifndef _JELLYFISH_H_
#define _JELLYFISH_H_

// changes to make it compile on VC, no support for C99
typedef int bool;
#define false 0
#define true 1
#ifndef inline
	#define inline __inline
#endif
#ifndef isnan
	#define isnan _isnan
#endif
#include <float.h>
#ifdef _MSC_VER
	#define INFINITY (DBL_MAX+DBL_MAX)
	#define NaN (INFINITY-INFINITY)
#endif
//#include <stdbool.h>
#include <stdlib.h>

#ifndef MIN
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#endif

double jaro_winkler(const char *str1, const char *str2, bool long_tolerance);
double jaro_distance(const char *str1, const char *str2);

size_t hamming_distance(const char *str1, const char *str2);

int levenshtein_distance(const char *str1, const char *str2);

int damerau_levenshtein_distance(const char *str1, const char *str2);

char* soundex(const char *str);

char* metaphone(const char *str);

char *nysiis(const char *str);

char* match_rating_codex(const char *str);
int match_rating_comparison(const char *str1, const char *str2);

struct stemmer;
extern struct stemmer * create_stemmer(void);
extern void free_stemmer(struct stemmer * z);
extern int stem(struct stemmer * z, char * b, int k);

#endif
