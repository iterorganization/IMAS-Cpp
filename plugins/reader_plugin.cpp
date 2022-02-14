#include "reader_plugin.h"

#include "simple_logger.h"

Reader_plugin::Reader_plugin()
{
}

Reader_plugin::~Reader_plugin()
{
}

void Reader_plugin::setParameter(const char* parameter_name, int datatype, int dim, int *size, void *data) {
}

void Reader_plugin::begin_global_action(int pulseCtx, const char* dataobjectname, int mode, int opCtx) {
    LOG_DEBUG << "Reader plugin called...";
    this->pulseCtx = pulseCtx;
    this->dataobjectname = std::string(dataobjectname);
    this->mode = mode;
    this->ctx = opCtx;
    LLenv lle = Lowlevel::getLLenv(pulseCtx);
    PulseContext *pctx= dynamic_cast<PulseContext *>(lle.context);
    this->shot = pctx->getShot();
    LOG_DEBUG << "shot=" << shot;
    std::size_t found = std::string(dataobjectname).find("/");
    if (found != std::string::npos) {
      std::string occStr = std::string(dataobjectname).substr(found+1, std::string::npos);
      LOG_DEBUG << "occStr=" << occStr;
      this->occurrence = std::stoi(occStr);
    }
    else {
      this->occurrence = 0;
    }
    LOG_DEBUG << "occurrence=" << occurrence;
  }
  
  void Reader_plugin::begin_slice_action(int pulseCtx, const char* dataobjectname, int mode, double time, int interp, int opCtx) {
    LOG_DEBUG << "called";
    this->time = time;
    this->interp = interp;
    return begin_global_action(pulseCtx, dataobjectname, mode, opCtx);
  }
  
  /*Implementation of begin_arraystruct_action*/
  void Reader_plugin::begin_arraystruct_action(int ctx, int *aosctx, const char* fieldPath, const char* timeBasePath, int *arraySize) 
  {
	
  }

int Reader_plugin::read_data(int ctx, const char* fieldPath, const char* timeBasePath, 
                void **data, int datatype, int dim, int *size) {
	LOG_DEBUG << "Reader plugin read_data called...";
    if (std::string(fieldPath) == "time") {
        LOG_DEBUG << "reading data for field path= " << fieldPath;
        //ual_read_data(ctx, fieldPath, timeBasePath, data, datatype, dim, size);
        //int *p = (int*) *data;
        /*LOG_DEBUG << "displaying data for field path= " << fieldPath;
        
        for (int j = 0; j < size[1]; j++) {
        for (int i = 0; i< size[0]; i++) {
            printf("%d\t", p[i+j*size[0]]);
        }
        printf("\n");
        }*/
        /*LOG_DEBUG << "displaying= " << fieldPath;
        for (int j = 0; j < size[1]; j++)
          for (int i = 0; i< size[0]; i++)
            p[i+j*size[0]]*=2;
        return 1; //data available
        */
    }

    return 0;
}
			  
void Reader_plugin::write_data(int ctx, const char* fieldPath, const char* timeBasePath, void *data, int datatype, int dim, int *size) {
	LOG_DEBUG << "Reader plugin write_data called...";
    if (std::string(fieldPath) == "time") {
        LOG_DEBUG << "reading data for field path= " << fieldPath;
    }

    //return 0;
}
