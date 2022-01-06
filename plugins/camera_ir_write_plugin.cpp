  #include "camera_ir_write_plugin.h"
  
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>
  #include "video_io.h"
  #include "west.h" 
  #include "simple_logger.h"
  
  Camera_ir_write_plugin::Camera_ir_write_plugin()
  :pulseCtx(-1), ctx(-1), globalContext(-1), aosContext(-1), shot(-1), 
  dataobjectname(), idsTimeMode(-1), occurrence(-1), mode(-1), time(-1), interp(-1)
  {
  }
  
  Camera_ir_write_plugin::~Camera_ir_write_plugin()
  {
  }
  
  void Camera_ir_write_plugin::readIdsTimeMode()
  {
      std::string fieldPath = "ids_properties/homogeneous_time";
      std::string timeBasePath = "";
      int opCtx = -1;
      
      //Opening a global context
      LOG_DEBUG << "readIdsTimeMode opening context...";
      al_status_t al_status = ual_begin_global_action(pulseCtx, dataobjectname.c_str(), READ_OP, &opCtx);
      if(al_status.code < 0 || opCtx < 0)
          throw UALPluginException("Camera_ir_write_plugin: readIdsTimeMode opening context failed...", LOG); 
      
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
  
  void Camera_ir_write_plugin::begin_global_action(int pulseCtx, const char* dataobjectname, int mode, int opCtx) {
      LOG_DEBUG << "Camera_ir_write_plugin plugin called...";
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
          this->occurrence = std::stoi(occStr);
      }
      else {
          this->occurrence = 0;
      }
      LOG_DEBUG << "occurrence=" << occurrence;
  }
  
  void Camera_ir_write_plugin::begin_slice_action(int pulseCtx, const char* dataobjectname, int mode, double time, int interp, int opCtx) {
      LOG_DEBUG << "called";
      this->time = time;
      this->interp = interp;
      return begin_global_action(pulseCtx, dataobjectname, mode, opCtx);
  }
  
  /*Implementation of begin_arraystruct_action*/
  void Camera_ir_write_plugin::begin_arraystruct_action(int ctx, int aosctx, const char* fieldPath, const char* timeBasePath, int arraySize) 
  {
      LOG_DEBUG << "calling begin_arraystruct_action for: " << fieldPath;
      if (std::string(fieldPath) != "frame") {
        return;
      }
      
      this->ctx = aosctx;
      
      LOG_DEBUG << "fieldPath:" << fieldPath;
      LOG_DEBUG << "arraySize:" << arraySize;
      LOG_DEBUG << "ctx:" << this->ctx;
      write_aos_content(ctx, aosctx, fieldPath, timeBasePath);
  }
  
  void Camera_ir_write_plugin::write_data(int ctx, const char* fieldPath, const char* timeBasePath, void *data, int datatype, int dim, int *size) {
      LOG_DEBUG << "calling write_data for: " << fieldPath;
      if (std::string(fieldPath) != "time") {
        return;
      }
      write_time_vector(ctx, fieldPath, timeBasePath);			  
  }
  
  void Camera_ir_write_plugin::write_aos_content(int ctx, int aosctx, const char* fieldPath, const char* timeBasePath) {
      
      al_status_t al_status;
      
      if (idsTimeMode == -1) 
          readIdsTimeMode();
      
      LOG_DEBUG << "idsTimeMode=" << idsTimeMode; 
      
      if (idsTimeMode == IDS_TIME_MODE_INDEPENDENT) {
          LOG_DEBUG << "idsTimeMode is IDS_TIME_MODE_INDEPENDENT, returning"; 
          return;
      }
  
      LOG_DEBUG << "plugin called";
      LOG_DEBUG << "shot: " << shot;
      LOG_DEBUG << "fieldPath: " << fieldPath;
      LOG_DEBUG << "timeBasePath: " << timeBasePath;
      LOG_DEBUG << "occurrence: " << occurrence;
      
      if (camera_data.image_count == 0)  //compressed chunks not yet fetched from the server
        get_camera_data(shot, occurrence); 
      
      
      if (idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS) 
        timeBasePath = "/time";
      else
        timeBasePath = "frame/time";
      
      bool pluginIsContextOwner = false;
      
      int arraySize = camera_data.image_count;
      LOG_DEBUG << "arraySize=" << arraySize;
      int aosCtx = -1;
      
      if(arraySize > 0)
      {	
          LOG_DEBUG << "calling ual_begin_arraystruct_action from plugin";
          ual_end_action(aosctx); //NOTE: the previous AOS context needs to be closed before to open a new one
          al_status = ual_begin_arraystruct_action(ctx, fieldPath, timeBasePath, &arraySize, &aosCtx);
          if (al_status.code < 0 || aosCtx < 0)  
          {	
              LOG_DEBUG << "aosCtx=" << aosCtx;
              LOG_DEBUG << "al_status.code=" << al_status.code;
              LOG_DEBUG << "an error has occurred in write_aos_content()";
              throw UALPluginException("error calling ual_begin_arraystruct_action", LOG);
          }
      }
      LOG_DEBUG << "aosCtx=" << aosCtx;
      int increment = 0;
      for (int i = 0; i < arraySize; i++) {
          int current_chunk_size = camera_data.chunk_size;
          if (i == arraySize - 1) {
            current_chunk_size = camera_data.remaining_size;
          }
          int shapes[2] = { 1, current_chunk_size };
          al_status = ual_write_data(aosCtx, "image_raw", "", chunks_buffer+increment, INTEGER_DATA, 2, shapes);
          if (al_status.code < 0)  
          {	
              LOG_DEBUG << "an error has occurred in write_aos_content(), calling ual_write_data()";
              ual_end_action(aosCtx); //plugin is owner of the AOS context
              throw UALPluginException("Camera_ir_plugin: error calling ual_write_data", LOG);
          }
          int64_t time_in_ns;
          int s = get_image_time(camera_data.camera_handler, i, &time_in_ns);
          if (s == 0) {
              double time = (double) time_in_ns*1.E-9;
              al_status = ual_write_data(aosCtx, "time", "", &time, DOUBLE_DATA, 0, NULL);
              if (al_status.code < 0)  
              {	
                  LOG_DEBUG << "an error has occurred writing frame/time scalar";
                  ual_end_action(aosCtx);
                  throw UALPluginException("Camera_ir_plugin: error calling ual_iterate_over_arraystruct", LOG);
              }
          }
          increment += current_chunk_size;
          al_status = ual_iterate_over_arraystruct(aosCtx, 1);
          if (al_status.code < 0)  
          {	
              LOG_DEBUG << "an error has occurred in write_aos_content(), ual_iterate_over_arraystruct";
              ual_end_action(aosCtx);
              throw UALPluginException("Camera_ir_plugin: error calling ual_iterate_over_arraystruct", LOG);
          }
      }
      ual_end_action(aosCtx);
      free(chunks_buffer);
      if (camera_data.camera_handler != -1)
        close_camera(camera_data.camera_handler);
      LOG_DEBUG << "returning from write_aos_content";
  }
  
  void Camera_ir_write_plugin::write_time_vector(int ctx, const char* fieldPath, const char* timeBasePath) {

      if (idsTimeMode == -1)
          readIdsTimeMode();
      
      LOG_DEBUG << "idsTimeMode=" << idsTimeMode; 
      
      if (idsTimeMode == IDS_TIME_MODE_INDEPENDENT) {
          LOG_DEBUG << "idsTimeMode is IDS_TIME_MODE_INDEPENDENT, returning"; 
          return;
      }
      
      LOG_DEBUG << "plugin called";
      LOG_DEBUG << "shot: " << shot;
      LOG_DEBUG << "fieldPath: " << fieldPath;
      LOG_DEBUG << "timeBasePath: " << timeBasePath;
      LOG_DEBUG << "occurrence: " << occurrence;
      
      if (camera_data.image_count == 0) { //compressed chunks not yet fetched from the server
        get_camera_data(shot, occurrence); 
      }
      
      if (idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS) 
        timeBasePath = "/time";
      else
        timeBasePath = "frame/time";
      
      int times_shapes[1] = {(int) camera_data.times.size()};
      al_status_t al_status = ual_write_data(ctx, "time", "", camera_data.times.data(), DOUBLE_DATA, 1, times_shapes);
      if (al_status.code < 0)  
        throw UALPluginException("Camera_ir_plugin: an error has occurred while writing the time vector", LOG);
      
      LOG_DEBUG << "returning from write_time_vector";
  }
  
  void Camera_ir_write_plugin::get_camera_data(int shot, int camera_number) {
      int cameras_count = get_camera_count(shot);
      LOG_DEBUG << "shot=" << shot;
      LOG_DEBUG << "cameras_count=" << cameras_count;
      std::vector<std::string> cameras;
      
      for (int i = 0; i < cameras_count; ++i) {
          if (camera_number != i)
            continue;
          char id[200];
          char name[200];
          int exists;
          LOG_DEBUG << "called";
          int cr = get_camera_infos(shot, i, id, name, &exists);
          if (cr == 0) {
              cameras.push_back(id);
              LOG_DEBUG << "calling open_camera for id=" << id;
              camera_data.camera_handler = open_camera(shot, id);
              LOG_DEBUG << "end of calling open_camera for id=" << id;
          }  
          else
            throw UALPluginException("Camera_ir_plugin: an error has occurred in get_camera_infos()", LOG);
      }
      
      std::vector<std::string> acquisition_units;
      std::vector<std::string> video_names;;
      LOG_DEBUG << "looping on cameras..";
      //for (int i = 0; i < (int) cameras.size(); i++) {
      LOG_DEBUG << "getting buffer for camera: " << camera_number;
      char s[256];
      strcpy(s, cameras[camera_number].c_str());
      char* token = strtok(s,"/");
      token = strtok(NULL, "/");
      char acquisition_unit[10];
      strcpy(acquisition_unit, token);
      acquisition_units.push_back(std::string(acquisition_unit));
      token = strtok(NULL, "/");
      char channel_name[10];
      strcpy(channel_name, token);
      std::string concat_au_cn = std::string(acquisition_unit) + std::string(channel_name);
      std::string latest_digits = concat_au_cn.substr(3,2);
      std::string video_name = std::string("FIRT_VIDEO") + latest_digits;
      std::cout << video_name << std::endl;
      video_names.push_back(video_name);
      long status = -1;
      unsigned int buffer_size;
      status = ts_file_size(shot,video_name.c_str(), &buffer_size);
      LOG_DEBUG << "ts_file_size status = " << status;
      LOG_DEBUG << "buffer_size = " << buffer_size;
      uint8_t* buffer = (uint8_t*) malloc(sizeof(uint8_t)*buffer_size);
      status = ts_read_file_buffer(shot,video_name.c_str(),  (char*) buffer, buffer_size);
      LOG_DEBUG << "ts_read_file_buffer status = " << status;
      LOG_DEBUG << "setting buffer_size = " << status;
      camera_data.buffer_size = buffer_size;
      camera_data.buffer = buffer;
      LOG_DEBUG << "setting image_count";
      camera_data.image_count = get_image_count(camera_data.camera_handler);
      LOG_DEBUG << "image_count = " << camera_data.image_count;
      
      std::vector<double> times;
      for (int j = 0; j < camera_data.image_count; j++) {
          int64_t time;
          get_image_time(camera_data.camera_handler, j, &time);
          times.push_back(time*1.E-9); //setting time in seconds
          //if (j < 5)
          //LOG_DEBUG << "time[" << j << "]=" << times[j];
          //if (j == camera_data.image_count -1)
          //LOG_DEBUG << "last time written[" << camera_data.image_count -1 << "]=" << times[camera_data.image_count -1];
      }
      
      LOG_DEBUG << "setting times";
      camera_data.times = times;
      camera_data.chunk_size =  (int) floor( (float)camera_data.buffer_size/(float)camera_data.image_count );
      camera_data.remaining_size = camera_data.buffer_size % camera_data.image_count;
      LOG_DEBUG << "buffer_size =" << camera_data.buffer_size;
      
      if (camera_data.remaining_size != 0)
        camera_data.image_count++;
        
      //close_camera(camera_data.camera_handler);
      LOG_DEBUG << "image_count=" << camera_data.image_count;
      LOG_DEBUG << "chunk_size=" << camera_data.chunk_size;
      LOG_DEBUG << "remaning_size=" << camera_data.remaining_size;
      
      
      chunks_buffer = new int[camera_data.buffer_size];
      //Converting unint_8 buffer to int buffer //TODO
      //int *buffer = new int[camera_data->buffer_size/4 + 1];
      for (int i = 0; i < camera_data.buffer_size; i++) {
        chunks_buffer[i] = (camera_data.buffer)[i];
      }
      //memcpy(buffer, camera_data->buffer, camera_data->buffer_size);
  }
  
  int Camera_ir_write_plugin::read_data(int ctx, const char* fieldPath, const char* timeBasePath, void **data, int datatype, int dim, int *size)
  {
    return 0;
  }
