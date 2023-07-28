#ifndef _IDS_CLASS

#define _IDS_CLASS


#include "ALDef.h"
using namespace blitz;

#define NON_TIMED    0
#define TIMED       1
#define TIMED_CLEAR 2
/*#define DEBUG*/


namespace IdsNs {

struct DataDictionary {
    static const std::string LIFECYCLE_STATUS_OBSOLETE;
};

class Ids
{
    public:
        Ids() { connected = false; }
        virtual ~Ids() = default;

        // serialization
        static int default_serializer_protocol() { return DEFAULT_SERIALIZER_PROTOCOL; };
        std::string serialize(int protocol=DEFAULT_SERIALIZER_PROTOCOL);
        int deserialize(std::string &data);

        // virtual functions defined in subclasses
        virtual int get() = 0;
        virtual int get(int idx) = 0;
        virtual int put() = 0;
        virtual int put(int idx) = 0;
        virtual int getSlice(double inTime, char interpolMode) = 0;
        virtual int getSlice(int idx, double inTime, char interpolMode) = 0;
        virtual int putSlice() = 0;
        virtual int putSlice(int idx) = 0;
        virtual int deleteAll() = 0;
        virtual int deleteAll(int idx) = 0;
        virtual void clear() = 0;
        
        void setPulseCtx(int pulseCtx){this->pulseCtx = pulseCtx; connected = true;}

    protected:
        int pulseCtx;
        bool connected;

        static al_status_t readIdsTimeMode( int pulseCtx, const char *idsFullName, int& outIdsTimeMode );

        static char* timeModeToString( int idsTimeMode );

        static void warningWritingObsolescentNode(const std::string &idsName, const std::string &fieldPath, const std::string &lifeCycleStatus);

        static bool isError(al_status_t al_status, const char *file, const unsigned long line, const char *func);
        static al_status_t okStatus();

        /************************************************************************************************************************************************/
        /*********************************                      COMPLEX NUMBERS CONVERSION                           ************************************/
        /************************************************************************************************************************************************/
            
        static void setArray(IMASArray<int,1>&array,int *arrayPtr, int dim1);
        
        static void setArray(IMASArray<float,1>&array,float *arrayPtr, int dim1);
  
        static void setArray(IMASArray<double,1>&array,double *arrayPtr, int dim1);

        static void setArray(IMASArray<std_complex_t,1> &array, std_complex_t *arrayPtr, int dim1);


        static void setArray(IMASArray<int,2>&array,int *arrayPtr, int dim1, int dim2);

        static void setArray(IMASArray<float,2>&array,float *arrayPtr, int dim1, int dim2);

        static void setArray(IMASArray<double,2>&array,double *arrayPtr, int dim1, int dim2);

        static void setArray(IMASArray<std_complex_t,2> &array, std_complex_t *arrayPtr, int dim1, int dim2);


        static void setArray(IMASArray<int,3>&array,int *arrayPtr, int dim1, int dim2, int dim3);

        static void setArray(IMASArray<float,3>&array,float *arrayPtr, int dim1, int dim2, int dim3);

        static void setArray(IMASArray<double,3>&array,double *arrayPtr, int dim1, int dim2, int dim3);

        static void setArray(IMASArray<std_complex_t,3> &array, std_complex_t *arrayPtr, int dim1, int dim2, int dim3);


        static void setArray(IMASArray<int,4>&array,int *arrayPtr, int dim1, int dim2, int dim3, int dim4);
   
        static void setArray(IMASArray<float,4>&array,float *arrayPtr, int dim1, int dim2, int dim3, int dim4);
   
        static void setArray(IMASArray<double,4>&array,double *arrayPtr, int dim1, int dim2, int dim3, int dim4);

        static void setArray(IMASArray<std_complex_t,4> &array, std_complex_t *arrayPtr, int dim1, int dim2, int dim3, int dim4);
    

        static void setArray(IMASArray<int,5>&array,int *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5);
   
        static void setArray(IMASArray<float,5>&array,float *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5);
     
        static void setArray(IMASArray<double,5>&array,double *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5);
 
        static void setArray(IMASArray<std_complex_t,5> &array, std_complex_t *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5);
   

        static void setArray(IMASArray<int,6>&array,int *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6);
  
        static void setArray(IMASArray<float,6>&array,float *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6);
   
        static void setArray(IMASArray<double,6>&array,double *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6);

        static void setArray(IMASArray<std_complex_t,6> &array, std_complex_t *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6);

    	/************************************************************************************************************************************************/
    	/*********************************                           WRITE DATA                                      ************************************/
    	/************************************************************************************************************************************************/
	
	static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, int value, const std::string &lifeCycleStatus);

	static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<int,1> array, const std::string &lifeCycleStatus);

	static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<int,2> array, const std::string &lifeCycleStatus);

	static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<int,3> array, const std::string &lifeCycleStatus);

	static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<int,4> array, const std::string &lifeCycleStatus);
 
	static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<int,5> array, const std::string &lifeCycleStatus);

    static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<int,6> array, const std::string &lifeCycleStatus);

  	/************************************************************************************************************************************************/
	static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, double value, const std::string &lifeCycleStatus);

	static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<double,1> array, const std::string &lifeCycleStatus);

	static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<double,2> array, const std::string &lifeCycleStatus);

	static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<double,3> array, const std::string &lifeCycleStatus);

	static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<double,4> array, const std::string &lifeCycleStatus);
 
	static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<double,5> array, const std::string &lifeCycleStatus);

    static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<double,6> array, const std::string &lifeCycleStatus);

    /************************************************************************************************************************************************/
    static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, std_complex_t value, const std::string &lifeCycleStatus);


    static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<std_complex_t,1> array, const std::string &lifeCycleStatus);

    static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<std_complex_t,2> array, const std::string &lifeCycleStatus);

    static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<std_complex_t,3> array, const std::string &lifeCycleStatus);

    static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<std_complex_t,4> array, const std::string &lifeCycleStatus);
 
    static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<std_complex_t,5> array, const std::string &lifeCycleStatus);

    static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<std_complex_t,6> array, const std::string &lifeCycleStatus);

  	/************************************************************************************************************************************************/
    
   	static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, std::string text, const std::string &lifeCycleStatus);
   	static al_status_t writeData(int ctx, const std::string &idsName, std::string fieldPath, std::string timebasePath, const IMASArray<std::string, 1> text, const std::string &lifeCycleStatus);

    /************************************************************************************************************************************************/
    /*********************************                             READ DATA                                     ************************************/
    /************************************************************************************************************************************************/
	
	static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, double &value);
	static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<double, 1> &array);
	static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<double, 2> &array);
	static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<double, 3> &array);
	static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<double, 4> &array);
	static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<double, 5> &array);
	static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<double, 6> &array);

	static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, int &value);
	static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<int, 1> &array);
	static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<int, 2> &array);
	static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<int, 3> &array);
	static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<int, 4> &array);
	static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<int, 5> &array);
	static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<int, 6> &array);

    static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, std_complex_t &value);
    static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<std_complex_t, 1> &array);
    static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<std_complex_t, 2> &array);
    static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<std_complex_t, 3> &array);
    static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<std_complex_t, 4> &array);
    static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<std_complex_t, 5> &array);
    static al_status_t readData(int ctx, std::string fieldPath, std::string timeBasePath, IMASArray<std_complex_t, 6> &array);

      	static al_status_t readData(int ctx, std::string fieldPath, std::string timebasePath, std::string& text);
    	static al_status_t readData(int ctx, std::string fieldPath, std::string timebasePath, IMASArray<std::string, 1>& array);
};
}
#endif // _IDS_CLASS
