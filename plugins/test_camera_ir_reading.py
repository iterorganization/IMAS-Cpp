import imas, sys
import matplotlib.pyplot as plt
from imas import _ual_lowlevel as ull
import numpy as np
ie=imas.ids(56927,0)
ie.open_env_backend('LF218007','test_camera','3',13)
ull.hli_register_plugin("camera_ir");
ull.hli_bind_plugin("camera_ir/frame", "camera_ir")
ull.hli_bind_plugin("camera_ir/frame/image_raw", "camera_ir")
#ie.camera_ir.get()
t = int(sys.argv[1])
print("Time = ", str(t))
ie.camera_ir.getSlice(t, 1, 0)

#print(ie.camera_ir.time)
print(len(ie.camera_ir.time))
im = plt.imshow(ie.camera_ir.frame[0].image_raw[0:510,0:630])
plt.show()

