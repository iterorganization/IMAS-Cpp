import imas
import matplotlib.pyplot as plt
from imas import _ual_lowlevel as ull
ie=imas.ids(56927,0)
ie.open_env_backend('LF218007','test_camera','3',13)
ull.hli_register_plugin("debug");
ull.hli_bind_plugin("camera_ir/ids_properties/version_put/access_layer", "debug")
#ull.hli_bind_plugin("camera_ir/ids_properties/homogeneous_time", "debug")
#ull.hli_bind_plugin("camera_ir/frame/image_raw", "debug")
#ull.hli_bind_plugin("camera_ir/frame", "debug")
#ull.hli_bind_plugin("camera_ir/*", "debug")
ie.camera_ir.get()
print(len(ie.camera_ir.frame))
ull.hli_unregister_plugin("debug");

