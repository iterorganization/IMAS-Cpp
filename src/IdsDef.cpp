#include "IdsDef.h"

#include "ual_const.h"
#include "ual_lowlevel.h"
#include "UALDef.h"

#include <complex.h>

using namespace blitz;
using namespace IdsNs;



al_status_t IdsNs::Ids::readIdsTimeMode( int ctx, int& outIdsTimeMode )
{
    int idsTimeMode = -1;
    al_status_t al_status;
    std::string fieldPath = "ids_properties/homogeneous_time";
    std::string timeBasePath = "";
    
    al_status =IdsNs::Ids::readData(ctx, fieldPath, timeBasePath, idsTimeMode);
    if (al_status.code)
            return al_status;

    switch(idsTimeMode)
    {
        case IDS_TIME_MODE_UNKNOWN:     
        case IDS_TIME_MODE_HETEROGENEOUS: 
        case IDS_TIME_MODE_HOMOGENEOUS:   
        case IDS_TIME_MODE_INDEPENDENT:   
                outIdsTimeMode = idsTimeMode;
                break;

        default: 
             al_status.code = -1;
             strncpy(al_status.message, "ERROR: time dependency mode (ids_properties/homogeneous_time) set to unknown value!", MAX_ERR_MSG_LEN);
    }
    return al_status;
}


char* IdsNs::Ids::timeModeToString( int idsTimeMode )
{

    switch(idsTimeMode)
    {
        case IDS_TIME_MODE_UNKNOWN:     
                                        return "UNKNOWN";
        case IDS_TIME_MODE_HETEROGENEOUS: 

                                        return "HETEROGENEOUS";
        case IDS_TIME_MODE_HOMOGENEOUS:   
                                        return "HOMOGENEOUS";
        case IDS_TIME_MODE_INDEPENDENT:   
                                        return "INDEPENDENT";

        default: 
                                        return "UNKNOWN";

    }
    return 0;
}


al_status_t IdsNs::Ids::okStatus()
{
    al_status_t al_status;

    al_status.code = 0;
    strncpy(al_status.message, "", MAX_ERR_MSG_LEN);

    return al_status;
}


