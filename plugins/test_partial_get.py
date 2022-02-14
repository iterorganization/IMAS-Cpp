import imas
import matplotlib.pyplot as plt
from imas import _ual_lowlevel as ull

ie=imas.ids(56927,0)
ie.open_env_backend('LF218007','test_camera','3',13)

ull.hli_register_plugin("partial_get");
#ull.hli_bind_plugin("camera_ir/frame", "partial_get")

ie.camera_ir.get()

print("Frame AOS size=",len(ie.camera_ir.frame))
ull.hli_unregister_plugin("partial_get");

