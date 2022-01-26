#ifndef CAMERA_IR_WRITE_PLUGIN_H
#define CAMERA_IR_WRITE_PLUGIN_H 1

#include <string>
#include <vector>
#include <map>
#include <unordered_map>
#include <iostream>

#include "access_layer_plugin.h"

typedef std::complex < double > std_complex_t;

 static const int EMPTY_INT = -999999999;
 static const float EMPTY_FLOAT = -9.0E35;
 static const double EMPTY_DOUBLE = -9.0E40;
 static const std_complex_t EMPTY_COMPLEX = std_complex_t(EMPTY_DOUBLE, EMPTY_DOUBLE);
 
 static const int   IDS_TIME_MODE_UNKNOWN       = EMPTY_INT; 
 static const int   IDS_TIME_MODE_HETEROGENEOUS = 0;
 static const int   IDS_TIME_MODE_HOMOGENEOUS   = 1;
 static const int   IDS_TIME_MODE_INDEPENDENT   = 2;

struct Camera_data
{
	int camera_handler;
	uint8_t* buffer;
	int buffer_size;
	int image_count;
	int chunk_size;
	int remaining_size;
	std::vector<double> times;
};

class Camera_ir_write_plugin: public access_layer_plugin
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
    
    int *chunks_buffer; //used for the PUT operation, contains all chunks data
    
    struct Camera_data camera_data;
    
    //PUT operation, getting data from the librir server
    void get_camera_data(int shot, int camera_number);
    
    void write_aos_content(int ctx, int aosctx, const char* fieldPath, const char* timeBasePath);
    void write_time_vector(int ctx, const char* fieldPath, const char* timeBasePath);

  public:
    Camera_ir_write_plugin();
    ~Camera_ir_write_plugin();
   
    virtual void setParameter(const char* parameter_name, int datatype, int dim, int *size, void *data); 
    virtual void begin_global_action(int pulseCtx, const char* dataobjectname, int mode, int opCtx);
    virtual void begin_slice_action(int pulseCtx, const char* dataobjectname, int mode, double time, int interp, int opCtx);
    virtual void begin_arraystruct_action(int ctx, int *aosctx, const char* fieldPath, const char* timeBasePath, int *arraySize);
    virtual int read_data(int ctx, const char* fieldPath, const char* timeBasePath, void **data, int datatype, int dim, int *size);
    virtual void write_data(int ctx, const char* fieldPath, const char* timeBasePath, void *data, int datatype, int dim, int *size);
    //virtual al_status_t close_pulse(int pulseCtx, int mode);
};

extern "C" access_layer_plugin* create() {
  return new Camera_ir_write_plugin;
}

extern "C" void destroy (access_layer_plugin* al_plugin) {
  printf("destroy has been called\n");
  delete al_plugin;
}

#endif
