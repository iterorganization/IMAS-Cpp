#include "patch_reader_plugin.h"

#include "simple_logger.h"

PatchReaderPlugin::PatchReaderPlugin()
{
}

PatchReaderPlugin::~PatchReaderPlugin()
{
}

int PatchReaderPlugin::read_data(int ctx, const char* fieldPath, const char* timeBasePath, 
                void **data, int datatype, int dim, int *size) {

    if (std::string(fieldPath) == "image_raw") {
        LOG_DEBUG << "reading data for field path= " << fieldPath;
        ual_read_data(ctx, fieldPath, timeBasePath, data, datatype, dim, size);
        int *p = (int*) *data;
        /*LOG_DEBUG << "displaying data for field path= " << fieldPath;
        
        for (int j = 0; j < size[1]; j++) {
        for (int i = 0; i< size[0]; i++) {
            printf("%d\t", p[i+j*size[0]]);
        }
        printf("\n");
        }*/
        LOG_DEBUG << "multiplying data by 2 for field path= " << fieldPath;
        for (int j = 0; j < size[1]; j++)
          for (int i = 0; i< size[0]; i++)
            p[i+j*size[0]]*=2;
        return 1; //data available
    }

    return 0;
}