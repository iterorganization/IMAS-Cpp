import imas
import matplotlib.pyplot as plt
from imas import _ual_lowlevel as ull
ie=imas.ids(56927,0)
ie.create_env_backend('LF218007','test_camera','3',13)
ie.camera_ir.ids_properties.homogeneous_time=1
ie.camera_ir.time.resize(1)
ie.camera_ir.time[0]=0.
ull.hli_register_plugin("camera_ir_write");
#ull.hli_register_plugin("reader");
ull.hli_attach_plugin("camera_ir/frame", "camera_ir_write")
ull.hli_attach_plugin("camera_ir/time", "camera_ir_write")
#ull.hli_attach_plugin("camera_ir/time", "reader")
ie.camera_ir.put()

