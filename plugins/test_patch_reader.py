import imas
import matplotlib.pyplot as plt
from imas import _ual_lowlevel as ull
import numpy as np
ie=imas.ids(56927,0)
ie.open_env_backend('LF218007','test_camera','3',13)
ull.hli_register_plugin("patch_reader");
ull.hli_setvalue_int_scalar_parameter_plugin("op", 3, "patch_reader");
#ps = np.array([1, 2, 3]);
#ull.hli_setvalue_parameter_plugin("test_p", ps, "patch_reader");

ull.hli_bind_plugin("camera_ir/frame/image_raw", "patch_reader")
#ull.hli_unbind_plugin("camera_ir/*", "patch_reader")
ie.camera_ir.get()
print(ie.camera_ir.frame[0].image_raw)


