#ifndef UALDEF_
#define UALDEF_
#include <string>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <complex.h>
#undef I

#ifdef HAVE_WINDOWS_H
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif

#define INTERPOLATION 3
#define CLOSEST_SAMPLE 1
#define PREVIOUS_SAMPLE 2


typedef std::complex < double > std_complex_t;

typedef double _Complex ual_complex_t;

 static    const int EMPTY_INT = -999999999;
 static     const float EMPTY_FLOAT = -9.0E35;
 static     const double EMPTY_DOUBLE = -9.0E40;
 static const std_complex_t EMPTY_COMPLEX = std_complex_t(EMPTY_DOUBLE, EMPTY_DOUBLE);




//Low level function prototypes
//extern "C" {
#include <ual_lowlevel.h>
 //}




#endif
