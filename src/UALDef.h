#ifndef UALDEF_
#define UALDEF_
#include <string>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifdef HAVE_WINDOWS_H
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif

#define INTERPOLATION 3
#define CLOSEST_SAMPLE 1
#define PREVIOUS_SAMPLE 2

      const int EMPTY_INT = -999999999;
      const float EMPTY_FLOAT = -9.0E35;
      const double EMPTY_DOUBLE = -9.0E40;


//Low level function prototypes
extern "C" {
#include <ual_low_level.h>
 }




#endif
