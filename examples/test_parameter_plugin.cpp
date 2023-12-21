#include <stdlib.h>
#include "ALClasses.h"

using namespace IdsNs;

void execute(char** argv);
void exitIfError(al_status_t &status);

void execute(char** argv) {

	al_status_t status = al_register_plugin("parameter");
        exitIfError(status);
	status = al_setvalue_int_scalar_parameter_plugin("op", 3, "parameter");
        exitIfError(status);
	status = al_unregister_plugin("parameter");
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

