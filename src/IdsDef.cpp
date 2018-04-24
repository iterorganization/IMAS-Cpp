#include <blitz/array.h>
#include "IdsDef.h"

#include "ual_const.h"
#include "ual_lowlevel.h"
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
    	/************************************************************************************************************************************************/
    	/*********************************                           WRITE DATA                                      ************************************/
    	/************************************************************************************************************************************************/
  
	int IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, int value)
        {
        	int status = -1;
		void* ptrData = (void*) (&value);

		status =  ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 0, NULL);
  		return status;
        }

	int IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<int,1> array)
        {
        	int status = -1;
		void* ptrData = (void*) array.data();
		int arrayOfSizes[1] = {	array.extent(0)};

		status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 1, arrayOfSizes);
  		return status;
        }

	int IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<int,2> array)
        {
        	int status = -1;
		void* ptrData = (void*) array.data();
		int arrayOfSizes[2] = {	array.extent(0), 
					array.extent(1)};

		status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 2, arrayOfSizes);
  		return status;
        }

	int IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<int,3> array)
        {
        	int status = -1;
		void* ptrData = (void*) array.data();
		int arrayOfSizes[3] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2)};

		status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 3, arrayOfSizes);
  		return status;
        }

	int IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<int,4> array)
        {
        	int status = -1;
		void* ptrData = (void*) array.data();
		int arrayOfSizes[4] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2), 
					array.extent(3)};

		status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 4, arrayOfSizes);
  		return status;
        }
 
	int IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<int,5> array)
        {
        	int status = -1;
		void* ptrData = (void*) array.data();
		int arrayOfSizes[5] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2), 
					array.extent(3), 
					array.extent(4)};

		status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 5, arrayOfSizes);
  		return status;
        }

    	int IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<int,6> array)
        {
        	int status = -1;
		void* ptrData = (void*) array.data();
		int arrayOfSizes[6] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2), 
					array.extent(3), 
					array.extent(4), 
					array.extent(5)};

		status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 6, arrayOfSizes);
  		return status;
        }

  	/************************************************************************************************************************************************/
	int IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, double value)
        {
        	int status = -1;
		void* ptrData = (void*) (&value);

		status =  ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 0, NULL);
  		return status;
        }

	int IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<double,1> array)
        {
        	int status = -1;
		void* ptrData = (void*) array.data();
		int arrayOfSizes[1] = {	array.extent(0)};

		status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 1, arrayOfSizes);
  		return status;
        }

	int IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<double,2> array)
        {
        	int status = -1;
		void* ptrData = (void*) array.data();
		int arrayOfSizes[2] = {	array.extent(0), 
					array.extent(1)};

		status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 2, arrayOfSizes);
  		return status;
        }

	int IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<double,3> array)
        {
        	int status = -1;
		void* ptrData = (void*) array.data();
		int arrayOfSizes[3] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2)};

		status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 3, arrayOfSizes);
  		return status;
        }

	int IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<double,4> array)
        {
        	int status = -1;
		void* ptrData = (void*) array.data();
		int arrayOfSizes[4] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2), 
					array.extent(3)};

		status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 4, arrayOfSizes);
  		return status;
        }
 
	int IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<double,5> array)
        {
        	int status = -1;
		void* ptrData = (void*) array.data();
		int arrayOfSizes[5] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2), 
					array.extent(3), 
					array.extent(4)};

		status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 5, arrayOfSizes);
  		return status;
        }

    	int IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<double,6> array)
        {
        	int status = -1;
		void* ptrData = (void*) array.data();
		int arrayOfSizes[6] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2), 
					array.extent(3), 
					array.extent(4), 
					array.extent(5)};

		status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 6, arrayOfSizes);
  		return status;
        }

    	int IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, std::string text)
        {
        	int status = -1;
		void* ptrData = (void *) (text.c_str());
		int arrayOfSizes[1] = {	(int)text.size()};

		status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, CHAR_DATA, 1, arrayOfSizes);
  		return status;
        }

    	int IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<std::string, 1> text)
        {
        	int status = -1;
		int maxStringSize = -1;
		int  numberOfStrings = text.extent(0);
		char* ptrData = NULL;
		char* ptrCString = NULL;
		int arrayOfSizes[2];
		int size;

		for(int i=0; i < numberOfStrings; i++)
		{
			size = text(i).size();
			if( size > maxStringSize)
				maxStringSize = size;
				
		}

		maxStringSize = maxStringSize + 1; //ending zero
		arrayOfSizes[0] = numberOfStrings; 
		arrayOfSizes[1] = maxStringSize;

		ptrData = (char*)  malloc(numberOfStrings * maxStringSize);
		memset(ptrData,  0 , numberOfStrings * maxStringSize);

		
		for(int i=0; i < numberOfStrings; i++)
		{
			ptrCString = const_cast<char *> (text(i).c_str());
			size = text(i).size();
			memcpy(ptrData + i * maxStringSize, ptrCString, size);	
		}

		status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), (void*)ptrData, CHAR_DATA, 2, arrayOfSizes);
  		return status;
        }
    


