#ifndef CAMERA_IR_PLUGIN_H
#define CAMERA_IR_PLUGIN_H 1

#include <string>
#include <vector>
#include <map>
#include <unordered_map>
#include <iostream>

#include "access_layer_plugin.h"

typedef std::complex < double > std_complex_t;

 static    const int EMPTY_INT = -999999999;
 static     const float EMPTY_FLOAT = -9.0E35;
 static     const double EMPTY_DOUBLE = -9.0E40;
 static const std_complex_t EMPTY_COMPLEX = std_complex_t(EMPTY_DOUBLE, EMPTY_DOUBLE);
 
 static const int   IDS_TIME_MODE_UNKNOWN       = EMPTY_INT; 
 static const int   IDS_TIME_MODE_HETEROGENEOUS = 0;
 static const int   IDS_TIME_MODE_HOMOGENEOUS   = 1;
 static const int   IDS_TIME_MODE_INDEPENDENT   = 2;

/**
Read a chunk at given offset into output buffer
*/
typedef int64_t(*readChunk_librir)(void*, int64_t, uint8_t * );
/**
Get file infos from opaque structure:
 - file size in bytes,
 - chunk number,
 - chunk size in bytes
*/
typedef void(*fileInfos_librir)(void*, int64_t * , int64_t *, int64_t *);
/**
Destroy internal opaque object
*/

typedef void(*destroy_opaque_librir)(void*);

struct Camera_data
{
	int camera_handler;
	uint8_t* buffer;
	int buffer_size;
	int image_count;
	int chunk_size;
	int remaining_size;
	std::vector<float> times;
};

/*A FileAccess object contains the following fields:
	- opaque: opaque resource (like a file descriptor) that will be passed to the functions infos, read and destroy.
	- infos: function to get file informations: its size, the number of chunk it contains and the chunk size.
	- read: read a full chunk into a destination buffer. This function should take care of the last chunk which is usually 
	smaller.
	- destroy: destroy the opaque object.
*/
struct FileAccess
{
	void * opaque;
	fileInfos_librir infos;
	readChunk_librir read;
	destroy_opaque_librir destroy;
};

struct CameraDataReader
{
	int64_t fileSize;
	int64_t chunkSize;
	int64_t chunkCount;
	int64_t filePos;
	int64_t currentChunk;
	FileAccess access;

	uint8_t * buffer;
};

/**
Create a file reader object from a #FileAccess object.
This file reader can be passed to the librir function #open_camera_file_reader().
*/
void * createCamReader(FileAccess access);

class Camera_ir_plugin: public access_layer_plugin
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
    
    int cam;
    //std::vector<int64_t> image_times; //the time of each image in nanoseconds (in WEST time base)
    
    int *chunks_buffer; //used for the PUT operation, contains all chunks data
    
    struct Camera_data camera_data;

    //void setContext(int ctx) {this->ctx = ctx;}
    void readIdsTimeMode( );
    //GET operation
     
    /* Check if the chunk is present in the chunk_buffers map */
    bool isChunkPresentInRAM(int chunk);
    
    /* Read the data of a chunk from the pulse file. The operation calls the backend */
    int readData(int ctx, std::string fieldPath, std::string timeBasePath, void** ptrData, int *retSize);
    
    /* Read the time vector of the camera_ir IDS  */
    void getTimeVector(void **time_vector, int *length);
    
    /* Put the chunk in memory*/
    int putChunkInRAM(int chunk, void *data, int* size);
    
    //al_status_t getChunksCount(int *chunksCount);
    
    //Used by the public getImage operation
    int getImage(int pos, void **data, int *size);
    
    //used by the public getImage() operation when starting the uncompression of the data of a camera
    void open_camera_handler();
    
    void close_camera_handler();
   
    //GET operation, call by the HLIs to get an uncompressed image
    int getImage(int ctx, const char *field, const char *timebase, void **data, int *size);
    
     
    
    /* Initialize the plugin */
    void initialize();
    

  public:
    Camera_ir_plugin();
    ~Camera_ir_plugin();
    
    int chunksCount;
    int fileSize;
    std::map <int, int> chunk_sizes;  //key = chunk index, value = chunk size
    std::map <int, uint8_t*> chunk_buffers; //key = chunk index, value = chunk buffer
    
    virtual void begin_global_action(int pulseCtx, const char* dataobjectname, int mode, int opCtx);
    virtual void begin_slice_action(int pulseCtx, const char* dataobjectname, int mode, double time, int interp, int opCtx);
    virtual void begin_arraystruct_action(int ctx, int aosctx, const char* fieldPath, const char* timeBasePath, int arraySize);
    virtual int read_data(int ctx, const char* fieldPath, const char* timeBasePath, void **data, int datatype, int dim, int *size);
    virtual void write_data(int ctx, const char* fieldPath, const char* timeBasePath, void *data, int datatype, int dim, int *size);
    //virtual al_status_t close_pulse(int pulseCtx, int mode);
    
    /* Check if a chunk is already in memory. If not, the plugin fetches the chunk from the pulse file and places it into memory. */
    int check(int chunk);
    
};

extern "C" access_layer_plugin* create() {
  return new Camera_ir_plugin;
}

extern "C" void destroy (access_layer_plugin* al_plugin) {
  delete al_plugin;
}

FileAccess createCameraDataAccess(Camera_ir_plugin *plugin);

#endif
