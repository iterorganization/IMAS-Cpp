import imas
import matplotlib.pyplot as plt
from imas import _ual_lowlevel as ull
ie=imas.ids(56928,0)
ie.create_env_backend('LF218007','test_camera','3',13)
ie.camera_ir.ids_properties.homogeneous_time=1
ie.camera_ir.time.resize(1)
ie.camera_ir.time[0]=0.
ull.hli_register_plugin("imas3121");
ull.hli_bind_plugin("camera_ir/ids_properties/creation_date", "imas3121")
ie.camera_ir.put()
ull.hli_unregister_plugin("imas3121");

