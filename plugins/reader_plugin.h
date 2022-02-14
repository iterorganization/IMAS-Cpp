#ifndef READER_PLUGIN_H
#define READER_PLUGIN_H 1

#include <string>
#include <vector>
#include <map>
#include <unordered_map>
#include <iostream>

#include "access_layer_plugin.h"

class Reader_plugin: public access_layer_plugin
{
  
  private:
    int pulseCtx;
    int ctx;
    int globalContext;
    int aosContext;
    int shot;
    std::string dataobjectname;
    int idsTimeMode;
    int occurrence;
    int mode;
    double time;
    int interp;

  public:
    Reader_plugin();
    ~Reader_plugin();

    virtual void setParameter(const char* parameter_name, int datatype, int dim, int *size, void *data);    
    virtual void begin_global_action(int pulseCtx, const char* dataobjectname, int mode, int opCtx);
    virtual void begin_slice_action(int pulseCtx, const char* dataobjectname, int mode, double time, int interp, int opCtx);
    virtual void begin_arraystruct_action(int ctx, int *aosctx, const char* fieldPath, const char* timeBasePath, int *arraySize);
    virtual int read_data(int ctx, const char* fieldPath, const char* timeBasePath, void **data, int datatype, int dim, int *size);
    virtual void write_data(int ctx, const char* fieldPath, const char* timeBasePath, void *data, int datatype, int dim, int *size);
};

extern "C" access_layer_plugin* create() {
  return new Reader_plugin;
}

extern "C" void destroy (access_layer_plugin* al_plugin) {
  delete al_plugin;
}

#endif
