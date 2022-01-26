#ifndef AL_READER_HELPER_PLUGIN_H
#define AL_READER_HELPER_PLUGIN_H 1

#include "access_layer_plugin.h"

class AL_reader_helper_plugin: public access_layer_plugin
{

  protected:
    int pulseCtx;
    int ctx;
    int shot;
    std::string dataobjectname;
    int occurrence;
    int mode;
    double time;
    int interp;


  public:
    AL_reader_helper_plugin();
    ~AL_reader_helper_plugin();

    virtual void setParameter(const char* parameter_name, int datatype, int dim, int *size, void *data);
    virtual void begin_arraystruct_action(int ctx, int *aosctx, const char* fieldPath, const char* timeBasePath, int *arraySize);
    virtual void begin_global_action(int pulseCtx, const char* dataobjectname, int mode, int opCtx);
    virtual void begin_slice_action(int pulseCtx, const char* dataobjectname, int mode, double time, int interp, int opCtx);
    virtual int read_data(int ctx, const char* fieldPath, const char* timeBasePath, void **data, int datatype, int dim, int *size);
    virtual void write_data(int ctx, const char* fieldPath, const char* timeBasePath, void *data, int datatype, int dim, int *size);

};

#endif
