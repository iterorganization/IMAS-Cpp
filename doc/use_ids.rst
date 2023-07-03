
.. highlight:: c++

.. include:: ../../doc_common/use_ids.rst

.. |lang| replace:: C++

.. |create_ids_text| replace:: creating a new class object for that IDS, for example :code:`IdsNs::IDS::core_profiles()`
.. |copy_ids| replace:: by putting it to the memory backend and getting it again
.. |deallocate_ids_text| replace:: In C++ an IDS is automatically deallocated when it falls outside scope.

.. |structures_type| replace:: ``class``
.. |structures_child_attribute| replace:: data members
.. |aos_type| replace:: a :ref:`Blitz++` Array of structures
.. |aos_default| replace:: an empty :ref:`Blitz++` Array (:code:`node.size() == 0`)
.. |aos_resize_meth| replace:: :code:`resize(n)`
.. |aos_resize_keep_meth| replace:: :code:`resizeAndPreserve(n)`

.. |str_type| replace:: :cpp:expr:`std::string`
.. |str_1d_type| replace:: 1D :ref:`Blitz++` ``Array`` of :cpp:expr:`std::string`
.. |int_type| replace:: :cpp:expr:`int`
.. |int_nd_type| replace:: N-dimensional :ref:`Blitz++` ``Array`` of :cpp:expr:`int`
.. |double_type| replace:: :cpp:expr:`double`
.. |double_nd_type| replace:: N-dimensional :ref:`Blitz++` ``Array`` of :cpp:expr:`double`
.. |complex_type| replace:: :cpp:expr:`std::complex<double>`
.. |complex_nd_type| replace:: N-dimensional :ref:`Blitz++` ``Array`` of :cpp:expr:`std::complex<double>`

.. |str_default| replace:: an empty string (:code:`""`)
.. |str_1D_default| replace:: an empty :ref:`Blitz++` ``Array``
.. |int_default| replace:: :code:`-999_999_999`, :cpp:expr:`EMPTY_INT`
.. |double_default| replace:: :code:`-9e40`, :cpp:expr:`EMPTY_DOUBLE`
.. |complex_default| replace:: :code:`-9e40 -9e40i`, :cpp:expr:`EMPTY_COMPLEX`
.. |ND_default| replace:: an empty :ref:`Blitz++` ``Array``

.. |isFieldValid| replace:: \ .. no equivalent in C++ API

.. |tm_homogeneous| replace:: :cpp:expr:`IDS_TIME_MODE_HOMOGENEOUS`
.. |tm_heterogeneous| replace:: :cpp:expr:`IDS_TIME_MODE_HETEROGENEOUS`
.. |tm_independent| replace:: :cpp:expr:`IDS_TIME_MODE_INDEPENDENT`

.. todo
    .. |ids_validate| replace:: :py:meth:`ids.validate <imas.ids_base.IDSBase.validate>`
    .. |validate_error| replace:: raises an error


Blitz++
-------

`Blitz++ <https://github.com/blitzpp/blitz>`_ is a multi-dimensional array
library for C++. The Access Layer uses Blitz++ ``Array``\ s for all
dimensional nodes (:ref:`Array of structures` and :ref:`Data` nodes of 1 or more
dimensions).

See the `Blitz++ documentation
<https://github.com/blitzpp/blitz/wiki/Documentation,-etc>`_ for the (API)
documentation for Blitz++ ``Array``.
