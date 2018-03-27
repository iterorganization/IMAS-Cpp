#ifndef _IDS_CLASS

#define _IDS_CLASS

#define BZ_THREADSAFE
#include <blitz/array.h>
using namespace blitz;

#define NON_TIMED    0
#define TIMED       1
#define TIMED_CLEAR 2
/*#define DEBUG*/


void checkStatus(int status);

char * str2char(string str);

string int2str(int i, int j);


void checkObject(void *obj);

namespace IdsNs {
class Ids
{
    protected:
        void setArray(blitz::Array<int,1>&array,int *arrayPtr, int dim1);
        
        void setArray(blitz::Array<float,1>&array,float *arrayPtr, int dim1);
  
        void setArray(blitz::Array<double,1>&array,double *arrayPtr, int dim1);

        void setArray(blitz::Array<int,2>&array,int *arrayPtr, int dim1, int dim2);

        void setArray(blitz::Array<float,2>&array,float *arrayPtr, int dim1, int dim2);

        void setArray(blitz::Array<double,2>&array,double *arrayPtr, int dim1, int dim2);

        void setArray(blitz::Array<int,3>&array,int *arrayPtr, int dim1, int dim2, int dim3);

        void setArray(blitz::Array<float,3>&array,float *arrayPtr, int dim1, int dim2, int dim3);

        void setArray(blitz::Array<double,3>&array,double *arrayPtr, int dim1, int dim2, int dim3);

        void setArray(blitz::Array<int,4>&array,int *arrayPtr, int dim1, int dim2, int dim3, int dim4);
   
        void setArray(blitz::Array<float,4>&array,float *arrayPtr, int dim1, int dim2, int dim3, int dim4);
   
        void setArray(blitz::Array<double,4>&array,double *arrayPtr, int dim1, int dim2, int dim3, int dim4);
    

        void setArray(blitz::Array<int,5>&array,int *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5);
   
        void setArray(blitz::Array<float,5>&array,float *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5);
     
        void setArray(blitz::Array<double,5>&array,double *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5);
   

        void setArray(blitz::Array<int,6>&array,int *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6);
  
        void setArray(blitz::Array<float,6>&array,float *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6);
   
        void setArray(blitz::Array<double,6>&array,double *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6);

    

};
}
#endif // _IDS_CLASS
