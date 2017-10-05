#ifndef _HELPER

#define _HELPER


#include <blitz/array.h>


using namespace blitz;

/*
int dim1 = 3;
int dim2 = 1;
int dim3 = 1;
int dim4 = 1;
int dim5 = 1;
int dim6 = 1;
*/

const char* PRINTABLE = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!\"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~\t\n\r";
int randseed = (int)time(NULL);
Range all = Range::all();

/*******************************************************************************/
/**********************    Random data generation        ***********************/
/*******************************************************************************/
int getInteger()
{
	return (int)rand();
}

int* generateIntegerArray(int size)
{
	int* array = new int[size];
	for (int i = 0; i < size; i++)
	{
		array[i] = getInteger();
	}

	return array;
}

double getDouble() 
{
	return (double) rand();
}

double* generateDoubleArray(int size)
{
	double* array = new double[size];
	for (int i = 0; i < size; i++)
	{
		array[i] = getDouble();
	}

	return array;
}

char* getString()
{
	return (char*)PRINTABLE;
}


/*******************************************************************************/
/**********************         Setting arrays           ***********************/
/*******************************************************************************/

void setArray(Array<int,1>&array,int dim1)
{
	int size = dim1;
	int *arrayPtr = generateIntegerArray(size);

	Array<int,1> newArray(arrayPtr, shape(dim1));
	array.resize(newArray.shape());
	array = newArray;
}

Array<int,1> getIntegerArray(int dim1)
{
	int size = dim1;
	int *arrayPtr = generateIntegerArray(size);

	Array<int,1> newArray(arrayPtr, shape(dim1));
	return newArray;
}

void setArray(Array<double,1>&array, int dim1)
{
	int size = dim1;
	double *arrayPtr = generateDoubleArray(size);
	Array<double,1> newArray(arrayPtr, shape(dim1));
	array.resize(newArray.shape());
	array = newArray;
}

Array<double,1> getDoubleArray( int dim1)
{
	int size = dim1;
	double *arrayPtr = generateDoubleArray(size);
	Array<double,1> newArray(arrayPtr, shape(dim1));

	return newArray;
}

void setArray(Array<int,2>&array, int dim1, int dim2)
{
	int size = dim1 * dim2 ;
	int *arrayPtr = generateIntegerArray(size);
	Array<int,2> newArray(arrayPtr, shape(dim1, dim2));
	array.resize(newArray.shape());
	array = newArray;
}

void setArray(Array<double,2>&array, int dim1, int dim2)
{
	int size = dim1 * dim2;
	double *arrayPtr = generateDoubleArray(size);
	Array<double,2> newArray(arrayPtr, shape(dim1, dim2));
	array.resize(newArray.shape());
	array = newArray;
}

void setArray(Array<int,3>&array, int dim1, int dim2, int dim3)
{
	int size = dim1 * dim2 * dim3;
	int *arrayPtr = generateIntegerArray(size);

	Array<int,3> newArray(arrayPtr, shape(dim1, dim2, dim3));
	array.resize(newArray.shape());
	array = newArray;
}

void setArray(Array<double,3>&array, int dim1, int dim2, int dim3)
{
	int size = dim1 * dim2 * dim3;
	double *arrayPtr = generateDoubleArray(size);

	Array<double,3> newArray(arrayPtr, shape(dim1, dim2, dim3));
	array.resize(newArray.shape());
	array = newArray;
}

void setArray(Array<int,4>&array, int dim1, int dim2, int dim3, int dim4)
{
	int size = dim1 * dim2 * dim3 * dim4;
	int *arrayPtr = generateIntegerArray(size);

	Array<int,4> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4));
	array.resize(newArray.shape());
	array = newArray;
}
void setArray(Array<double,4>&array, int dim1, int dim2, int dim3, int dim4)
{
	int size = dim1 * dim2 * dim3 * dim4;
	double *arrayPtr = generateDoubleArray(size);

	Array<double,4> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4));
	array.resize(newArray.shape());
	array = newArray;
}

