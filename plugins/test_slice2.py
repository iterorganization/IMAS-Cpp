import imas
import matplotlib.pyplot as plt
from imas import _ual_lowlevel as ull
ie=imas.ids(56927,0)
ie.open_env_backend('LF218007','test_camera','3',13)
ull.hli_register_plugin("camera_ir");
ull.hli_bind_plugin("camera_ir/frame/surface_temperature", "camera_ir")
ull.hli_bind_plugin("camera_ir/frame", "camera_ir")
#ie.camera_ir.get()
ie.camera_ir.getSlice(19.,1, 0)
#print(ie.camera_ir.time)
print(len(ie.camera_ir.time))
print(ie.camera_ir.frame[0].time)
print(ie.camera_ir.frame[0].surface_temperature[0:510,0:630])
im = plt.imshow(ie.camera_ir.frame[0].surface_temperature[0:510,0:630])
plt.show()

