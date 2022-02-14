#include "reader_plugin.h"

#include "simple_logger.h"

ReaderPlugin::ReaderPlugin()
{
}

ReaderPlugin::~ReaderPlugin()
{
}

int ReaderPlugin::read_data(int ctx, const char* fieldPath, const char* timeBasePath, 
                void **data, int datatype, int dim, int *size) {
    LOG_DEBUG << "reading data for field path= " << fieldPath;
    ual_read_data(ctx, fieldPath, timeBasePath, data, datatype, dim, size);
    return 1; //data available
}