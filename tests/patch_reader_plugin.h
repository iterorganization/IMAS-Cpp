#ifndef PATCH_READER_PLUGIN_H
#define PATCH_READER_PLUGIN_H 1

#include "al_reader_helper_plugin.h"
#include "access_layer_plugin.h"

class PatchReaderPlugin: public AL_reader_helper_plugin
{
  public:
    PatchReaderPlugin();
    ~PatchReaderPlugin();

    int read_data(int ctx, const char* fieldPath, const char* timeBasePath, void **data, int datatype, int dim, int *size);

};

extern "C" access_layer_plugin* create() {
  return new PatchReaderPlugin;
}

extern "C" void destroy (access_layer_plugin* al_plugin) {
  delete al_plugin;
}

#endif