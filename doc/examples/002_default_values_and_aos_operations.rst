========================================================================================================================
Handling Array of Structures and its default values in IDS
========================================================================================================================

This example focuses on handling arrays of structures and default values.

.. literalinclude:: ../code_samples/tutorial/example_002_fill_data_in_ids.cpp
    :start-after: // This example focuses on handling arrays of structures and default values
    :end-before:  // This example focuses on creating multi-dimensional arrays, using copmlex type and copying IDS structures
    :language: cpp
    :dedent: 4


.. output::

    .. code-block:: bash

        edge_profiles/grid_ggd after merge:
        First test struct
        
        edge_profiles/grid_ggd after merge:
        Second test struct

        Default value for "INT"   data  (edge_profiles/midplane/index)                                   : -999999999
        Default value for "FLOAT"   data  (edge_profiles/vacuum_toroidal_field/vacuum_toroidal_field/r0) : -9e+40
        Default value for "COMPLEX" data                                                                 : (-9e+40,-9e+40)
        Default value for 1+ dimensional data   

.. seealso::

    API documentation for :code:`resizeAndPreserve(n)`