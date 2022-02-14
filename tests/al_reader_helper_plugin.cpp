#include "al_reader_helper_plugin.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "simple_logger.h"

AL_reader_helper_plugin::AL_reader_helper_plugin()
:pulseCtx(-1), ctx(-1), shot(-1), dataobjectname(), occurrence(-1), mode(-1), time(-1), interp(-1)
{
}

AL_reader_helper_plugin::~AL_reader_helper_plugin()
{
}

void AL_reader_helper_plugin::begin_global_action(int pulseCtx, const char* dataobjectname, int mode, int opCtx) {

    this->pulseCtx = pulseCtx;
    this->dataobjectname = std::string(dataobjectname);
    this->mode = mode;
    this->ctx = opCtx;
    LLenv lle = Lowlevel::getLLenv(pulseCtx);
    PulseContext *pctx= dynamic_cast<PulseContext *>(lle.context);
    this->shot = pctx->getShot();
    std::size_t found = std::string(dataobjectname).find("/");
    if (found != std::string::npos) {
        std::string occStr = std::string(dataobjectname).substr(found+1, std::string::npos);
        this->occurrence = std::stoi(occStr);
    }
    else {
        this->occurrence = 0;
    }
}

void AL_reader_helper_plugin::begin_slice_action(int pulseCtx, const char* dataobjectname, int mode, double time, int interp, int opCtx) {
    LOG_DEBUG;
    this->time = time;
    this->interp = interp;
    begin_global_action(pulseCtx, dataobjectname, mode, opCtx);
}

void AL_reader_helper_plugin::begin_arraystruct_action(int ctx, const char* fieldPath, const char* timeBasePath, int arraySize) {

    return;
}

int AL_reader_helper_plugin::read_data(int ctx, const char* fieldPath, const char* timeBasePath, 
                void **data, int datatype, int dim, int *size) {
    return 0; //data not available
}
