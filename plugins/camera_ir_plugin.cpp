  #include "camera_ir_plugin.h"
  
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>
  #include "video_io.h"
  #include "simple_logger.h"
  
  Camera_ir_plugin::Camera_ir_plugin()
  :pulseCtx(-1), globalContext(-1), aosContext(-1), shot(-1), dataobjectname(), idsTimeMode(-1), occurrence(-1), mode(-1), time(-1), interp(-1), 
  cam(0), chunksCount(0), fileSize(0), chunk_sizes(), chunk_buffers()
  {
  }
  
  Camera_ir_plugin::~Camera_ir_plugin()
  {
  }
  
  void Camera_ir_plugin::readIdsTimeMode()
  {
	  std::string fieldPath = "ids_properties/homogeneous_time";
	  std::string timeBasePath = "";
	  int opCtx = -1;
	  
	  //Opening a global context
	  LOG_DEBUG << "readIdsTimeMode opening context...";
	  al_status_t al_status = ual_begin_global_action(pulseCtx, dataobjectname.c_str(), READ_OP, &opCtx);
	  if(al_status.code < 0 || opCtx < 0)
		throw UALPluginException("Camera_ir_plugin: readIdsTimeMode opening context failed...", LOG); 

	  int size[MAXDIM];
	  int *timeMode = &idsTimeMode;
	  al_status = ual_read_data(opCtx, fieldPath.c_str(), timeBasePath.c_str(), (void**) &timeMode, INTEGER_DATA, 0, size);
	  LOG_DEBUG << "readIdsTimeMode fetched value=" << idsTimeMode;	  		  
	  if (al_status.code < 0)
	  {   
		ual_end_action(opCtx);
		throw UALPluginException("Camera_ir_plugin: readIdsTimeMode has failed...", LOG); 
	  }
	  
	  switch(idsTimeMode)
	  {
		  case IDS_TIME_MODE_UNKNOWN:     
		  case IDS_TIME_MODE_HETEROGENEOUS: 
		  case IDS_TIME_MODE_HOMOGENEOUS:   
		  case IDS_TIME_MODE_INDEPENDENT:   
			break;
		  
		  default: 
			throw UALPluginException("Camera_ir_plugin: time dependency mode (ids_properties/homogeneous_time) set to unknown value!", LOG); 
	  }
	  
	  ual_end_action(opCtx);
  }
  
  void Camera_ir_plugin::begin_global_action(int pulseCtx, const char* dataobjectname, int mode, int opCtx) {
  
	  this->pulseCtx = pulseCtx;
	  this->dataobjectname = std::string(dataobjectname);
	  this->mode = mode;
	  //this->ctx = opCtx;
	  LLenv lle = Lowlevel::getLLenv(pulseCtx);
	  PulseContext *pctx= dynamic_cast<PulseContext *>(lle.context);
	  this->shot = pctx->getShot();
	  std::size_t found = std::string(dataobjectname).find("/");
	  if (found != std::string::npos) {
		  std::string occStr = std::string(dataobjectname).substr(found+1, std::string::npos);
		  this->occurrence = std::stoi(occStr);
	  }
	  else {
		this->occurrence = 0;
	  }
	  LOG_DEBUG << "shot=" << shot;
	  LOG_DEBUG << "occurrence=" << occurrence;
  }
  
  void Camera_ir_plugin::begin_slice_action(int pulseCtx, const char* dataobjectname, int mode, double time, int interp, int opCtx) {
	  LOG_DEBUG << "called";
	  LOG_DEBUG << "time=" << time;
	  this->time = time;
	  this->interp = interp;
	  return begin_global_action(pulseCtx, dataobjectname, mode, opCtx);
  }
  
  /*Implementation of begin_arraystruct_action*/
  void Camera_ir_plugin::begin_arraystruct_action(int ctx, int *aosctx, const char* fieldPath, const char* timeBasePath, int *arraySize) {
	  LOG_DEBUG << "begin_arraystruct_action called for fieldPath=" << fieldPath;		 					 
	  if (std::string(fieldPath) != "frame") {
		return;
	  }
	  //this->ctx = *aosctx;
	  LOG_DEBUG << "fieldPath:" << fieldPath;
	  LOG_DEBUG << "arraySize:" << *arraySize;
	  LOG_DEBUG << "aosctx:" << *aosctx;
	  initialize();
  }
  
  
  void Camera_ir_plugin::open_camera_handler() { 
	  if (this->cam > 0)
		return;
	  LOG_DEBUG << "opening camera...";
	  this->cam = open_camera_file_reader(createCamReader(createCameraDataAccess(this)), NULL);
	  if (cam <= 0) 
		throw UALPluginException("Camera_ir_plugin: error calling open_camera_file_reader", LOG); 
	  
	  LOG_DEBUG << "camera handler=" << this->cam;
	  
	  int w, h;
	  get_image_size(this->cam, &w, &h);
	  std::vector<unsigned short> pixels;
	  pixels.resize(w*h);
	  load_image(this->cam, 0, 0, pixels.data());  //PATCH
	  
	  LOG_DEBUG << "returning ";
  }
  
  void Camera_ir_plugin::close_camera_handler() {
	  LOG_DEBUG << "closing...";
	  if (this->cam > 0)
		close_camera(this->cam);
	  this->cam = 0;
  }
  
  bool Camera_ir_plugin::isChunkPresentInRAM(int chunk) {
	  if (chunk_buffers.find(chunk) != chunk_buffers.end()) { //chunk already exists, nothing to do
		LOG_DEBUG << "chunk " << chunk << " already present in RAM:";
		return true;
	  }
	  LOG_DEBUG << "chunk " << chunk << " not yet present in RAM";
	  return false;
  }
  
  int Camera_ir_plugin::putChunkInRAM(int chunk, void *data, int* size) {
	  if (data == nullptr) {
		LOG_DEBUG << "data is empty for chunk=" << chunk;
		return 0;
	  }
	  LOG_DEBUG << "current size of chunk_buffers=" << (int) chunk_buffers.size();
	  int *data_int = (int*) data;
	  uint8_t* chunk_buffer = (uint8_t*) malloc(sizeof(uint8_t) *  size[1]);
	  
	  for (int i = 0; i < size[1]; i++)
		chunk_buffer[i] = (uint8_t) data_int[i];
	  
	  this->chunk_buffers[chunk] = chunk_buffer;
	  this->chunk_sizes[chunk] = size[1];
	  return 0;
  }
  
  int Camera_ir_plugin::check(int chunk) {
	  int status;
	  if (! isChunkPresentInRAM(chunk) ) { //is the chunk of compressed data already in memory?
		  LOG_DEBUG << "check::aosCtx:" << aosContext;
		  LOG_DEBUG << "getting context object...for chunk:" << chunk;
		  LLenv lle = Lowlevel::getLLenv(aosContext);
		  ArraystructContext *actx = static_cast<ArraystructContext *>(lle.context);
		  
		  int current_index = actx->getIndex();
		  LOG_DEBUG << "current_index=" << current_index << " in context...for chunk=" << chunk;
		  int step = chunk - current_index;
		  LOG_DEBUG << "step=" << step << " for chunk " << chunk;
		  actx->nextIndex(step);
		  
		  LOG_DEBUG << "new context index=" << actx->getIndex() << " for chunk=" << chunk;
		  
		  void* compressedData = NULL;
		  int retSize[MAXDIM];
		  std::string fieldPath = "image_raw";
		  std::string timeBasePath = "";
		  LOG_DEBUG << "checking index =" << actx->getIndex();
		  //reading the chunk from the pulse file
		  status = readData(aosContext, fieldPath, timeBasePath, &compressedData, retSize);
		  if (status < 0) {
			  LOG_ERROR << "error for chunk =" << chunk << ", returning...";
			  return status;
		  }
		  LOG_DEBUG << "readData for chunk:" << chunk << ", OK";

		  LOG_DEBUG << "chunk=" << chunk << " has size=" << retSize[1];
		  
		  //storing the chunk in memory
		  status = putChunkInRAM(chunk, compressedData, retSize);
		  if (status < 0) {
			  LOG_ERROR << "error for chunk = " << chunk <<  " ,returning...";
			  return status;
		  }
		  
		  LOG_DEBUG << "chunk=" << chunk << " OK";
		  
		  //restore the previous index
		  actx->nextIndex(-step); 
	  }
	  return 0;
  
  }
  
  int Camera_ir_plugin::read_data(int ctx, const char* fieldPath, const char* timeBasePath, 
  void **data, int datatype, int dim, int *size) {
  
	  LOG_DEBUG << "read_data called for field : " << fieldPath;
	  
	  if (idsTimeMode == -1)
		readIdsTimeMode();
	  LOG_DEBUG << "idsTimeMode=" <<  idsTimeMode; 
	  
	  if (idsTimeMode == IDS_TIME_MODE_INDEPENDENT) {
		return 0; //No data
	  }
	  
	  if (std::string(fieldPath) == "image_raw") {
		  LOG_DEBUG << "shot:" << shot;
		  LOG_DEBUG << "fieldPath:" << fieldPath;
		  LOG_DEBUG << "timeBasePath:" << timeBasePath;
		  LOG_DEBUG << "idsTimeMode:" << idsTimeMode;
		  LOG_DEBUG << "occurrence:" << occurrence;
		  
		  LOG_DEBUG << "fileSize=" << fileSize;
		  int status = getImage(ctx, fieldPath, timeBasePath, data, size);
		  if (status != 0) //TODO, see why the latest image can not be loaded
			return 0; 
		  return 1; //data available
	  }
	  else if(std::string(fieldPath) == "time") {
		  if (this->cam <= 0) //camera not opened
			open_camera_handler();
			
		  LOG_DEBUG << "camera handler=" << this->cam;
		  
		  int image_count = get_image_count(cam);
		  LOG_DEBUG << "setting time vector of length=" << image_count;
		  std::vector<int64_t> image_times; //the time of each image in nanoseconds (in WEST time base)
		  int64_t time;
		  for (int i = 0; i < image_count; i++) {
			  int s = get_image_time(cam, i, &time);
			  /*if (s==0 && i < 10) {
				LOG_DEBUG << "time=" << time*1.E-9;
			  }*/
			  image_times.push_back((double)time*1.E-9);
		  }
		  
		  *data = (double*) malloc (sizeof(double)*image_count);
		  memcpy(*data, image_times.data(), image_count*sizeof(double));
		  size[0] = image_times.size();
		  LOG_DEBUG << "length of time vector = " << image_times.size();
		  return 1;
	  }
	  
	  return 0;
  
  }
  
  void Camera_ir_plugin::write_data(int ctx, const char* fieldPath, const char* timeBasePath, void *data, int datatype, int dim, int *size) {}
  
  int Camera_ir_plugin::readData(int ctx, std::string fieldPath, std::string timeBasePath, void** ptrData, int *retSize)
  {
	  al_status_t al_status = ual_read_data(ctx, fieldPath.c_str(), timeBasePath.c_str(), ptrData, INTEGER_DATA, 2, &retSize[0]);
	  return al_status.code;
  }

  void Camera_ir_plugin::setParameter(const char* parameter_name, int datatype, int dim, int *size, void *data) {
  }
  
  /*al_status_t Camera_ir_plugin::close_pulse(int pulseCtx, int mode) {
  al_status_t al_status;
  al_status.code = 0;
  return al_status;
  }*/
  
  void Camera_ir_plugin::initialize() {
  
	  al_status_t al_status;
	  std::string fieldPath = "frame";
	  std::string timeBasePath = "";
	  
	  //Open context
	  LOG_DEBUG << "initialize opening context...";
	  al_status = ual_begin_global_action(pulseCtx, dataobjectname.c_str(), READ_OP, &globalContext);
	  if(al_status.code < 0 || globalContext < 0) 
		  throw UALPluginException("Camera_ir_plugin: call to ual_begin_global_action() has failed.", LOG); 
	  
	  LOG_DEBUG << "fetching value...";
	  al_status = ual_begin_arraystruct_action(globalContext, fieldPath.c_str(), timeBasePath.c_str(), &chunksCount, &aosContext);
	  LOG_DEBUG << "globalContext=" << globalContext;	
	  LOG_DEBUG << "aosContext=" << aosContext;
	  LOG_DEBUG << "after fetching value=" << chunksCount;		  		  
	  if (al_status.code < 0)
	  {   
		  LOG_DEBUG << "initialize has failed.."; 
		  ual_end_action(globalContext);
		  throw UALPluginException("Camera_ir_plugin: call to initialize() has failed.", LOG); 
	  }
	  
	  fileSize = 0;
	  
	  check(0);  //get the first chunk
	  if (chunksCount > 1) {
		  check(chunksCount - 1); //get the last chunk;
		  LOG_DEBUG << "this->chunk_sizes[0]=" << this->chunk_sizes[0];
		  LOG_DEBUG << "this->chunk_sizes[chunksCount - 1]=" << this->chunk_sizes[chunksCount - 1];
		  fileSize = (chunksCount - 1)*this->chunk_sizes[0] + this->chunk_sizes[chunksCount - 1];
	  }
	  else {
		  fileSize = this->chunk_sizes[0];
	  }
	  LOG_DEBUG << "fileSize=" << fileSize;
	  LOG_DEBUG << "chunksCount=" << chunksCount;
	  LOG_DEBUG << "chunkSize=" << chunk_sizes[0];
  }
  
  /*This function uncompress the image data stored in the buffer object*/ 
  int Camera_ir_plugin::getImage(int ctx, const char *field, const char *timebase, void **data, int *size) {
  
	  LOG_DEBUG << "called...";
	  //this->ctx = ctx;
	  
	  if (this->cam <= 0) //camera not opened
		open_camera_handler();
	  
	  if (this->cam <= 0) { //failure to open the camera
		  LOG_ERROR << "failure to open camera";
		  return -1;
	  }
	  
	  LLenv lle = Lowlevel::getLLenv(ctx);
	  ArraystructContext *actx = static_cast<ArraystructContext *>(lle.context);
	  bool slice_mode =  actx->getOperationContext()->getRangemode() == SLICE_OP;
	  int interp_mode = actx->getOperationContext()->getInterpmode();
	  double time_interp = actx->getOperationContext()->getTime();
	  LOG_DEBUG << "time_interp=" << time_interp;
	  int chunk = (int) actx->getIndex();
	  
	  if (slice_mode) {
		  //make time interpolation, gives the value of chunk
		  double *time_vector = NULL;
		  int length = 0;
		  getTimeVector((void**) &time_vector, &length);
		  
		  int closest_sample = 0;
		  
		  if (length == 0) {
			  LOG_ERROR << "error, time vector has 0 length";
			  //return -1; //TODO, remove comment, only for testing purpose
			  throw UALPluginException("Camera_ir_plugin: time vector has 0 length.", LOG); 
		  }
		  else {
			  double diff = time_interp - time_vector[0];
			  for (int i = 1; i < length; i++) { //searching the closest previous sample
				  if (abs(time_interp - time_vector[i]) < abs(diff)) {
					  diff = time_interp - time_vector[i];
					  closest_sample = i;
				  }
				  else
					break;
			  }
			  
			  LOG_DEBUG << "closest_sample=" << closest_sample;
			  LOG_DEBUG << "-->closest time=" << time_vector[closest_sample];
			  
			  if (interp_mode != CLOSEST_INTERP)
				LOG_WARNING << "Camera_IR plugin performs only interpolation of closest sample.";
				
		  }
		  chunk = closest_sample;
		  LOG_DEBUG << "getting slice for chunk=" << chunk;
	  }
	  
	  LOG_DEBUG << "chunk=" << chunk;
	  
	  int status = getImage(chunk, data, size); 
	  return status;
  }
  
  int Camera_ir_plugin::getImage(int pos, void **data, int *size) {
	  int w, h;
	  get_image_size(this->cam, &w, &h);
	  std::vector<unsigned short> pixels;
	  pixels.resize(w*h);
	  int calibration = 0; //TODO
	  LOG_DEBUG << "calling load_image at pos=" << pos << " with camera handler=" << this->cam;
	  int status = load_image(this->cam, pos, calibration, pixels.data());  //Getting the image
	  if (status < 0) {
		  LOG_ERROR << "error loading image for pos:" << pos;
		  return status;
	  }
	  *data = (int*) malloc(sizeof(int)*w*h);
	  
	  //Lets's transpose the buffer
	  int index = 0;
	  int* v = (int*) *data;
	  for (int row = 0; row < h; row++) {
		  for (int col = 0; col < w; col++) {
			  v[h*col + row] = (int) pixels[index];
			  index++;
		  }
	  }
	  
	  size[0] = h; //WARNING: removing the last 3 lines from the image
	  size[1] = w;
	  LOG_DEBUG << "image size, h=" << h << ", w=" << w;
	  return 0;
  }
  
  void Camera_ir_plugin::getTimeVector(void **time_vector, int *length)
  {
	  std::string fieldPath = "time";
	  std::string timeBasePath = "";
	  
	  int size[MAXDIM];
	  
	  LOG_DEBUG << "fetching time values...";
	  al_status_t al_status = ual_read_data(globalContext, fieldPath.c_str(), timeBasePath.c_str(), time_vector, DOUBLE_DATA, 1, size);
	   		  
	  if (al_status.code < 0)
		  throw UALPluginException("Camera_ir_plugin: getTimeVector() has failed...", LOG); 
	  
	  *length = size[0];
	  LOG_DEBUG << "time vector length=" << *length;
  }
  
  void fileInfos_from_cam(void* opaque, int64_t * fileSize_, int64_t * chunkCount_, int64_t * chunkSize_)
  {
	  Camera_ir_plugin *plugin = (Camera_ir_plugin*) opaque;
	  LOG_DEBUG << "fileInfos_from_cam";
	  *chunkCount_ = (int64_t) plugin->chunksCount;
	  *chunkSize_ = 0;;
	  *fileSize_ = (int64_t) plugin->fileSize;
	  
	  if (*chunkCount_ > 0) {
		  *chunkSize_ = (int64_t) plugin->chunk_sizes[0]; //size of a chunk in bytes
		  LOG_DEBUG << "fileInfos_from_cam, getting chunkCount =" << (int) *chunkCount_;
		  LOG_DEBUG << "fileInfos_from_cam, getting chunkSize =" << (int) *chunkSize_; 
		  LOG_DEBUG << "fileInfos_from_cam, getting fileSize =" << (int) *fileSize_;
	  }
  }
  
  int64_t readChunk_from_cam(void* opaque, int64_t chunk, uint8_t * buf)
  {
	  LOG_DEBUG << "reading chunk " << (int) chunk;
	  Camera_ir_plugin *plugin = (Camera_ir_plugin*) opaque;
	  
	  int status = plugin->check(chunk); //check if the chunk is in RAM
	  if (status < 0) {
		LOG_ERROR << "Error calling check for chunk:" << (int) chunk;
		return status;
	  }
	  LOG_DEBUG << "reading buffer for chunk:" << (int) chunk;
	  
	  int chunk_size = plugin->chunk_sizes[chunk];
	  LOG_DEBUG << "chunk_size:" << chunk_size;
	  LOG_DEBUG << "camera->chunk_buffers size:" << (int) plugin->chunk_buffers.size();
	  
	  memcpy(buf, (uint8_t *) plugin->chunk_buffers[chunk], chunk_size);
	  LOG_DEBUG << "chunk_buffers.size():", (int) plugin->chunk_buffers.size();
	  LOG_DEBUG << "returning chunk:" << (int) chunk;
	  return chunk_size;
  }
  
  void destroyOpaqueCamHandle(void* opaque)
  {
	  /*if (opaque == NULL)
	  return;
	  Librir_camera_IR *camera = (Librir_camera_IR*) opaque;
	  camera->chunk_buffers.clear();*/
  }
  
  void * createCamReader(FileAccess access)
  {
	  if (!access.opaque)
		return NULL;
	  
	  CameraDataReader * reader = new CameraDataReader();
	  reader->access = access;
	  LOG_DEBUG << "calling infos";
	  access.infos(access.opaque, &reader->fileSize, &reader->chunkCount, &reader->chunkSize);
	  reader->filePos = 0;
	  reader->currentChunk = -1;
	  reader->buffer = new uint8_t[reader->chunkSize];
	  LOG_DEBUG << "reader->fileSize=" << (int) reader->fileSize;
	  LOG_DEBUG << "reader->chunkSize=" << (int) reader->chunkSize;
	  LOG_DEBUG << "reader->chunkCount=" << (int) reader->chunkCount;
	  return reader;
  }
  
  FileAccess createCameraDataAccess(Camera_ir_plugin *plugin)
  {
	  LOG_DEBUG << "calling createCameraDataAccess";
	  FileAccess res;
	  res.opaque = plugin;
	  LOG_DEBUG << "setting res.infos";
	  res.infos = &fileInfos_from_cam;
	  LOG_DEBUG << "setting res.read";
	  res.read = &readChunk_from_cam;
	  LOG_DEBUG << "setting res.destroy";
	  res.destroy = &destroyOpaqueCamHandle;
	  return res;
  }
  
  
  
  
  
