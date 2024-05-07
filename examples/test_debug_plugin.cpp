#include <stdlib.h>
#include "ALClasses.h"

using namespace IdsNs;

void execute(char** argv);
void exitIfError(al_status_t &status);

void execute(char** argv) {

    int pulse=54;
    char* userName = NULL;
    char uri[]="imas:mdsplus?path=./test_db_test_debug_plugin";

    userName = getenv("USER");
    if(userName == NULL) 
    {
        printf( "PANIC: $USER not found! Exiting...");
        exit(1);
    }

    IdsNs::IDS data_entry;
    data_entry.open(uri, OPEN_PULSE);

    al_status_t status = al_register_plugin("debug");
    exitIfError(status);
    printf("Using the magnetics IDS for demo purpose\n");
    al_bind_plugin("magnetics:0/ids_properties/version_put/access_layer", "debug");
    al_bind_plugin("magnetics:0/flux_loop", "debug");	
    
    IDS::magnetics ids = data_entry._magnetics;
    ids.get(0);

    data_entry.close();
    status = al_unregister_plugin("debug");
    exitIfError(status);
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

