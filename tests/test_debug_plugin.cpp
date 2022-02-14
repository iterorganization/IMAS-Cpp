#include <stdlib.h>
#include "UALClasses.h"


using namespace IdsNs;

void put();


void put() {
        IDS imas = IDS(10501, 515, -1, -1);
        //LLplugin::register_plugin("camera_ir");
        hli_register_plugin("debug");
        LLplugin::attachPlugin("camera_ir/frame/image_raw", "debug");
        //LLplugin::attachPlugin("camera_ir/ids_properties/homogeneous_time", "camera_ir");
        hli_attach_plugin("camera_ir/ids_properties/version_put/access_layer", "debug");
        //hli_attach_plugin("camera_ir/frame/image_raw", "camera_ir");
        imas.setBackend(HDF5_BACKEND);
        imas.openEnv("fleuryl", "test", "3");
        IDS::camera_ir ids = imas._camera_ir;
        ids.get(0);
        /*printf("homog. time = %d\n", ids.ids_properties.homogeneous_time);
        for (int i = 0; i < 2; i++) {
          printf("displaying frame %d:\n", i);
          std::cout << ids.frame(i).image_raw.transpose(secondDim,firstDim) << std::endl;
        }*/
        /*std::cout << "frame size=" << ids.frame.size() << std::endl;
        if (ids.time.size() > 0) {
          for (int i = 0; i < 10; i++) {
            std::cout << "time[" << i << "]=" << ids.time(i) << std::endl;
          }
        }*/
        imas.close();
}


int main(int argc, char** argv){
    put();
}

