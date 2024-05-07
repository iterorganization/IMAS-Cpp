#include <stdlib.h>
#include "ALClasses.h"


using namespace IdsNs;

void execute(char** argv);
void exitIfError(al_status_t &status);


/**
This test creates a new IDS object using an input URI (Uniform Resource Identifier). It then patches the field 'ids_properties/creation_date' of a magnetics IDS for demonstration purposes. To do this, it first registers a plugin named "creation_date" using the function "al_register_plugin", and then binds it to the magnetics IDS using the function "al_bind_plugin". If the plugin binding fails, the program prints an error message and exits.
Next, the function sets the IDS properties, including the time base, and then writes the IDS data to the backend specified in the URI. It then closes the IDS and unregisters the "creation_date" plugin.
*/

void execute(char** argv) {

    int pulse=54;
    char* userName = NULL;
    char uri[]="imas:mdsplus?path=./test_db_test_creation_date_plugin";

    userName = getenv("USER");
    if(userName == NULL) 
    {
        printf( "PANIC: $USER not found! Exiting...");
        exit(1);
    }
    IdsNs::IDS data_entry;
    data_entry.open(uri, OPEN_PULSE);
	
    std::cout << "Patching the field 'ids_properties/creation_date' of a magnetics IDS for demo purpose." << std::endl;

    al_status_t status = al_register_plugin("creation_date");
    exitIfError(status);
    status = al_bind_plugin("magnetics:0/ids_properties/creation_date", "creation_date");
    exitIfError(status);
    IDS::magnetics ids = data_entry._magnetics;
    ids.ids_properties.homogeneous_time=1;
    ids.time.resize(1);
    ids.time[0] = 0;
    ids.put();
    data_entry.close();
    status = al_unregister_plugin("creation_date");
    exitIfError(status);
    std::cout << "Reading IDS..." << std::endl;

    IdsNs::IDS data_entry2;
    data_entry2.open(uri, OPEN_PULSE);
    
    IDS::magnetics ids2 = data_entry2._magnetics;
    ids2.get();
    //printf("ids.ids_properties.plugins.node.size()=%d\n", ids2.ids_properties.plugins.node.size());
    bool readBackPlugins = false;
    for (int i = 0; i < (int) ids2.ids_properties.plugins.node.size(); i++) { 
      if  (ids2.ids_properties.plugins.node(i).readback.size() != 0) {
          readBackPlugins = true;
      }
      for (int j = 0; j < (int) ids2.ids_properties.plugins.node(i).readback.size(); j++) {
          std::cout << "node at path=" << ids2.ids_properties.plugins.node(i).path << std::endl;
          std::cout << "readback plugin --> name=" << ids2.ids_properties.plugins.node(i).readback(j).name << std::endl;
          std::cout << "--> version=" << ids2.ids_properties.plugins.node(i).readback(j).version << std::endl;
          std::cout << "--> commit=" << ids2.ids_properties.plugins.node(i).readback(j).commit << std::endl;
       }
    }
    if (!readBackPlugins)
       std::cout << "No readback plugins have been called during get()." << std::endl;
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

