#include <blitz/array.h>
#include "IdsDef.h"
using namespace blitz;
using namespace IdsNs;


#ifdef DEBUG
void checkStatus(int status) {if(status) printf("%s\n", imas_last_errmsg());}
#else
void checkStatus(int status){}
#endif

char * str2char(string str)
{
char *cyb;
cyb = new char[512];
strcpy(cyb, str.c_str());
return cyb;
}

string int2str(int i, int j)
{
int r;
r= i+j;
ostringstream convert;   // stream used for the conversion
convert << r;      // insert the textual representation of 'Number' in the characters in the stream

return(convert.str());
}


void checkObject(void *obj)
{
    if (!obj) printf("Problem with array of structure allocation\n");
}


        void IdsNs::Ids::setArray(blitz::Array<int,1>&array,int *arrayPtr, int dim1)
        {
            blitz::Array<int,1> newArray(arrayPtr, shape(dim1), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void IdsNs::Ids::setArray(blitz::Array<float,1>&array,float *arrayPtr, int dim1)
        {
            blitz::Array<float,1> newArray(arrayPtr, shape(dim1), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void IdsNs::Ids::setArray(blitz::Array<double,1>&array,double *arrayPtr, int dim1)
        {
            blitz::Array<double,1> newArray(arrayPtr, shape(dim1), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void IdsNs::Ids::setArray(blitz::Array<int,2>&array,int *arrayPtr, int dim1, int dim2)
        {
            blitz::Array<int,2> newArray(arrayPtr, shape(dim1, dim2), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void IdsNs::Ids::setArray(blitz::Array<float,2>&array,float *arrayPtr, int dim1, int dim2)
        {
            blitz::Array<float,2> newArray(arrayPtr, shape(dim1, dim2), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void IdsNs::Ids::setArray(blitz::Array<double,2>&array,double *arrayPtr, int dim1, int dim2)
        {
            blitz::Array<double,2> newArray(arrayPtr, shape(dim1, dim2), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void IdsNs::Ids::setArray(blitz::Array<int,3>&array,int *arrayPtr, int dim1, int dim2, int dim3)
        {
            blitz::Array<int,3> newArray(arrayPtr, shape(dim1, dim2, dim3), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void IdsNs::Ids::setArray(blitz::Array<float,3>&array,float *arrayPtr, int dim1, int dim2, int dim3)
        {
            blitz::Array<float,3> newArray(arrayPtr, shape(dim1, dim2, dim3), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void IdsNs::Ids::setArray(blitz::Array<double,3>&array,double *arrayPtr, int dim1, int dim2, int dim3)
        {
            blitz::Array<double,3> newArray(arrayPtr, shape(dim1, dim2, dim3), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }


        void IdsNs::Ids::setArray(blitz::Array<int,4>&array,int *arrayPtr, int dim1, int dim2, int dim3, int dim4)
        {
            blitz::Array<int,4> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void IdsNs::Ids::setArray(blitz::Array<float,4>&array,float *arrayPtr, int dim1, int dim2, int dim3, int dim4)
        {
            blitz::Array<float,4> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void IdsNs::Ids::setArray(blitz::Array<double,4>&array,double *arrayPtr, int dim1, int dim2, int dim3, int dim4)
        {
            blitz::Array<double,4> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }

        void IdsNs::Ids::setArray(blitz::Array<int,5>&array,int *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5)
        {
            blitz::Array<int,5> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void IdsNs::Ids::setArray(blitz::Array<float,5>&array,float *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5)
        {
            blitz::Array<float,5> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void IdsNs::Ids::setArray(blitz::Array<double,5>&array,double *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5)
        {
            blitz::Array<double,5> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }

        void IdsNs::Ids::setArray(blitz::Array<int,6>&array,int *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6)
        {
            blitz::Array<int,6> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5, dim6), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void IdsNs::Ids::setArray(blitz::Array<float,6>&array,float *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6)
        {
            blitz::Array<float,6> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5, dim6), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void IdsNs::Ids::setArray(blitz::Array<double,6>&array,double *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6)
        {
            blitz::Array<double,6> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5, dim6), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
    



