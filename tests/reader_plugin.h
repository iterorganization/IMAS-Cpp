#ifndef READER_PLUGIN_H
#define READER_PLUGIN_H 1

#include "al_reader_helper_plugin.h"
#include "access_layer_plugin.h"

class ReaderPlugin: public AL_reader_helper_plugin
{
  public:
    ReaderPlugin();
    ~ReaderPlugin();

    int read_data(int ctx, const char* fieldPath, const char* timeBasePath, void **data, int datatype, int dim, int *size);

};

extern "C" access_layer_plugin* create() {
  return new ReaderPlugin;
}

extern "C" void destroy (access_layer_plugin* al_plugin) {
  delete al_plugin;
}

#endif