bool IdsNs::Ids::isError(al_status_t statusCode, const char *file, const unsigned long line, const char *func)
{  
            // no error
            if (al_status.code > -1)
                return false;

            // critical error that should be propagated to higher levels
            printf("ERROR while calling '%s', %s:%d\n%s\n", func, file, line, al_status.message);
            return true;
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

        void IdsNs::Ids::setArray(blitz::Array<std_complex_t,1>&array, std_complex_t *arrayPtr, int dim1)
        {
            blitz::Array<std_complex_t,1> newArray(arrayPtr, shape(dim1), duplicateData, fortranArray);
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

        void IdsNs::Ids::setArray(blitz::Array<std_complex_t,2>&array, std_complex_t *arrayPtr, int dim1, int dim2)
        {
            blitz::Array<std_complex_t,2> newArray(arrayPtr, shape(dim1, dim2), duplicateData, fortranArray);
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

        void IdsNs::Ids::setArray(blitz::Array<std_complex_t,3>&array, std_complex_t *arrayPtr, int dim1, int dim2, int dim3)
        {
            blitz::Array<std_complex_t,3> newArray(arrayPtr, shape(dim1, dim2, dim3), duplicateData, fortranArray);
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

        void IdsNs::Ids::setArray(blitz::Array<std_complex_t,4>&array, std_complex_t *arrayPtr, int dim1, int dim2, int dim3, int dim4)
        {
            blitz::Array<std_complex_t,4> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4), duplicateData, fortranArray);
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

        void IdsNs::Ids::setArray(blitz::Array<std_complex_t,5>&array, std_complex_t *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5)
        {
            blitz::Array<std_complex_t,5> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5), duplicateData, fortranArray);
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

        void IdsNs::Ids::setArray(blitz::Array<std_complex_t,6>&array, std_complex_t *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6)
        {
            blitz::Array<std_complex_t,6> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5, dim6), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
    	/************************************************************************************************************************************************/
    	/*********************************                                                                           ************************************/
    	/*********************************                           WRITE DATA                                      ************************************/
    	/*********************************                                                                           ************************************/
    	/************************************************************************************************************************************************/
  
    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, int value)
        {
        al_status_t al_status;
		void* ptrData = (void*) (&value);

		if (value == EMPTY_INT)
			return IdsNs::Ids::okStatus();

		al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 0, NULL);
        return al_status;
        }

    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<int,1> array)
        {
        al_status_t al_status;
		void* ptrData = (void*) array.data();
		int arrayOfSizes[1] = {	array.extent(0)};

		if(array.size() < 1)
			return IdsNs::Ids::okStatus();

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 1, arrayOfSizes);
        return al_status;
        }

    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<int,2> array)
        {
        al_status_t al_status;
		void* ptrData = NULL;
		int arrayOfSizes[2] = {	array.extent(0), 
					array.extent(1)};

		if(array.size() < 1)
			return IdsNs::Ids::okStatus();

        //Changing data order C -> F
        blitz::Array<int,2>  fortranOrderArray (array.shape(), fortranArray);
        fortranOrderArray = array;

		ptrData = (void*) fortranOrderArray.data();
        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 2, arrayOfSizes);
        return al_status;
        }

    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<int,3> array)
        {
        al_status_t al_status;
		void* ptrData = NULL;
		int arrayOfSizes[3] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2)};
		if(array.size() < 1)
			return IdsNs::Ids::okStatus();

        //Changing data order C -> F
		blitz::Array<int,3> fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

		ptrData = (void*) fortranOrderArray.data();

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 3, arrayOfSizes);
        return al_status;
        }

    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<int,4> array)
        {
        al_status_t al_status;
		void* ptrData = NULL;
		int arrayOfSizes[4] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2), 
					array.extent(3)};

		if(array.size() < 1)
			return IdsNs::Ids::okStatus();

        //Changing data order C -> F
		blitz::Array<int,4> fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

		ptrData = (void*) fortranOrderArray.data();

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 4, arrayOfSizes);
        return al_status;
        }
 
    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<int,5> array)
        {
        al_status_t al_status;
		void* ptrData = NULL;
		int arrayOfSizes[5] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2), 
					array.extent(3), 
					array.extent(4)};

		if(array.size() < 1)
			return IdsNs::Ids::okStatus();

        //Changing data order C -> F
		blitz::Array<int,5> fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;
		ptrData = (void*) fortranOrderArray.data();

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 5, arrayOfSizes);
        return al_status;
        }

    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<int,6> array)
        {
        al_status_t al_status;
		void* ptrData = NULL;
		int arrayOfSizes[6] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2), 
					array.extent(3), 
					array.extent(4), 
					array.extent(5)};

		if(array.size() < 1)
			return IdsNs::Ids::okStatus();

        //Changing data order C -> F
		blitz::Array<int,6> fortranOrderArray(array.shape(), fortranArray);

        fortranOrderArray = array;
		ptrData = (void*) fortranOrderArray.data();

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 6, arrayOfSizes);
        return al_status;
        }

  	/************************************************************************************************************************************************/
    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, double value)
        {
        al_status_t al_status;
		void* ptrData = (void*) (&value);

		if (value == EMPTY_DOUBLE)
			return IdsNs::Ids::okStatus();

		al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 0, NULL);
        return al_status;
        }

    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<double,1> array)
        {
        al_status_t al_status;
		void* ptrData = (void*) array.data();
		int arrayOfSizes[1] = {	array.extent(0)};

		if(array.size() < 1)
			return IdsNs::Ids::okStatus();

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 1, arrayOfSizes);
        return al_status;
        }

    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<double,2> array)
        {
        al_status_t al_status;
		void* ptrData = NULL;
		int arrayOfSizes[2] = {	array.extent(0), 
					array.extent(1)};

		if(array.size() < 1)
			return IdsNs::Ids::okStatus();

        //Changing data order C -> F
		blitz::Array<double,2> fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

		ptrData = (void*) fortranOrderArray.data();

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 2, arrayOfSizes);
        return al_status;
        }

    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<double,3> array)
        {
        al_status_t al_status;
		void* ptrData = NULL;
		int arrayOfSizes[3] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2)};

		if(array.size() < 1)
			return IdsNs::Ids::okStatus();

        //Changing data order C -> F
		blitz::Array<double,3> fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

		ptrData = (void*) fortranOrderArray.data();

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 3, arrayOfSizes);
        return al_status;
        }

    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<double,4> array)
        {
        al_status_t al_status;
		void* ptrData = NULL;
		int arrayOfSizes[4] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2), 
					array.extent(3)};

		if(array.size() < 1)
			return IdsNs::Ids::okStatus();

        //Changing data order C -> F
		blitz::Array<double,4> fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

		ptrData = (void*) fortranOrderArray.data();


        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 4, arrayOfSizes);
        return al_status;
        }
 
    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<double,5> array)
        {
        al_status_t al_status;
		void* ptrData = NULL;
		int arrayOfSizes[5] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2), 
					array.extent(3), 
					array.extent(4)};


		if(array.size() < 1)
			return IdsNs::Ids::okStatus();

        //Changing data order C -> F
		blitz::Array<double,5> fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

		ptrData = (void*) fortranOrderArray.data();



        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 5, arrayOfSizes);
        return al_status;
        }

    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<double,6> array)
        {
        al_status_t al_status;
		void* ptrData = NULL;
		int arrayOfSizes[6] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2), 
					array.extent(3), 
					array.extent(4), 
					array.extent(5)};


		if(array.size() < 1)
			return IdsNs::Ids::okStatus();

        //Changing data order C -> F
		blitz::Array<double,6>  fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

		ptrData = (void*) fortranOrderArray.data();


        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 6, arrayOfSizes);
        return al_status;
        }

    /************************************************************************************************************************************************/
    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath,  std_complex_t value)
    {
        al_status_t al_status;
        void* ptrData = (void*) (&value);

        if(value == EMPTY_COMPLEX)
            return IdsNs::Ids::okStatus();

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, COMPLEX_DATA, 0, NULL);
        return al_status;
    }

    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<std_complex_t, 1> array)
    {
        al_status_t al_status;
        void* ptrData = NULL;
        int arrayOfSizes[1] = { array.extent(0)};


        if(array.size() < 1)
            return IdsNs::Ids::okStatus();

        //Changing data order C -> F
        blitz::Array<std_complex_t,1>  fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

        ptrData = (void*) fortranOrderArray.data();


        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, COMPLEX_DATA, 1, arrayOfSizes);
        return al_status;
    }


    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<std_complex_t, 2> array)
    {
        al_status_t al_status;
        void* ptrData = NULL;
        int arrayOfSizes[2] = { array.extent(0), array.extent(1)};


        if(array.size() < 1)
            return IdsNs::Ids::okStatus();

        //Changing data order C -> F
        blitz::Array<std_complex_t,2>  fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

        ptrData = (void*) fortranOrderArray.data();


        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, COMPLEX_DATA, 2, arrayOfSizes);
        return al_status;
    }


    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<std_complex_t, 3> array)
    {
        al_status_t al_status;
        void* ptrData = NULL;
        int arrayOfSizes[3] = { array.extent(0), array.extent(1), array.extent(2)};


        if(array.size() < 1)
            return IdsNs::Ids::okStatus();

        //Changing data order C -> F
        blitz::Array<std_complex_t,3>  fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

        ptrData = (void*) fortranOrderArray.data();


        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, COMPLEX_DATA, 3, arrayOfSizes);
        return al_status;
    }


    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<std_complex_t, 4> array)
    {
        al_status_t al_status;
        void* ptrData = NULL;
        int arrayOfSizes[4] = { array.extent(0), array.extent(1), array.extent(2), array.extent(3)};


        if(array.size() < 1)
            return IdsNs::Ids::okStatus();

        //Changing data order C -> F
        blitz::Array<std_complex_t,4>  fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

        ptrData = (void*) fortranOrderArray.data();


        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, COMPLEX_DATA, 4, arrayOfSizes);
        return al_status;
    }

    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<std_complex_t, 5> array)
    {
        al_status_t al_status;
        void* ptrData = NULL;
        int arrayOfSizes[5] = { array.extent(0), array.extent(1), array.extent(2), array.extent(3), array.extent(4)};


        if(array.size() < 1)
            return IdsNs::Ids::okStatus();

        //Changing data order C -> F
        blitz::Array<std_complex_t,5>  fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

        ptrData = (void*) fortranOrderArray.data();


        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, COMPLEX_DATA, 5, arrayOfSizes);
        return al_status;
    }

    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<std_complex_t, 6> array)
    {
        al_status_t al_status;
        void* ptrData = NULL;
        int arrayOfSizes[6] = { array.extent(0), array.extent(1), array.extent(2), array.extent(3), array.extent(4), array.extent(5)};


        if(array.size() < 1)
            return IdsNs::Ids::okStatus();

        //Changing data order C -> F
        blitz::Array<std_complex_t,6>  fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

        ptrData = (void*) fortranOrderArray.data();


        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, COMPLEX_DATA, 6, arrayOfSizes);
        return al_status;
    }

	/************************************************************************************************************************************************/

    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, std::string text)
        {
        al_status_t al_status;
		void* ptrData = (void *) (text.c_str());
		int arrayOfSizes[1] = {	(int)text.size()};
		if (text.length() < 1)
			return IdsNs::Ids::okStatus();

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, CHAR_DATA, 1, arrayOfSizes);
        return al_status;
        }

    al_status_t IdsNs::Ids::writeData(int ctx, std::string fieldPath, std::string timeBasePath, const blitz::Array<std::string, 1> text)
        {
        al_status_t al_status;
		int maxStringSize = -1;
		int  numberOfStrings = text.extent(0);
		char* ptrData = NULL;
		char* ptrCString = NULL;
		int arrayOfSizes[2];
		int size;

		if (numberOfStrings < 1)
			return IdsNs::Ids::okStatus();

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

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), (void*)ptrData, CHAR_DATA, 2, arrayOfSizes);
        return al_status;
        }

    	/************************************************************************************************************************************************/
    	/*********************************                                                                           ************************************/
    	/*********************************                             READ DATA                                     ************************************/
    	/*********************************                                                                           ************************************/
    	/************************************************************************************************************************************************/

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, double &value)
        {
        al_status_t al_status;
		int retSize[MAXDIM];
		double retVal = -1;
		void* ptrData = &retVal;

  		al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, DOUBLE_DATA, 0, &retSize[0]);
        if (al_status.code != 0)
    			return al_status;
		
        if(ptrData == NULL)
            return al_status;

		value = *(double*)ptrData;

        return al_status;
	}


    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<double, 1> &array)
        {
        al_status_t al_status;
		int retSize[MAXDIM];
		void* ptrData = NULL;

  		al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, DOUBLE_DATA, 1, &retSize[0]);
        if (al_status.code != 0)
    			return al_status;

        if(ptrData == NULL || retSize[0] == 0)
            return al_status;

		IdsNs::Ids::setArray(array, (double*)ptrData, retSize[0]);

        return al_status;
	}

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<double, 2> &array)
        {
        al_status_t al_status;
		int retSize[MAXDIM];
		void* ptrData = NULL;

  		al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, DOUBLE_DATA, 2, &retSize[0]);
        if (al_status.code != 0)
    			return al_status;

        if(ptrData == NULL || retSize[0] * retSize[1] == 0)
            return al_status;

		IdsNs::Ids::setArray(array, (double*)ptrData, retSize[0], retSize[1]);

        return al_status;
	}

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<double, 3> &array)
        {
        al_status_t al_status;
		int retSize[MAXDIM];
		void* ptrData = NULL;

  		al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, DOUBLE_DATA, 3, &retSize[0]);
        if (al_status.code != 0)
    			return al_status;

        if(ptrData == NULL || retSize[0] * retSize[1] * retSize[2] == 0)
            return al_status;

		IdsNs::Ids::setArray(array, (double*)ptrData, retSize[0], retSize[1], retSize[2]);

        return al_status;
	}
	

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<double, 4> &array)
        {
        al_status_t al_status;
		int retSize[MAXDIM];
		void* ptrData = NULL;

  		al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, DOUBLE_DATA, 4, &retSize[0]);
        if (al_status.code != 0)
    			return al_status;

        if(ptrData == NULL || retSize[0] * retSize[1] * retSize[2] * retSize[3] == 0)
            return al_status;

		IdsNs::Ids::setArray(array, (double*)ptrData, retSize[0], retSize[1], retSize[2], retSize[3]);

        return al_status;
	}

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<double, 5> &array)
        {
        al_status_t al_status;
		int retSize[MAXDIM];
		void* ptrData = NULL;

  		al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, DOUBLE_DATA, 5, &retSize[0]);
        if (al_status.code != 0)
    			return al_status;

        if(ptrData == NULL || retSize[0] * retSize[1] * retSize[2] * retSize[3] * retSize[4] == 0)
            return al_status;

		IdsNs::Ids::setArray(array, (double*)ptrData, retSize[0], retSize[1], retSize[2], retSize[3], retSize[4]);

        return al_status;
	}

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<double, 6> &array)
        {
        al_status_t al_status;
		int retSize[MAXDIM];
		void* ptrData = NULL;

  		al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, DOUBLE_DATA, 6, &retSize[0]);
        if (al_status.code != 0)
    			return al_status;

        if(ptrData == NULL || retSize[0] * retSize[1] * retSize[2] * retSize[3] * retSize[4] * retSize[5] == 0)
            return al_status;

		IdsNs::Ids::setArray(array, (double*)ptrData, retSize[0], retSize[1], retSize[2], retSize[3], retSize[4], retSize[5]);

        return al_status;
	}


    /************************************************************************************************************************************************/
    /************************************************************************************************************************************************/
    /************************************************************************************************************************************************/


    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath,  std_complex_t &value)
        {
        al_status_t al_status;
        int retSize[MAXDIM];
        std_complex_t stdComplex;
        void* ptrData = &stdComplex;
        

        al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, COMPLEX_DATA, 0, &retSize[0]);
        if (al_status.code != 0)
                return al_status;

        if(ptrData == NULL)
        {
            value = EMPTY_COMPLEX;
            return al_status;
        }

        value = *(std_complex_t*)ptrData;

        return al_status;
    }

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<std_complex_t, 1> &array)
        {
        al_status_t al_status;
        int retSize[MAXDIM];
        void* ptrData = NULL;

        al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, COMPLEX_DATA, 1, &retSize[0]);
        if (al_status.code != 0)
                return al_status;

        if(ptrData == NULL || retSize[0] == 0)
        {
            array.free();
            return al_status;
        }

        IdsNs::Ids::setArray(array, (std_complex_t*)ptrData, retSize[0]);

        return al_status;
    }


    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<std_complex_t, 2> &array)
        {
        al_status_t al_status;
        int retSize[MAXDIM];
        void* ptrData = NULL;

        al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, COMPLEX_DATA, 2, &retSize[0]);
        if (al_status.code != 0)
                return al_status;

        if(ptrData == NULL || retSize[0] * retSize[1]  == 0)
        {
            array.free();
            return al_status;
        }

        IdsNs::Ids::setArray(array, (std_complex_t*)ptrData, retSize[0], retSize[1]);

        return al_status;
    }

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<std_complex_t, 3> &array)
        {
        al_status_t al_status;
        int retSize[MAXDIM];
        void* ptrData = NULL;

        al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, COMPLEX_DATA, 3, &retSize[0]);
        if (al_status.code != 0)
                return al_status;

        if(ptrData == NULL || retSize[0] * retSize[1] * retSize[2] == 0)
        {
            array.free();
            return al_status;
        }

        IdsNs::Ids::setArray(array, (std_complex_t*)ptrData, retSize[0], retSize[1], retSize[2]);

        return al_status;
    }

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<std_complex_t, 4> &array)
        {
        al_status_t al_status;
        int retSize[MAXDIM];
        void* ptrData = NULL;

        al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, COMPLEX_DATA, 4, &retSize[0]);
        if (al_status.code != 0)
                return al_status;

        if(ptrData == NULL || retSize[0] * retSize[1] * retSize[2] * retSize[3] == 0)
        {
            array.free();
            return al_status;
        }

        IdsNs::Ids::setArray(array, (std_complex_t*)ptrData, retSize[0], retSize[1], retSize[2], retSize[3]);

        return al_status;
    }

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<std_complex_t, 5> &array)
        {
        al_status_t al_status;
        int retSize[MAXDIM];
        void* ptrData = NULL;

        al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, COMPLEX_DATA, 5, &retSize[0]);
        if (al_status.code != 0)
                return al_status;

        if(ptrData == NULL || retSize[0] * retSize[1] * retSize[2] * retSize[3] * retSize[4] == 0)
        {
            array.free();
            return al_status;
        }

        IdsNs::Ids::setArray(array, (std_complex_t*)ptrData, retSize[0], retSize[1], retSize[2], retSize[3], retSize[4]);

        return al_status;
    }

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<std_complex_t, 6> &array)
        {
        al_status_t al_status;
        int retSize[MAXDIM];
        void* ptrData = NULL;

        al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, COMPLEX_DATA, 6, &retSize[0]);
        if (al_status.code != 0)
                return al_status;

        if(ptrData == NULL || retSize[0] * retSize[1] * retSize[2] * retSize[3] * retSize[4] * retSize[5] == 0)
        {
            array.free();
            return al_status;
        }

        IdsNs::Ids::setArray(array, (std_complex_t*)ptrData, retSize[0], retSize[1], retSize[2], retSize[3], retSize[4], retSize[5]);

        return al_status;
    }
	/************************************************************************************************************************************************/
	/************************************************************************************************************************************************/
	/************************************************************************************************************************************************/

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, int  &value)
        {
        al_status_t al_status;
		int retSize[MAXDIM];
		int retVal = -1;
		void* ptrData = &retVal;

  		al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, INTEGER_DATA, 0, &retSize[0]);
        if (al_status.code != 0)
    			return al_status;

        if(ptrData == NULL)
            return al_status;
		
		value = *(int*)ptrData;

        return al_status;
	}


    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<int, 1> &array)
        {
        al_status_t al_status;
		int retSize[MAXDIM];
		void* ptrData = NULL;

  		al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, INTEGER_DATA, 1, &retSize[0]);
        if (al_status.code != 0)
    			return al_status;

        if(ptrData == NULL || retSize[0] == 0)
            return al_status;

		IdsNs::Ids::setArray(array, (int*)ptrData, retSize[0]);

        return al_status;
	}

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<int, 2> &array)
        {
        al_status_t al_status;
		int retSize[MAXDIM];
		void* ptrData = NULL;

  		al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, INTEGER_DATA, 2, &retSize[0]);
        if (al_status.code != 0)
    			return al_status;

        if(ptrData == NULL || retSize[0] * retSize[1] == 0)
            return al_status;

		IdsNs::Ids::setArray(array, (int*)ptrData, retSize[0], retSize[1]);

        return al_status;
	}

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<int, 3> &array)
        {
        al_status_t al_status;
		int retSize[MAXDIM];
		void* ptrData = NULL;

  		al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, INTEGER_DATA, 3, &retSize[0]);
        if (al_status.code != 0)
    			return al_status;

        if(ptrData == NULL || retSize[0] * retSize[1] * retSize[2] == 0)
            return al_status;

		IdsNs::Ids::setArray(array, (int*)ptrData, retSize[0], retSize[1], retSize[2]);

        return al_status;
	}
	

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<int, 4> &array)
        {
        al_status_t al_status;
		int retSize[MAXDIM];
		void* ptrData = NULL;

  		al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, INTEGER_DATA, 4, &retSize[0]);
        if (al_status.code != 0)
    			return al_status;

        if(ptrData == NULL || retSize[0] * retSize[1] * retSize[2] * retSize[3] == 0)
            return al_status;

		IdsNs::Ids::setArray(array, (int*)ptrData, retSize[0], retSize[1], retSize[2], retSize[3]);

        return al_status;
	}

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<int, 6> &array)
        {
        al_status_t al_status;
		int retSize[MAXDIM];
		void* ptrData = NULL;

  		al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, INTEGER_DATA, 6, &retSize[0]);
        if (al_status.code != 0)
    			return al_status;

        if(ptrData == NULL || retSize[0] * retSize[1] * retSize[2] * retSize[3] * retSize[4] * retSize[5] == 0)
            return al_status;

		IdsNs::Ids::setArray(array, (int*)ptrData, retSize[0], retSize[1], retSize[2], retSize[3], retSize[4], retSize[5]);

        return al_status;
	}

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<int, 5> &array)
        {
        al_status_t al_status;
		int retSize[MAXDIM];
		void* ptrData = NULL;

  		al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, INTEGER_DATA, 5, &retSize[0]);
        if (al_status.code != 0)
    			return al_status;

        if(ptrData == NULL || retSize[0] * retSize[1] * retSize[2] * retSize[3] * retSize[4] == 0)
            return al_status;

		IdsNs::Ids::setArray(array, (int*)ptrData, retSize[0], retSize[1], retSize[2], retSize[3], retSize[4]);

        return al_status;
	}
	/************************************************************************************************************************************************/
	/************************************************************************************************************************************************/
	/************************************************************************************************************************************************/
    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, std::string& text)
        {
        al_status_t al_status;
		int retSize[MAXDIM];	
		void* ptrData = NULL;
		
		al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), &ptrData, CHAR_DATA, 1, &retSize[0]);
		if (al_status.code != 0)
    			return al_status;
		
		if(ptrData != NULL && retSize[0] > 0)
			text = std::string((char*)ptrData, retSize[0]);
		else
			text = "";

        return al_status;
        }

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, blitz::Array<std::string, 1> &array)
        {
        al_status_t al_status;
		int retSize[MAXDIM];
		char* ptrData = NULL;

		int  numberOfStrings = -1;
		int maxStringSize = -1;

  		al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), (void**)(&ptrData), CHAR_DATA, 2, &retSize[0]);
        if (al_status.code != 0)
    			return al_status;

        if(ptrData == NULL || retSize[0] * retSize[1] == 0)
            return al_status;        

		numberOfStrings = retSize[0];
		maxStringSize = retSize[1];

		array.resize(numberOfStrings);

		for(int i=0; i < numberOfStrings; i++)
		{
			
			array(i) = ptrData; 	
			ptrData = ptrData + maxStringSize;	
		}

        return al_status;
	}

    /************************************************************************************************************************************************/
    /************************************************************************************************************************************************/
    /************************************************************************************************************************************************/


