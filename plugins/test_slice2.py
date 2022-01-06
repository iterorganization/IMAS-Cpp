import imas
import matplotlib.pyplot as plt
from imas import _ual_lowlevel as ull
ie=imas.ids(56927,0)
ie.open_env_backend('LF218007','test_camera','3',13)
ull.hli_register_plugin("camera_ir");
ull.hli_attach_plugin("camera_ir/frame/image_raw", "camera_ir")
ull.hli_attach_plugin("camera_ir/frame", "camera_ir")
#ie.camera_ir.get()
ie.camera_ir.getSlice(19.,1, 0)
#print(ie.camera_ir.time)
print(len(ie.camera_ir.time))
print(ie.camera_ir.frame[0].time)
im = plt.imshow(ie.camera_ir.frame[0].image_raw[0:510,0:630])
plt.show()

