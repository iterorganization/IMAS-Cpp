#include "partial_get_plugin.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "simple_logger.h"

PartialGetPlugin::PartialGetPlugin()
:pulseCtx(-1), ctx(-1), shot(-1), dataobjectname(), occurrence(-1), mode(-1), time(-1), interp(-1)
{
}

PartialGetPlugin::~PartialGetPlugin()
{
}

void PartialGetPlugin::setParameter(const char* parameter_name, int datatype, int dim, int *size, void *data) {
}

void PartialGetPlugin::begin_global_action(int pulseCtx, const char* dataobjectname, int mode, int opCtx) {

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

void PartialGetPlugin::begin_slice_action(int pulseCtx, const char* dataobjectname, int mode, double time, int interp, int opCtx) {
    //LOG_DEBUG;
    //this->time = time;
    //this->interp = interp;
    //begin_global_action(pulseCtx, dataobjectname, mode, opCtx);
    throw UALPluginException("PartialGetPlugin: slice operation not supported", LOG);
}

void PartialGetPlugin::begin_arraystruct_action(int ctx, int *aosctx, const char* fieldPath, const char* timeBasePath, int *arraySize) {
  if (std::string(fieldPath) == "frame") {
     LOG_WARNING << "ignoring frame";
     //ual_begin_arraystruct_action(ctx, fieldPath, timeBasePath, arraySize, aosctx);
     *arraySize = 0; 
  } 
}

int PartialGetPlugin::read_data(int ctx, const char* fieldPath, const char* timeBasePath, 
                void **data, int datatype, int dim, int *size) {
    //printf("debug plugin is called with path=%s\n", fieldPath);
    /*if (std::string(fieldPath) == "ids_properties/version_put/access_layer") {
        LOG_DEBUG << "reading data for field path= " << fieldPath;
        ual_read_data(ctx, fieldPath, timeBasePath, data, datatype, dim, size);
        char buff[100];
        snprintf(buff, sizeof(buff), "%s", (char*) *data);
        std::string buffAsStdStr = buff;
        LOG_DEBUG << "ids_properties/access_layer= " << buffAsStdStr;
        return 1; //data available
    } else if (std::string(fieldPath) == "ids_properties/homogeneous_time") {
        al_status_t s = ual_read_data(ctx, fieldPath, timeBasePath, data, datatype, dim, size);
        //printf("al_status_t.code = %d\n", s.code);
        return 1;
   } else if(std::string(fieldPath) == "image_raw") {
        //LOG_DEBUG << "skipping image_raw...";*/
        /*if (read_prev) {
           read_prev = false;
           return 0;
        }
        else {
          LOG_DEBUG << "reading frame=" << frames_count;
          al_status_t s = ual_read_data(ctx, fieldPath, timeBasePath, data, datatype, dim, size);
          read_prev = true;
          frames_count++;
        }*/

        //return 0;
   //}

   return 0;
}


void PartialGetPlugin::write_data(int ctx, const char* fieldPath, const char* timeBasePath, void *data, int datatype, int dim, int *size) {
}

