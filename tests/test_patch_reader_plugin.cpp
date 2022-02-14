#include <stdlib.h>
#include "UALClasses.h"


using namespace IdsNs;

void execute();


void execute() {
        IDS imas = IDS(10501, 515, -1, -1);
        hli_register_plugin("reader");
        hli_attach_plugin("camera_ir/frame/image_raw", "reader");
        imas.setBackend(HDF5_BACKEND);
        imas.openEnv("fleuryl", "test", "3");
        IDS::camera_ir ids = imas._camera_ir;
        ids.get(0);

        for (int i = 0; i < 2; i++) {
          printf("displaying frame %d:\n", i);
          //std::cout << ids.frame(i).image_raw.transpose(secondDim,firstDim) << std::endl;
          std::cout << ids.frame(i).image_raw << std::endl;
        }
        hli_detach_plugin("camera_ir/frame/image_raw", "reader");
        hli_register_plugin("patch_reader");
        //hli_attach_plugin("camera_ir/ids_properties/version_put/access_layer", "patch_reader");
        hli_attach_plugin("camera_ir/frame/image_raw", "patch_reader");
        ids.get(0);
        //std::cout << "access_layer=" << ids.ids_properties.version_put.access_layer << std::endl;
        //printf("homog. time = %d\n", ids.ids_properties.homogeneous_time);
        for (int i = 0; i < 2; i++) {
          printf("displaying patched frame %d:\n", i);
          //std::cout << ids.frame(i).image_raw.transpose(secondDim,firstDim) << std::endl;
          std::cout << ids.frame(i).image_raw << std::endl;
        }
        imas.close();
}


int main(int argc, char** argv){
    execute();
}