
class Ids
{
    protected:
        void setArray(Array<int,1>&array,int *arrayPtr, int dim1)
        {
            Array<int,1> newArray(arrayPtr, shape(dim1), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void setArray(Array<float,1>&array,float *arrayPtr, int dim1)
        {
            Array<float,1> newArray(arrayPtr, shape(dim1), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void setArray(Array<double,1>&array,double *arrayPtr, int dim1)
        {
            Array<double,1> newArray(arrayPtr, shape(dim1), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void setArray(Array<int,2>&array,int *arrayPtr, int dim1, int dim2)
        {
            Array<int,2> newArray(arrayPtr, shape(dim1, dim2), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void setArray(Array<float,2>&array,float *arrayPtr, int dim1, int dim2)
        {
            Array<float,2> newArray(arrayPtr, shape(dim1, dim2), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void setArray(Array<double,2>&array,double *arrayPtr, int dim1, int dim2)
        {
            Array<double,2> newArray(arrayPtr, shape(dim1, dim2), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void setArray(Array<int,3>&array,int *arrayPtr, int dim1, int dim2, int dim3)
        {
            Array<int,3> newArray(arrayPtr, shape(dim1, dim2, dim3), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void setArray(Array<float,3>&array,float *arrayPtr, int dim1, int dim2, int dim3)
        {
            Array<float,3> newArray(arrayPtr, shape(dim1, dim2, dim3), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void setArray(Array<double,3>&array,double *arrayPtr, int dim1, int dim2, int dim3)
        {
            Array<double,3> newArray(arrayPtr, shape(dim1, dim2, dim3), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }


        void setArray(Array<int,4>&array,int *arrayPtr, int dim1, int dim2, int dim3, int dim4)
        {
            Array<int,4> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void setArray(Array<float,4>&array,float *arrayPtr, int dim1, int dim2, int dim3, int dim4)
        {
            Array<float,4> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void setArray(Array<double,4>&array,double *arrayPtr, int dim1, int dim2, int dim3, int dim4)
        {
            Array<double,4> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }

        void setArray(Array<int,5>&array,int *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5)
        {
            Array<int,5> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void setArray(Array<float,5>&array,float *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5)
        {
            Array<float,5> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void setArray(Array<double,5>&array,double *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5)
        {
            Array<double,5> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }

        void setArray(Array<int,6>&array,int *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6)
        {
            Array<int,6> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5, dim6), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void setArray(Array<float,6>&array,float *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6)
        {
            Array<float,6> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5, dim6), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void setArray(Array<double,6>&array,double *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6)
        {
            Array<double,6> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5, dim6), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }
        void setArray(Array<double,7>&array,double *arrayPtr, int dim1, int dim2, int dim3, int dim4, int dim5, int dim6, 
		int dim7)
        {
            Array<double,7> newArray(arrayPtr, shape(dim1, dim2, dim3, dim4, dim5, dim6,dim7), duplicateData, fortranArray);
            array.resize(newArray.shape());
            array = newArray;
        }

};

