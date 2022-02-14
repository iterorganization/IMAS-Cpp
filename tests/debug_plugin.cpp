#include "debug_plugin.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "simple_logger.h"

Debug_plugin::Debug_plugin()
:pulseCtx(-1), ctx(-1), shot(-1), dataobjectname(), occurrence(-1), mode(-1), time(-1), interp(-1)
{
}

Debug_plugin::~Debug_plugin()
{
}

void Debug_plugin::begin_global_action(int pulseCtx, const char* dataobjectname, int mode, int opCtx) {

    this->pulseCtx = pulseCtx;
    this->dataobjectname = std::string(dataobjectname);
    this->mode = mode;
    this->ctx = opCtx;
    LLenv lle = Lowlevel::getLLenv(pulseCtx);
    PulseContext *pctx= dynamic_cast<PulseContext *>(lle.context);
    this->shot = pctx->getShot();
    LOG_DEBUG << "Shot= " << shot;
    
    std::size_t found = std::string(dataobjectname).find("/");
    if (found != std::string::npos) {
        std::string occStr = std::string(dataobjectname).substr(found+1, std::string::npos);
        this->occurrence = std::stoi(occStr);
    }
    else {
        this->occurrence = 0;
    }
    LOG_DEBUG << "Occurrence= " << occurrence;
}

void Debug_plugin::begin_slice_action(int pulseCtx, const char* dataobjectname, int mode, double time, int interp, int opCtx) {
    LOG_DEBUG;
    this->time = time;
    this->interp = interp;
    begin_global_action(pulseCtx, dataobjectname, mode, opCtx);
}

void Debug_plugin::begin_arraystruct_action(int ctx, const char* fieldPath, const char* timeBasePath, int arraySize) {

    return;
}

int Debug_plugin::read_data(int ctx, const char* fieldPath, const char* timeBasePath, 
                void **data, int datatype, int dim, int *size) {

    if (std::string(fieldPath) == "ids_properties/version_put/access_layer") {
        LOG_DEBUG << "reading data for field path= " << fieldPath;
        ual_read_data(ctx, fieldPath, timeBasePath, data, datatype, dim, size);
        char buff[100];
        snprintf(buff, sizeof(buff), "%s", (char*) *data);
        std::string buffAsStdStr = buff;
        LOG_DEBUG << "ids_properties/access_layer= " << buffAsStdStr;
        return 1; //data available
    }

    /*if (std::string(fieldPath) == "image_raw") {
        LOG_DEBUG << "reading data for field path= " << fieldPath;
        ual_read_data(ctx, fieldPath, timeBasePath, data, datatype, dim, size);
        LOG_DEBUG << "displaying data for field path= " << fieldPath;
        int *p = (int*) *data;
        for (int j = 0; j < size[1]; j++) {
        for (int i = 0; i< size[0]; i++) {
            printf("%d\t", p[i+j*size[0]]);
        }
        printf("\n");
        }*/
        /*LOG_DEBUG << "multiplying data by 2 for field path= " << fieldPath;
        for (int j = 0; j < size[1]; j++)
        for (int i = 0; i< size[0]; i++)
            p[i+j*size[0]]*=2;*/
        //return 1; //data available
    //}

    return 0;
}
