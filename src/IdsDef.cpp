#include "IdsDef.h"

#include "ual_const.h"
#include "ual_lowlevel.h"
#include "UALDef.h"

#include <complex.h>
#include <fstream>

using namespace blitz;
using namespace IdsNs;

const std::string IdsNs::DataDictionary::LIFECYCLE_STATUS_OBSOLETE = "obsolescent";

namespace {
std::string generate_tmp_file(std::string folder)
{
    // TODO generate a random file name and test for existence
    return folder + "imas_serialize_random123";
}
}

std::string IdsNs::Ids::serialize(int protocol)
{
    if( protocol == ASCII_SERIALIZER_PROTOCOL )
    {
        al_status_t al_status;
        int _pulseCtx;
        // overwrite pulse context, so we can use the logic in put for putting to the ascii backend
        al_status = ual_begin_pulse_action(ASCII_BACKEND, 0, 0, "serialize", "serialize", "3", &_pulseCtx);
        // TODO: check if al_status.code is ok

        // specify the -fullpath option to the ASCII backend
        std::string tmpfile = generate_tmp_file("/dev/shm/"); // create a random non-existent file in the /dev/shm/ directory
        std::string options = "-fullpath " + tmpfile;
        al_status = ual_open_pulse(_pulseCtx, CREATE_PULSE, options.c_str());
        // TODO: check if al_status.code is ok

        // store state and overwrite so we use the ASCII backend in this->put
        auto _connected_stored = this->connected;
        auto _pulseCtx_stored = this->pulseCtx;
        this->pulseCtx = _pulseCtx;
        this->connected = true;
        if( this->put() < 0 ) {
            // TODO: report error
        }
        // restore state
        this->pulseCtx = _pulseCtx_stored;
        this->connected = _connected_stored;

        // cleanup
        al_status = ual_close_pulse(_pulseCtx, CLOSE_PULSE, "");
        // TODO: check if al_status.code is ok
        al_status = ual_end_action(_pulseCtx);
        // TODO: check if al_status.code is ok

        // read contents of tmpfile
        std::ifstream ifstream(tmpfile, std::ios::in | std::ios::binary);
        if(!ifstream)
        {
            printf("SERIALIZE: Error while opening ASCII serialized file");
            return "";
        }

        std::string data;
        ifstream.seekg(0, std::ios::end);
        data.resize(ifstream.tellg());  // reserve memory for reading in the full file
        ifstream.seekg(0, std::ios::beg);
        ifstream.read(&data[0], data.size());
        ifstream.close();
        if(ifstream.bad() || ifstream.fail())
        {
            printf("SERIALIZE: I/O error while reading");
        }
        // TODO erase file
        return data;
    }
    else
    {
        printf("ERROR: unrecognized serialization protocol");
   		return "";
    }
}

int IdsNs::Ids::deserialize(std::string &data, int protocol)
{
    if( protocol == ASCII_SERIALIZER_PROTOCOL )
    {

        // specify the -fullpath option to the ASCII backend
        std::string tmpfile = generate_tmp_file("/dev/shm/"); // create a random non-existent file in the /dev/shm/ directory
        std::string options = "-fullpath " + tmpfile;

        // write data to tmpfile
        std::ofstream ofstream(tmpfile, std::ios::out | std::ios::binary);
        if(!ofstream)
        {
            printf("SERIALIZE: Error while opening ASCII file");
            return -1;
        }

        ofstream << data;
        ofstream.close();
        if(ofstream.bad() || ofstream.fail())
        {
            printf("SERIALIZE: I/O error while writing");
        }

        al_status_t al_status;
        int _pulseCtx;
        // overwrite pulse context, so we can use the logic in get for putting to the ascii backend
        al_status = ual_begin_pulse_action(ASCII_BACKEND, 0, 0, "serialize", "serialize", "3", &_pulseCtx);
        // TODO: check if al_status.code is ok

        al_status = ual_open_pulse(_pulseCtx, CREATE_PULSE, options.c_str());
        // TODO: check if al_status.code is ok

        // store state and overwrite so we use the ASCII backend in this->get
        auto _connected_stored = this->connected;
        auto _pulseCtx_stored = this->pulseCtx;
        this->pulseCtx = _pulseCtx;
        this->connected = true;
        if( this->get() < 0 ) {
            // TODO: report error
        }
        // restore state
        this->pulseCtx = _pulseCtx_stored;
        this->connected = _connected_stored;

        // cleanup
        al_status = ual_close_pulse(_pulseCtx, CLOSE_PULSE, "");
        // TODO: check if al_status.code is ok
        al_status = ual_end_action(_pulseCtx);
        // TODO: check if al_status.code is ok
        
        // TODO erase file
        return 0;
    }
    else
    {
        printf("ERROR: unrecognized serialization protocol");
   		return -1;
    }
}



