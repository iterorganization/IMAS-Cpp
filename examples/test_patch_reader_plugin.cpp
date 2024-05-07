#include <stdlib.h>
#include "ALClasses.h"
  
using namespace IdsNs;

void execute(char** argv);
void exitIfError(al_status_t &status);

void execute(char** argv) {

  int pulse=60;
  char* userName = NULL;
  char uri[]="imas:mdsplus?path=./test_db_test_patch_reader_plugin";

  userName = getenv("USER");
  if(userName == NULL) 
  {
      printf( "PANIC: $USER not found! Exiting...");
      exit(1);
  }
  
  IdsNs::IDS data_entry;
  data_entry.open(uri, FORCE_CREATE_PULSE);

  IDS::camera_ir ids = data_entry._camera_ir;
  
  ids.ids_properties.homogeneous_time = 1;
  ids.time.resize(2);
  ids.time(0) = 1.0;
  ids.time(1) = 1.1;
  ids.frame.resize(2);
  for (int k = 0; k < 2; k++) {
    ids.frame(k).surface_temperature.resize(5,15); 
    for (int j = 0; j < 15; j++)
      for (int i = 0; i< 5; i++)
         ids.frame(k).surface_temperature(i,j) = (double) (i + j + k);
	 }
         
  ids.put();

  //displays first 2 frames before multiplying pixels by op parameter
  for (int i = 0; i < 2; i++) {
     printf("displaying frame %d:\n", i);
     std::cout << ids.frame(i).surface_temperature << std::endl;
  }
      
  al_status_t status = al_register_plugin("patch_reader");
  status = al_bind_plugin("camera_ir:0/frame/surface_temperature", "patch_reader");
  exitIfError(status);

  //setting the value of the ‘op’ plugin parameter to 2
  status = al_setvalue_int_scalar_parameter_plugin("op", 2, "patch_reader");
  exitIfError(status);

  ids.get();

  //displays first 2 frames after multiplying pixels by op parameter
  for (int i = 0; i < 2; i++) {
     printf("displaying patched frame %d:\n", i);
     std::cout << ids.frame(i).surface_temperature << std::endl;
  }
  data_entry.close();
}

void exitIfError(al_status_t &status) {
  if (status.code != 0) {
       printf("%s\n", status.message);
       exit(-1);
  }
}

int main(int argc, char** argv){
    execute(argv);
}