void setArray(Array<int,5>&array, int dim1, int dim2, int dim3, int dim4, int dim5)
{
	int size = dim1 * dim2 * dim3 * dim4 * dim5;
	int *arrayPtr = generateIntegerArray(size);

	Array<int,5> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5));
	array.resize(newArray.shape());
	array = newArray;
}
void setArray(Array<double,5>&array, int dim1, int dim2, int dim3, int dim4, int dim5)
{
	int size = dim1 * dim2 * dim3 * dim4 * dim5;
	double *arrayPtr = generateDoubleArray(size);

	Array<double,5> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5));
	array.resize(newArray.shape());
	array = newArray;
}

void setArray(Array<int,6>&array, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6)
{
	int size = dim1 * dim2 * dim3 * dim4 * dim5 * dim6;
	int *arrayPtr = generateIntegerArray(size);

	Array<int,6> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5, dim6));
	array.resize(newArray.shape());
	array = newArray;
}

void setArray(Array<double,6>&array, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6)
{
	int size = dim1 * dim2 * dim3 * dim4 * dim5 * dim6;
	double *arrayPtr = generateDoubleArray(size);

	Array<double,6> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5, dim6));
	array.resize(newArray.shape());
	array = newArray;
}

/*******************************************************************************/
/**********************         Field checking           ***********************/
/*******************************************************************************/

/**********************        Assert array shape        ***********************/

int assertShape(const blitz::TinyVector<int, 1> expectedShape, const blitz::TinyVector<int, 1> observedShape, const char* fieldPath)
{
	if(any(expectedShape != observedShape))
	{
		std::cerr <<  fieldPath << " : different shapes, observed=" << observedShape << ", expected=" << expectedShape<<std::endl;
		return -1;
	}
	return 0;
}

/**********************        Assert field value        ***********************/
int assertField(std::string&, const char* fieldPath, bool sliceMode)
{
	char* expectedValue = getString();
	return 0;
}

int assertField(int observedValue, const char* fieldPath,  bool sliceMode)
{
	int expectedValue = getInteger();
	if(expectedValue != observedValue)
	{
		std::cerr <<  fieldPath << " : different values, observed=" << observedValue << ", expected=" << expectedValue<<std::endl;
		return -1;
	}
	return 0;
}

int assertField(double observedValue, const char* fieldPath, bool sliceMode)
{
	double expectedValue = getDouble();
	
	if(expectedValue != observedValue)
	{
		std::cerr <<  fieldPath << " : different values, observed=" << observedValue << ", expected=" << expectedValue<<std::endl;
		return -1;
	}
	return 0;
	
}

int assertField(const blitz::Array<int, 1> observedValue, const char* fieldPath, bool sliceMode)
{
	blitz::Array<int, 1> expectedValue;

	setArray(expectedValue, 3);
	

	
	if(assertShape(expectedValue(Range(1)).shape(), observedValue.shape(), fieldPath))
		return -1;
	

	if(any(expectedValue != observedValue))
	{
		std::cerr <<  fieldPath << " : different values, observed=" << observedValue << ", expected=" << expectedValue<<std::endl;
		return -1;
	}
	return 0;
}

int assertField(const blitz::Array<double, 1> observedValue, const char*fieldPath, bool sliceMode)
{

	const blitz::TinyVector<int, 1> *expectedShape;
 	const blitz::TinyVector<int, 1> *observedShape;

	blitz::Array<double, 1> expectedValue;
	setArray(expectedValue, 3);


	if(assertShape(expectedValue(Range(1)).shape(), observedValue.shape(), fieldPath))
{
	std::cerr <<" bla"<<std::endl;
		return -1;
	
}
	if(any(expectedValue != observedValue))
	{
		std::cerr <<  fieldPath << " : different values, observed=" << observedValue << ", expected=" << expectedValue<<std::endl;
		return -1;
	}

	return 0;
}


#endif // _HELPER

