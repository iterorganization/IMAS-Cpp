#include <stdlib.h>
#include "UALClasses.h"


using namespace IdsNs;

void execute();


void execute() {
	//printf("Reading shot...\n");
        IDS imas = IDS(56928, 0, -1, -1);
        hli_register_plugin("imas3121");
        hli_bind_plugin("camera_ir/ids_properties/creation_date", "imas3121");
        imas.setBackend(HDF5_BACKEND);
        imas.createEnv("LF218007", "test_camera", "3");
        IDS::camera_ir ids = imas._camera_ir;
        ids.ids_properties.homogeneous_time=1;
        ids.time.resize(1);
        ids.time[0] = 0;
        ids.put(0);
        //std::cout << "access_layer=" << ids.ids_properties.version_put.access_layer << std::endl;
        imas.close();
}


int main(int argc, char** argv){
    execute();
}

