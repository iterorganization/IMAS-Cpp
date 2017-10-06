#ifndef _HELPER

#define _HELPER


#include <blitz/array.h>


using namespace blitz;


int dim1 = 2;
int dim2 = 2;
int dim3 = 2;
int dim4 = 2;
int dim5 = 2;
int dim6 = 2;

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

void setValue(std::string& idsField, bool isReduced)
{

}

void setValue(int& idsField, bool isReduced)
{
	idsField = getInteger();
}


void setValue(double& idsField, bool isReduced)
{
	idsField = getDouble();
}

void setValue(Array<int,1>&array, bool isReduced)
{
	int size = -1;
	int *arrayPtr = NULL;
	
	const blitz::TinyVector<int, 1> *ptrShape;

	if(isReduced)
	{
		size = 1;
		ptrShape = new const blitz::TinyVector<int, 1> (1);
	}
	else
	{
		size = dim1;
		ptrShape = new const blitz::TinyVector<int, 1> (dim1);
	}


	arrayPtr = generateIntegerArray(size);
	Array<double,1> newArray(arrayPtr, *ptrShape);
	array.resize(*ptrShape);
	array = newArray;;
}


void setValue(Array<double,1>&array, bool isReduced)
{
	int size = -1;
	double *arrayPtr = NULL;
	const blitz::TinyVector<int, 1> *ptrShape;

	if(isReduced)
	{
		size = 1;
		ptrShape = new const blitz::TinyVector<int, 1> (1);
	}
	else
	{
		size = dim1;
		ptrShape = new const blitz::TinyVector<int, 1> (dim1);
	}

	arrayPtr = generateDoubleArray(size);
	Array<double,1> newArray(arrayPtr, *ptrShape);
	array.resize(*ptrShape);
	array = newArray;
}

void setValue(Array<int,2>&array, bool isReduced)
{
	int size = -1;
	int *arrayPtr = NULL;
	const blitz::TinyVector<int, 2> *ptrShape;

	if(isReduced)
	{
		size = 1 * dim2;
		ptrShape = new const blitz::TinyVector<int, 2> (1, dim2);
	}
	else
	{
		size = dim1 * dim2;
		ptrShape = new const blitz::TinyVector<int, 2> (dim1, dim2);
	}

	arrayPtr = generateIntegerArray(size);
	Array<int,2> newArray(arrayPtr, *ptrShape);
	array.resize(*ptrShape);
	array = newArray;
}

void setValue(Array<double,2>&array, bool isReduced)
{
	int size = -1;
	double *arrayPtr = NULL;
	const blitz::TinyVector<int, 2> *ptrShape;

	if(isReduced)
	{
		size = 1 * dim2;
		ptrShape = new const blitz::TinyVector<int, 2> (1, dim2);
	}
	else
	{
		size = dim1 * dim2;
		ptrShape = new const blitz::TinyVector<int, 2> (dim1, dim2);
	}

	arrayPtr = generateDoubleArray(size);
	
	Array<double,2> newArray(arrayPtr, *ptrShape);
	array.resize(*ptrShape);
	array = newArray;
}

void setValue(Array<int,3>&array, bool isReduced)
{
	int size = -1;
	int *arrayPtr = NULL;
	const blitz::TinyVector<int, 3> *ptrShape;

	if(isReduced)
	{
		size = 1 * dim2 * dim3;
		ptrShape = new const blitz::TinyVector<int, 3> (1, dim2, dim3);
	}
	else
	{
		size = dim1 * dim2 * dim3;
		ptrShape = new const blitz::TinyVector<int, 3> (dim1, dim2, dim3);
	}

	arrayPtr = generateIntegerArray(size);

	Array<int,3> newArray(arrayPtr, *ptrShape);
	array.resize(*ptrShape);
	array = newArray;
}

void setValue(Array<double,3>&array, bool isReduced)
{
	int size = -1;
	double *arrayPtr = NULL;
	const blitz::TinyVector<int, 3> *ptrShape;

	if(isReduced)
	{
		size = 1 * dim2 * dim3;
		ptrShape = new const blitz::TinyVector<int, 3> (1, dim2, dim3);
	}
	else
	{
		size = dim1 * dim2 * dim3;
		ptrShape = new const blitz::TinyVector<int, 3> (dim1, dim2, dim3);
	}

	arrayPtr = generateDoubleArray(size);

	Array<double,3> newArray(arrayPtr, *ptrShape);
	array.resize(*ptrShape);
	array = newArray;
}

