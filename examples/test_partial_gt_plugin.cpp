#include <stdlib.h>
#include "ALClasses.h"

using namespace IdsNs;

void execute(char** argv);
void exitIfError(al_status_t &status);

void execute(char** argv) {

    char uri[]="imas:mdsplus?path=./test_db_test_magnetics";

    //char uri[] = "imas:hdf5?path=/home/ITER/fleuryl/public/imasdb/west/3/54914/4";
    IdsNs::IDS data_entry;
    data_entry.open(uri, OPEN_PULSE);

    al_status_t status = al_register_plugin("partial_get");
    exitIfError(status);

    std::string request1 = "flux_loop(1:5:2)";
    //std::string request2 = "bpol_probe(0:2)";
    //std::string request3 = "flux_loop/position(:)";

    int size1 = request1.length();
    status = al_setvalue_parameter_plugin("includes", CHAR_DATA, 1, &size1, (void *) request1.data(), "partial_get");
    exitIfError(status);
  
    status = al_setvalue_int_scalar_parameter_plugin("debug", 0, "partial_get");
    exitIfError(status);
    status = al_setvalue_int_scalar_parameter_plugin("debug_read_requests_only", 0, "partial_get");
    exitIfError(status);
    status = al_bind_plugin("magnetics:0/*", "partial_get");

    exitIfError(status);
    IDS::magnetics ids = data_entry._magnetics;
    ids.get(0);
    printf("magnetics AOS size=%d\n",ids.flux_loop.size());
    data_entry.close();

    /*for( int i = 0; i < 10; i++) {
      printf("ids.flux_loop(%d).flux.data.size=%d\n", i, ids.flux_loop(i).flux.data.size());
    }*/

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

