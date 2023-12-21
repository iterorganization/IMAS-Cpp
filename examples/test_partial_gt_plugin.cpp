#include <stdlib.h>
#include "ALClasses.h"

using namespace IdsNs;

void execute(char** argv);
void exitIfError(al_status_t &status);

void execute(char** argv) {

    int pulse=54;
    char* userName = NULL;

    userName = getenv("USER");
    if(userName == NULL) 
    {
        printf( "PANIC: $USER not found! Exiting...");
        exit(1);
    }

    /*   Get Full  */
    IdsNs::IDS data_entry(pulse,1,-1,-1);
    data_entry.openEnv(userName, "test", "3"); 

    al_status_t status = al_register_plugin("partial_get");
    exitIfError(status);
    status = al_bind_plugin("magnetics:0/flux_loop", "partial_get");
    IDS::magnetics ids = data_entry._magnetics;
    ids.get(0);
    printf("magnetics AOS size=%d\n",ids.flux_loop.size());
    data_entry.close();

    status = al_unregister_plugin("partial_get");
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