void setValue(Array<int,4>&array, bool isReduced)
{
	int size = -1;
	int *arrayPtr = NULL;
	const blitz::TinyVector<int, 4> *ptrShape;

	if(isReduced)
	{
		size = 1 * dim2 * dim3 * dim4;
		ptrShape = new const blitz::TinyVector<int, 4> (1, dim2, dim3, dim4);
	}
	else
	{
		size = dim1 * dim2 * dim3 * dim4;
		ptrShape = new const blitz::TinyVector<int, 4> (dim1, dim2, dim3, dim4);
	}


	arrayPtr = generateIntegerArray(size);

	Array<int,4> newArray(arrayPtr, *ptrShape);
	array.resize(*ptrShape);
	array = newArray;
}
void setValue(Array<double,4>&array, bool isReduced)
{
	int size = -1;
	double *arrayPtr = NULL;
	const blitz::TinyVector<int, 4> *ptrShape;

	if(isReduced)
	{
		size = 1 * dim2 * dim3 * dim4;
		ptrShape = new const blitz::TinyVector<int, 4> (1, dim2, dim3, dim4);
	}
	else
	{
		size = dim1 * dim2 * dim3 * dim4;
		ptrShape = new const blitz::TinyVector<int, 4> (dim1, dim2, dim3, dim4);
	}


	arrayPtr = generateDoubleArray(size);

	Array<double,4> newArray(arrayPtr, *ptrShape);
	array.resize(*ptrShape);
	array = newArray;
}

void setValue(Array<int,5>&array, bool isReduced)
{
	int size = -1;
	int *arrayPtr = NULL;
	const blitz::TinyVector<int, 5> *ptrShape;

	if(isReduced)
	{
		size = 1 * dim2 * dim3 * dim4 * dim5;
		ptrShape = new const blitz::TinyVector<int, 5> (1, dim2, dim3, dim4, dim5);
	}
	else
	{
		size = dim1 * dim2 * dim3 * dim4 * dim5;
		ptrShape = new const blitz::TinyVector<int, 5> (dim1, dim2, dim3, dim4, dim5);
	}

	
	arrayPtr = generateIntegerArray(size);

	Array<int,5> newArray(arrayPtr, *ptrShape);
	array.resize(*ptrShape);
	array = newArray;
}
void setValue(Array<double,5>&array, bool isReduced)
{
	int size = -1;
	double *arrayPtr = NULL;
	const blitz::TinyVector<int, 5> *ptrShape;

	if(isReduced)
	{
		size = 1 * dim2 * dim3 * dim4 * dim5;
		ptrShape = new const blitz::TinyVector<int, 5> (1, dim2, dim3, dim4, dim5);
	}
	else
	{
		size = dim1 * dim2 * dim3 * dim4 * dim5;
		ptrShape = new const blitz::TinyVector<int, 5> (dim1, dim2, dim3, dim4, dim5);

	}

	
	arrayPtr = generateDoubleArray(size);

	Array<double,5> newArray(arrayPtr, *ptrShape);
	array.resize(*ptrShape);
	array = newArray;
}

void setValue(Array<int,6>&array, bool isReduced)
{		
	int size = -1;
	int *arrayPtr = NULL;
	const blitz::TinyVector<int, 6> *ptrShape;

	if(isReduced)
	{
		size = 1 * dim2 * dim3 * dim4 * dim5 * dim6;
		ptrShape = new const blitz::TinyVector<int, 6> (1, dim2, dim3, dim4, dim5, dim6);
	}
	else
	{
		size = dim1 * dim2 * dim3 * dim4 * dim5 * dim6;
		ptrShape = new const blitz::TinyVector<int, 6> (dim1, dim2, dim3, dim4, dim5, dim6);
	}

	
	arrayPtr = generateIntegerArray(size);

	Array<int,6> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5, dim6));
	array.resize(*ptrShape);
	array = newArray;
}

void setValue(Array<double,6>&array, bool isReduced)
{
	int size = -1;
	double *arrayPtr = NULL;
	const blitz::TinyVector<int, 6> *ptrShape;

	if(isReduced)
	{
		size = 1 * dim2 * dim3 * dim4 * dim5 * dim6;
		ptrShape = new const blitz::TinyVector<int, 6> (1, dim2, dim3, dim4, dim5, dim6);
	}
	else
	{
		size = dim1 * dim2 * dim3 * dim4 * dim5 * dim6;
		ptrShape = new const blitz::TinyVector<int, 6> (dim1, dim2, dim3, dim4, dim5, dim6);
	}

	
	arrayPtr = generateDoubleArray(size);

	Array<double,6> newArray(arrayPtr, *ptrShape);
	array.resize(*ptrShape);
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

	setValue(expectedValue, sliceMode);
	

	
	if(assertShape(expectedValue.shape(), observedValue.shape(), fieldPath))
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
	setValue(expectedValue, sliceMode);


	if(assertShape(expectedValue.shape(), observedValue.shape(), fieldPath))
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

