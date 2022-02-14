#include <stdlib.h>
#include "UALClasses.h"


using namespace IdsNs;

void execute();


void execute() {
        IDS imas = IDS(10501, 515, -1, -1);
        hli_register_plugin("reader");
        hli_attach_plugin("camera_ir/ids_properties/version_put/access_layer", "reader");
        imas.setBackend(HDF5_BACKEND);
        imas.openEnv("fleuryl", "test", "3");
        IDS::camera_ir ids = imas._camera_ir;
        ids.get(0);
        std::cout << "access_layer=" << ids.ids_properties.version_put.access_layer << std::endl;
        imas.close();
}


int main(int argc, char** argv){
    execute();
}

