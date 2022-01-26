#include "imas3121_plugin.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "simple_logger.h"

#include <iostream>
#include <iomanip>
#include <ctime>
#include <sstream>

IMAS3121_plugin::IMAS3121_plugin()
:pulseCtx(-1), ctx(-1), shot(-1), dataobjectname(), occurrence(-1), mode(-1), time(-1), interp(-1)
{
}

IMAS3121_plugin::~IMAS3121_plugin()
{
}

void IMAS3121_plugin::begin_global_action(int pulseCtx, const char* dataobjectname, int mode, int opCtx) {

    this->pulseCtx = pulseCtx;
    this->dataobjectname = std::string(dataobjectname);
    this->mode = mode;
    this->ctx = opCtx;
    LLenv lle = Lowlevel::getLLenv(opCtx);
    OperationContext *opctx = dynamic_cast < OperationContext * >(lle.context);
    PulseContext *pctx = opctx->getPulseContext();
    this->shot = pctx->getShot();
    //LOG_DEBUG << "Shot= " << shot;
    
    std::size_t found = std::string(dataobjectname).find("/");
    if (found != std::string::npos) {
        std::string occStr = std::string(dataobjectname).substr(found+1, std::string::npos);
        this->occurrence = std::stoi(occStr);
    }
    else {
        this->occurrence = 0;
    }
    //LOG_DEBUG << "Occurrence= " << occurrence;
}

void IMAS3121_plugin::begin_slice_action(int pulseCtx, const char* dataobjectname, int mode, double time, int interp, int opCtx) {
    LOG_DEBUG;
    this->time = time;
    this->interp = interp;
    begin_global_action(pulseCtx, dataobjectname, mode, opCtx);
}

void IMAS3121_plugin::begin_arraystruct_action(int ctx, int *aosctx, const char* fieldPath, const char* timeBasePath, int *arraySize) {

    return;
}

int IMAS3121_plugin::read_data(int ctx, const char* fieldPath, const char* timeBasePath, 
                void **data, int datatype, int dim, int *size) {
    return 0;
}


void IMAS3121_plugin::write_data(int ctx, const char* fieldPath, const char* timeBasePath, void *data, int datatype, int dim, int *size) {
    LOG_DEBUG << "Patching creation_date... ";
    auto t = std::time(nullptr);
    auto tm = *std::localtime(&t);
    std::ostringstream oss;
    //oss << std::put_time(&tm, "%d-%m-%Y %H-%M-%S");
    oss << std::put_time(&tm, "%Y-%m-%d");
    auto text = oss.str(); 
    void* ptrData = (void *) (text.c_str());
    int arrayOfSizes[1] = {(int)text.size()};
    ual_write_data(ctx, fieldPath, timeBasePath, ptrData, CHAR_DATA, 1, arrayOfSizes);
}

void IMAS3121_plugin::setParameter(const char* parameter_name, int datatype, int dim, int *size, void *data) {
}

