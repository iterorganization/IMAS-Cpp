#include <stdlib.h>
#include "UALClasses.h"


using namespace IdsNs;

void execute();


void execute() {
	printf("Reading shot...\n");
        IDS imas = IDS(56927, 0, -1, -1);
	//const char* plugin_name= "camera_ir";
        printf("Attaching plugin %s\n", "camera_ir");
        hli_register_plugin("camera_ir");
        hli_attach_plugin("camera_ir/frame/image_raw", "camera_ir");
        imas.setBackend(HDF5_BACKEND);
        imas.openEnv("LF218007", "test", "3");
        IDS::camera_ir ids = imas._camera_ir;
        ids.get(0);
        imas.close();
}


int main(int argc, char** argv){
    execute();
}

