#ifndef _HELPER
#define _HELPER


#include <blitz/array.h>


using namespace blitz;

extern int finalStatus;
/*
extern int dim1;
extern int dim2;
extern int dim3;
extern int dim4;
extern int dim5;
extern int dim6;

extern int randseed;
*/


void checkStatus(int status);
/*******************************************************************************/
/**********************         Setting arrays           ***********************/
/*******************************************************************************/

void setValue(std::string& idsField, bool isReduced);


void setValue(int& idsField, bool isReduced);



void setValue(double& idsField, bool isReduced);


void setValue(Array<std::string,1>&array, bool isReduced);



void setValue(Array<int,1>&array, bool isReduced);
void setValue(Array<int,2>&array, bool isReduced);
void setValue(Array<int,3>&array, bool isReduced);
void setValue(Array<int,4>&array, bool isReduced);
void setValue(Array<int,5>&array, bool isReduced);
void setValue(Array<int,6>&array, bool isReduced);


void setValue(Array<double,1>&array, bool isReduced);
void setValue(Array<double,2>&array, bool isReduced);
void setValue(Array<double,3>&array, bool isReduced);
void setValue(Array<double,4>&array, bool isReduced);
void setValue(Array<double,5>&array, bool isReduced);
void setValue(Array<double,6>&array, bool isReduced);


/**********************        Assert field value        ***********************/
int assertField(std::string&, const char* fieldPath, bool sliceMode);

int assertField(int observedValue, const char* fieldPath,  bool sliceMode);


int assertField(double observedValue, const char* fieldPath, bool sliceMode);


int assertField(const blitz::Array<std::string, 1> observedValue, const char* fieldPath, bool sliceMode);


int assertField(const blitz::Array<int, 1> observedValue, const char* fieldPath, bool sliceMode);
int assertField(const blitz::Array<int, 2> observedValue, const char* fieldPath, bool sliceMode);
int assertField(const blitz::Array<int, 3> observedValue, const char* fieldPath, bool sliceMode);
int assertField(const blitz::Array<int, 4> observedValue, const char* fieldPath, bool sliceMode);
int assertField(const blitz::Array<int, 5> observedValue, const char* fieldPath, bool sliceMode);
int assertField(const blitz::Array<int, 6> observedValue, const char* fieldPath, bool sliceMode);

int assertField(const blitz::Array<double, 1> observedValue, const char*fieldPath, bool sliceMode);
int assertField(const blitz::Array<double, 2> observedValue, const char*fieldPath, bool sliceMode);
int assertField(const blitz::Array<double, 3> observedValue, const char*fieldPath, bool sliceMode);
int assertField(const blitz::Array<double, 4> observedValue, const char*fieldPath, bool sliceMode);
int assertField(const blitz::Array<double, 5> observedValue, const char*fieldPath, bool sliceMode);
int assertField(const blitz::Array<double, 6> observedValue, const char*fieldPath, bool sliceMode);

#endif // _HELPER