al_status_t IdsNs::Ids::readIdsTimeMode( int pulseCtx, const char *idsFullName, int& outIdsTimeMode )
{
    int idsTimeMode = -1;
    al_status_t al_status;
    std::string fieldPath = "ids_properties/homogeneous_time";
    std::string timeBasePath = "";
    int opCtx = -1;
    

    // Open get context
    al_status = ual_begin_global_action(pulseCtx, idsFullName, READ_OP, &opCtx);
    if(al_status.code < 0) 
        return al_status;

    al_status =IdsNs::Ids::readData(opCtx, fieldPath, timeBasePath, idsTimeMode);
    if (al_status.code)
    {   
        ual_end_action(opCtx);
        return al_status;
    }

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

    ual_end_action(opCtx);
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

void IdsNs::Ids::warningWritingObsolescentNode(const std::string &idsName, const std::string &fieldPath, const std::string &lifeCycleStatus)
{
    if (lifeCycleStatus.compare(IdsNs::DataDictionary::LIFECYCLE_STATUS_OBSOLETE) == 0)
        printf("Warning : while putting IDS %s, the written IDS has non-empty obsolescent node %s. Please consider updating the code to avoid using obsolescent nodes.\n", idsName.c_str(), fieldPath.c_str());
}


bool IdsNs::Ids::isError(al_status_t al_status, const char *file, const unsigned long line, const char *func)
{  
            // no error
            if (al_status.code > -1)
                return false;

            // critical error that should be propagated to higher levels
            printf("ERROR while calling '%s', %s:%d\n%s\n", func, file, line, al_status.message);
            return true;
}

        void IdsNs::Ids::setArray(IMASArray<int,1>&array,int *arrayPtr, int dim1)
        {
            IMASArray<int,1> newArray(arrayPtr, shape(dim1), neverDeleteData, blitz::ColumnMajorArray<1>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }
        void IdsNs::Ids::setArray(IMASArray<float,1>&array,float *arrayPtr, int dim1)
        {
            IMASArray<float,1> newArray(arrayPtr, shape(dim1), neverDeleteData, blitz::ColumnMajorArray<1>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }
        void IdsNs::Ids::setArray(IMASArray<double,1>&array,double *arrayPtr, int dim1)
        {
            IMASArray<double,1> newArray(arrayPtr, shape(dim1), neverDeleteData, blitz::ColumnMajorArray<1>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }

        void IdsNs::Ids::setArray(IMASArray<std_complex_t,1>&array, std_complex_t *arrayPtr, int dim1)
        {
            IMASArray<std_complex_t,1> newArray(arrayPtr, shape(dim1), neverDeleteData, blitz::ColumnMajorArray<1>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }

        void IdsNs::Ids::setArray(IMASArray<int,2>&array,int *arrayPtr, int dim1, int dim2)
        {
            IMASArray<int,2> newArray(arrayPtr, shape(dim1, dim2), neverDeleteData, blitz::ColumnMajorArray<2>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }
        void IdsNs::Ids::setArray(IMASArray<float,2>&array,float *arrayPtr, int dim1, int dim2)
        {
            IMASArray<float,2> newArray(arrayPtr, shape(dim1, dim2), neverDeleteData, blitz::ColumnMajorArray<2>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }
        void IdsNs::Ids::setArray(IMASArray<double,2>&array,double *arrayPtr, int dim1, int dim2)
        {
            IMASArray<double,2> newArray(arrayPtr, shape(dim1, dim2), neverDeleteData, blitz::ColumnMajorArray<2>());
            //
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }

        void IdsNs::Ids::setArray(IMASArray<std_complex_t,2>&array, std_complex_t *arrayPtr, int dim1, int dim2)
        {
            IMASArray<std_complex_t,2> newArray(arrayPtr, shape(dim1, dim2), neverDeleteData, blitz::ColumnMajorArray<2>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }

        void IdsNs::Ids::setArray(IMASArray<int,3>&array,int *arrayPtr, int dim1, int dim2, int dim3)
        {
            IMASArray<int,3> newArray(arrayPtr, shape(dim1, dim2, dim3), neverDeleteData, blitz::ColumnMajorArray<3>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }
        void IdsNs::Ids::setArray(IMASArray<float,3>&array,float *arrayPtr, int dim1, int dim2, int dim3)
        {
            IMASArray<float,3> newArray(arrayPtr, shape(dim1, dim2, dim3), neverDeleteData, blitz::ColumnMajorArray<3>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }
        void IdsNs::Ids::setArray(IMASArray<double,3>&array,double *arrayPtr, int dim1, int dim2, int dim3)
        {
            IMASArray<double,3> newArray(arrayPtr, shape(dim1, dim2, dim3), neverDeleteData, blitz::ColumnMajorArray<3>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }

        void IdsNs::Ids::setArray(IMASArray<std_complex_t,3>&array, std_complex_t *arrayPtr, int dim1, int dim2, int dim3)
        {
            IMASArray<std_complex_t,3> newArray(arrayPtr, shape(dim1, dim2, dim3), neverDeleteData, blitz::ColumnMajorArray<3>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }


        void IdsNs::Ids::setArray(IMASArray<int,4>&array,int *arrayPtr, int dim1, int dim2, int dim3, int dim4)
        {
            IMASArray<int,4> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4), neverDeleteData, blitz::ColumnMajorArray<4>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }
        void IdsNs::Ids::setArray(IMASArray<float,4>&array,float *arrayPtr, int dim1, int dim2, int dim3, int dim4)
        {
            IMASArray<float,4> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4), neverDeleteData, blitz::ColumnMajorArray<4>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }
        void IdsNs::Ids::setArray(IMASArray<double,4>&array,double *arrayPtr, int dim1, int dim2, int dim3, int dim4)
        {
            IMASArray<double,4> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4), neverDeleteData, blitz::ColumnMajorArray<4>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }

        void IdsNs::Ids::setArray(IMASArray<std_complex_t,4>&array, std_complex_t *arrayPtr, int dim1, int dim2, int dim3, int dim4)
        {
            IMASArray<std_complex_t,4> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4), neverDeleteData, blitz::ColumnMajorArray<4>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }

        void IdsNs::Ids::setArray(IMASArray<int,5>&array,int *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5)
        {
            IMASArray<int,5> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5), neverDeleteData, blitz::ColumnMajorArray<5>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }
        void IdsNs::Ids::setArray(IMASArray<float,5>&array,float *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5)
        {
            IMASArray<float,5> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5), neverDeleteData, blitz::ColumnMajorArray<5>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);

        }
        void IdsNs::Ids::setArray(IMASArray<double,5>&array,double *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5)
        {
            IMASArray<double,5> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5), neverDeleteData, blitz::ColumnMajorArray<5>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }

        void IdsNs::Ids::setArray(IMASArray<std_complex_t,5>&array, std_complex_t *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5)
        {
            IMASArray<std_complex_t,5> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5), neverDeleteData, blitz::ColumnMajorArray<5>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }


        void IdsNs::Ids::setArray(IMASArray<int,6>&array,int *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6)
        {
            IMASArray<int,6> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5, dim6), neverDeleteData, blitz::ColumnMajorArray<6>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }
        void IdsNs::Ids::setArray(IMASArray<float,6>&array,float *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6)
        {
            IMASArray<float,6> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5, dim6), neverDeleteData, blitz::ColumnMajorArray<6>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }
        void IdsNs::Ids::setArray(IMASArray<double,6>&array,double *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6)
        {
            IMASArray<double,6> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5, dim6), neverDeleteData, blitz::ColumnMajorArray<6>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }

        void IdsNs::Ids::setArray(IMASArray<std_complex_t,6>&array, std_complex_t *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6)
        {
            IMASArray<std_complex_t,6> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5, dim6), neverDeleteData, blitz::ColumnMajorArray<6>());
            
            array.setDeletionPolicy(neverDeleteData);
            array.reference(newArray);
        }
    	/************************************************************************************************************************************************/
    	/*********************************                                                                           ************************************/
    	/*********************************                           WRITE DATA                                      ************************************/
    	/*********************************                                                                           ************************************/
    	/************************************************************************************************************************************************/
  
    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, int value, const std::string &lifeCycleStatus)
        {
        al_status_t al_status;
		void* ptrData = (void*) (&value);

		if (value == EMPTY_INT)
			return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

		al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 0, NULL);
        return al_status;
        }

    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<int,1> array, const std::string &lifeCycleStatus)
        {
        al_status_t al_status;
		void* ptrData = (void*) array.data();
		int arrayOfSizes[1] = {	array.extent(0)};

		if(array.size() < 1)
			return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 1, arrayOfSizes);
        return al_status;
        }

    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<int,2> array, const std::string &lifeCycleStatus)
        {
        al_status_t al_status;
		void* ptrData = NULL;
		int arrayOfSizes[2] = {	array.extent(0), 
					array.extent(1)};

		if(array.size() < 1)
			return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        //Changing data order C -> F
        IMASArray<int,2>  fortranOrderArray (array.shape(), fortranArray);
        fortranOrderArray = array;

		ptrData = (void*) fortranOrderArray.data();
        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 2, arrayOfSizes);
        return al_status;
        }


    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<int,3> array, const std::string &lifeCycleStatus)
        {
        al_status_t al_status;
		void* ptrData = NULL;
		int arrayOfSizes[3] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2)};
		if(array.size() < 1)
			return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        //Changing data order C -> F
		IMASArray<int,3> fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

		ptrData = (void*) fortranOrderArray.data();

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 3, arrayOfSizes);
        return al_status;
        }


    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<int,4> array, const std::string &lifeCycleStatus)
        {
        al_status_t al_status;
		void* ptrData = NULL;
		int arrayOfSizes[4] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2), 
					array.extent(3)};

		if(array.size() < 1)
			return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        //Changing data order C -> F
		IMASArray<int,4> fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

		ptrData = (void*) fortranOrderArray.data();

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 4, arrayOfSizes);
        return al_status;
        }
 

    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<int,5> array, const std::string &lifeCycleStatus)
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
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        //Changing data order C -> F
		IMASArray<int,5> fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;
		ptrData = (void*) fortranOrderArray.data();

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 5, arrayOfSizes);
        return al_status;
        }


    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<int,6> array, const std::string &lifeCycleStatus)
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
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        //Changing data order C -> F
		IMASArray<int,6> fortranOrderArray(array.shape(), fortranArray);

        fortranOrderArray = array;
		ptrData = (void*) fortranOrderArray.data();

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 6, arrayOfSizes);
        return al_status;
        }

  	/************************************************************************************************************************************************/
    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, double value, const std::string &lifeCycleStatus)
        {
        al_status_t al_status;
		void* ptrData = (void*) (&value);

		if (value == EMPTY_DOUBLE)
			return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

		al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 0, NULL);
        return al_status;
        }


    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<double,1> array, const std::string &lifeCycleStatus)
        {
        al_status_t al_status;
		void* ptrData = (void*) array.data();
		int arrayOfSizes[1] = {	array.extent(0)};

		if(array.size() < 1)
			return IdsNs::Ids::okStatus();
		else
		    IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 1, arrayOfSizes);
        return al_status;
        }


    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<double,2> array, const std::string &lifeCycleStatus)
        {
        al_status_t al_status;
		void* ptrData = NULL;
		int arrayOfSizes[2] = {	array.extent(0), 
					array.extent(1)};

		if(array.size() < 1)
			return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        //Changing data order C -> F
		IMASArray<double,2> fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

		ptrData = (void*) fortranOrderArray.data();

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 2, arrayOfSizes);
        return al_status;
        }


    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<double,3> array, const std::string &lifeCycleStatus)
        {
        al_status_t al_status;
		void* ptrData = NULL;
		int arrayOfSizes[3] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2)};

		if(array.size() < 1)
			return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        //Changing data order C -> F
		IMASArray<double,3> fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

		ptrData = (void*) fortranOrderArray.data();

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 3, arrayOfSizes);
        return al_status;
        }


    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<double,4> array, const std::string &lifeCycleStatus)
        {
        al_status_t al_status;
		void* ptrData = NULL;
		int arrayOfSizes[4] = {	array.extent(0), 
					array.extent(1), 
					array.extent(2), 
					array.extent(3)};

		if(array.size() < 1)
			return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        //Changing data order C -> F
		IMASArray<double,4> fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

		ptrData = (void*) fortranOrderArray.data();


        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 4, arrayOfSizes);
        return al_status;
        }
 

    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<double,5> array, const std::string &lifeCycleStatus)
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
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        //Changing data order C -> F
		IMASArray<double,5> fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

		ptrData = (void*) fortranOrderArray.data();



        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 5, arrayOfSizes);
        return al_status;
        }


    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<double,6> array, const std::string &lifeCycleStatus)
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
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        //Changing data order C -> F
		IMASArray<double,6>  fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

		ptrData = (void*) fortranOrderArray.data();


        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, DOUBLE_DATA, 6, arrayOfSizes);
        return al_status;
        }

    /************************************************************************************************************************************************/
    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath,  std_complex_t value, const std::string &lifeCycleStatus)
    {
        al_status_t al_status;
        void* ptrData = (void*) (&value);

        if(value == EMPTY_COMPLEX)
            return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, COMPLEX_DATA, 0, NULL);
        return al_status;
    }


    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<std_complex_t, 1> array, const std::string &lifeCycleStatus)
    {
        al_status_t al_status;
        void* ptrData = NULL;
        int arrayOfSizes[1] = { array.extent(0)};


        if(array.size() < 1)
            return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        //Changing data order C -> F
        IMASArray<std_complex_t,1>  fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

        ptrData = (void*) fortranOrderArray.data();


        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, COMPLEX_DATA, 1, arrayOfSizes);
        return al_status;
    }



    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<std_complex_t, 2> array, const std::string &lifeCycleStatus)
    {
        al_status_t al_status;
        void* ptrData = NULL;
        int arrayOfSizes[2] = { array.extent(0), array.extent(1)};


        if(array.size() < 1)
            return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        //Changing data order C -> F
        IMASArray<std_complex_t,2>  fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

        ptrData = (void*) fortranOrderArray.data();


        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, COMPLEX_DATA, 2, arrayOfSizes);
        return al_status;
    }


    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<std_complex_t, 3> array, const std::string &lifeCycleStatus)
    {
        al_status_t al_status;
        void* ptrData = NULL;
        int arrayOfSizes[3] = { array.extent(0), array.extent(1), array.extent(2)};


        if(array.size() < 1)
            return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        //Changing data order C -> F
        IMASArray<std_complex_t,3>  fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

        ptrData = (void*) fortranOrderArray.data();


        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, COMPLEX_DATA, 3, arrayOfSizes);
        return al_status;
    }


    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<std_complex_t, 4> array, const std::string &lifeCycleStatus)
    {
        al_status_t al_status;
        void* ptrData = NULL;
        int arrayOfSizes[4] = { array.extent(0), array.extent(1), array.extent(2), array.extent(3)};


        if(array.size() < 1)
            return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        //Changing data order C -> F
        IMASArray<std_complex_t,4>  fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

        ptrData = (void*) fortranOrderArray.data();


        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, COMPLEX_DATA, 4, arrayOfSizes);
        return al_status;
    }


    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<std_complex_t, 5> array, const std::string &lifeCycleStatus)
    {
        al_status_t al_status;
        void* ptrData = NULL;
        int arrayOfSizes[5] = { array.extent(0), array.extent(1), array.extent(2), array.extent(3), array.extent(4)};


        if(array.size() < 1)
            return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        //Changing data order C -> F
        IMASArray<std_complex_t,5>  fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

        ptrData = (void*) fortranOrderArray.data();


        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, COMPLEX_DATA, 5, arrayOfSizes);
        return al_status;
    }


    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<std_complex_t, 6> array, const std::string &lifeCycleStatus)
    {
        al_status_t al_status;
        void* ptrData = NULL;
        int arrayOfSizes[6] = { array.extent(0), array.extent(1), array.extent(2), array.extent(3), array.extent(4), array.extent(5)};


        if(array.size() < 1)
            return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        //Changing data order C -> F
        IMASArray<std_complex_t,6>  fortranOrderArray(array.shape(), fortranArray);
        fortranOrderArray = array;

        ptrData = (void*) fortranOrderArray.data();


        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, COMPLEX_DATA, 6, arrayOfSizes);
        return al_status;
    }

	/************************************************************************************************************************************************/

    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, std::string text, const std::string &lifeCycleStatus)
        {
        al_status_t al_status;
		void* ptrData = (void *) (text.c_str());
		int arrayOfSizes[1] = {	(int)text.size()};
		if (text.length() < 1)
			return IdsNs::Ids::okStatus();
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

        al_status = ual_write_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, CHAR_DATA, 1, arrayOfSizes);
        return al_status;
        }


    al_status_t IdsNs::Ids::writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timeBasePath, const IMASArray<std::string, 1> text, const std::string &lifeCycleStatus)
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
        else
            IdsNs::Ids::warningWritingObsolescentNode(idsName, fieldPath, lifeCycleStatus);

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


    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<double, 1> &array)
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

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<double, 2> &array)
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

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<double, 3> &array)
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
	

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<double, 4> &array)
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

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<double, 5> &array)
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

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<double, 6> &array)
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

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<std_complex_t, 1> &array)
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


    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<std_complex_t, 2> &array)
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

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<std_complex_t, 3> &array)
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

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<std_complex_t, 4> &array)
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

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<std_complex_t, 5> &array)
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

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<std_complex_t, 6> &array)
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


    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<int, 1> &array)
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

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<int, 2> &array)
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

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<int, 3> &array)
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
	

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<int, 4> &array)
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

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<int, 6> &array)
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

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<int, 5> &array)
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
		{
			text = std::string((char*)ptrData, retSize[0]);
            free(ptrData);
			
		}
		else
			text = "";



        return al_status;
        }

    al_status_t IdsNs::Ids::readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<std::string, 1> &array)
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
		
		char* res = new char[maxStringSize + 1];
		
		for(int i=0; i < numberOfStrings; i++)
		{
            strncpy(res, ptrData, maxStringSize);
            res[maxStringSize] = 0;
            array(i) = res;
			ptrData = ptrData + maxStringSize;	
		}
		free(res);
        return al_status;
	}

    /************************************************************************************************************************************************/
    /************************************************************************************************************************************************/
    /************************************************************************************************************************************************/


