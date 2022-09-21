#ifndef DEBUG_PLUGIN_H
#define DEBUG_PLUGIN_H 1

#include <string>
#include <vector>
#include <map>
#include <unordered_map>
#include <iostream>

#include "access_layer_plugin.h"


class Debug_plugin: public access_layer_plugin
{

  private:
    int pulseCtx;
    int ctx;
    int shot;
    std::string dataobjectname;
    int occurrence;
    int mode;
    double time;
    int interp;


  public:
    Debug_plugin();
    ~Debug_plugin();

    virtual void begin_arraystruct_action(int ctx, const char* fieldPath, const char* timeBasePath, int arraySize);
    virtual void begin_global_action(int pulseCtx, const char* dataobjectname, int mode, int opCtx);
    virtual void begin_slice_action(int pulseCtx, const char* dataobjectname, int mode, double time, int interp, int opCtx);
    virtual int read_data(int ctx, const char* fieldPath, const char* timeBasePath, void **data, int datatype, int dim, int *size);

};

extern "C" access_layer_plugin* create() {
  return new Debug_plugin;
}

extern "C" void destroy (access_layer_plugin* al_plugin) {
  delete al_plugin;
}

#endif