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
ull.hli_bind_plugin("camera_ir/frame", "camera_ir_write")
ull.hli_bind_plugin("camera_ir/time", "camera_ir_write")

#Calling plugin using put()
ie.camera_ir.put()

#Removing plugin from memory
ull.hli_unregister_plugin("camera_ir_write");

