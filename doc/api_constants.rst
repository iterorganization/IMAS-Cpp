IMAS constants
==============


Interpolation modes
-------------------

.. c:macro:: CLOSEST_SAMPLE

    Interpolation method that returns the `closest` time slice in the original
    IDS (can break causality as it can return data ahead of requested time).

    .. seealso:: :cpp:expr:`IdsNs::Ids::getSlice`

.. c:macro:: PREVIOUS_SAMPLE

    Interpolation method that returns the previous time slice if the requested
    time does not exactly exist in the original IDS.

    .. seealso:: :cpp:expr:`IdsNs::Ids::getSlice`

.. c:macro:: INTERPOLATION

    Interpolation method that returns a linear interpolation between the
    existing slices before and after the requested time.

    .. seealso:: :cpp:expr:`IdsNs::Ids::getSlice`


Empty values
------------

.. cpp:var:: static const int EMPTY_INT = -999999999

    Value representing an unset integer in an IDS.

.. cpp:var:: static const double EMPTY_DOUBLE = -9.0E40

    Value representing an unset floating point number in an IDS.

.. cpp:var:: static const std::complex<double> EMPTY_COMPLEX = std::complex<double>(EMPTY_DOUBLE, EMPTY_DOUBLE)

    Value representing an unset complex number in an IDS.


Serializer protocols
--------------------

.. c:macro:: ASCII_SERIALIZER_PROTOCOL

    Identifier for the ASCII serialization protocol.

.. c:macro:: DEFAULT_SERIALIZER_PROTOCOL

    Identifier for the default serialization protocol.


Time modes
----------

.. cpp:var:: static const int IDS_TIME_MODE_HETEROGENEOUS = 0

    Time mode indicating that dynamic nodes may be asynchronous.

    Timebases of quantities are as indicated in the "Coordinates" column of the
    Data Dictionary documentation.

.. cpp:var:: static const int IDS_TIME_MODE_HOMOGENEOUS = 1

    Time mode indicating that dynamic nodes are synchronous.

    Timebases of quantities are the "time" node that is the child of the nearest
    parent IDS.

.. cpp:var:: static const int IDS_TIME_MODE_INDEPENDENT = 2

    Time mode indicating that no dynamic nodes are filled in the IDS.


Backend identifiers
-------------------

.. cpp:enum:: BACKEND

    .. cpp:enumerator:: NO_BACKEND
    .. cpp:enumerator:: ASCII_BACKEND

        :ref:`ASCII backend`

    .. cpp:enumerator:: MDSPLUS_BACKEND

        :ref:`MDSPLUS backend`

    .. cpp:enumerator:: HDF5_BACKEND

        :ref:`HDF5 backend`

    .. cpp:enumerator:: MEMORY_BACKEND

        :ref:`MEMORY backend`

    .. cpp:enumerator:: UDA_BACKEND

        :ref:`UDA backend`


Data entry open/create modes
----------------------------

.. c:macro:: OPEN_PULSE

    Opens the access to the data only if the Data Entry exists, returns error
    otherwise.

.. c:macro:: FORCE_OPEN_PULSE

    Opens access to the data, creates the Data Entry if it does not exists yet.

.. c:macro:: CREATE_PULSE

    Creates a new empty Data Entry (returns error if Data Entry already exists)
    and opens it at the same time.

.. c:macro:: FORCE_CREATE_PULSE

    Creates an empty Data Entry (overwrites if Data Entry already exists) and
    opens it at the same time.


Version constants
-----------------

.. cpp:function:: const char * getALVersion()

    Get the Access Layer low-level version.

    Returns the version (C) string of the low-level component of the Access
    Layer, for example ``"5.1.0"``.

.. cpp:var:: std::string al_cpp_version

    Get the version string of the C++ Access Layer library, for
    example ``"5.1.0"``.

.. cpp:var:: int al_cpp_major_version
    
    Get the major version of the C++ Access Layer library, for example ``5``.

.. cpp:var:: int al_cpp_minor_version
    
    Get the minor version of the C++ Access Layer library, for example ``1``.
    
.. cpp:var:: int al_cpp_patch_version

    Get the patch version of the C++ Access Layer library, for example ``0``.

.. cpp:var:: std::string al_dd_version

    Get the version string of the Data Dictionary definitions that are used, for
    example ``"3.39.0"``.

.. cpp:var:: int al_dd_major_version

    Get the major version of the Data Dictionary definitions that are used, for
    example ``3``.

.. cpp:var:: int al_dd_minor_version

    Get the minor version of the Data Dictionary definitions that are used, for
    example ``39``.

.. cpp:var:: int al_dd_patch_version

    Get the patch version of the Data Dictionary definitions that are used, for
    example ``0``.
