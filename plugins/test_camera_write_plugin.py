import imas
import matplotlib.pyplot as plt
from imas import _ual_lowlevel as ull

#Pulse file creation
ie=imas.ids(56927,0)
ie.create_env_backend('LF218007','test_camera','3',13)
ie.camera_ir.ids_properties.homogeneous_time=1
ie.camera_ir.time.resize(1)
ie.camera_ir.time[0]=0.

#Pulse file registering and binding
ull.hli_register_plugin("camera_ir_write");

for occurrence in range(20):
   path = "camera_ir/frame"
   path_time = "camera_ir/time"
   if occurrence != 0:
      path = "camera_ir/" + str(occurrence) + "/frame"
      path_time = "camera_ir/" + str(occurrence) + "/time"
   ull.hli_bind_plugin(path, "camera_ir_write")
   ull.hli_bind_plugin(path_time, "camera_ir_write")

#Calling plugin using put()
ie.camera_ir.put(1)

#Removing plugin from memory
ull.hli_unregister_plugin("camera_ir_write");

