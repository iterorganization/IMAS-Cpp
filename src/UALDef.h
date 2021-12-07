#ifndef UALDEF_
#define UALDEF_
#include <string>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#ifdef __GNUC__
#  include <complex.h>
#else
#  include <iostream>
#  include <cmath>
#  include <complex>
#  include <complex.h>
#endif


#undef I

#ifdef _WIN32
#  define EXPORT __declspec(dllexport)
#else
#  define EXPORT
#endif

#define INTERPOLATION 3
#define CLOSEST_SAMPLE 1
#define PREVIOUS_SAMPLE 2

#include <blitz/memblock.h>
#include <blitz/array.h>


typedef std::complex < double > std_complex_t;

 static    const int EMPTY_INT = -999999999;
 static     const float EMPTY_FLOAT = -9.0E35;
 static     const double EMPTY_DOUBLE = -9.0E40;
 static const std_complex_t EMPTY_COMPLEX = std_complex_t(EMPTY_DOUBLE, EMPTY_DOUBLE);


 static const int   IDS_TIME_MODE_UNKNOWN       = EMPTY_INT; 
 static const int   IDS_TIME_MODE_HETEROGENEOUS = 0;
 static const int   IDS_TIME_MODE_HOMOGENEOUS   = 1;
 static const int   IDS_TIME_MODE_INDEPENDENT   = 2;


template <typename P_numtype, int N_rank>
class IMASArray : public blitz::Array<P_numtype, N_rank> 
{
    using  blitz::Array<P_numtype, N_rank>::Array;

    private:
        blitz::preexistingMemoryPolicy deletionPolicy = blitz::duplicateData;

    public:
        blitz::preexistingMemoryPolicy getDeletionPolicy(){
            return this->deletionPolicy;
        }

        void setDeletionPolicy(blitz::preexistingMemoryPolicy deletionPolicy){
            this->deletionPolicy = deletionPolicy;
        }
};


//Low level function prototypes
//extern "C" {
#include <ual_lowlevel.h>
 //}




#endif
