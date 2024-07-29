=========================================================================================================
Create and copy multi-dimensional AoS 
=========================================================================================================

This example focuses on creating multi=dimensional arrays, using copmlex type and copying IDS structures.

.. literalinclude:: ../code_samples/tutorial/example_002_fill_data_in_ids.cpp
    :start-after:  // This example focuses on creating multi-dimensional arrays, using copmlex type and copying IDS structures
    :language: cpp
    :dedent: 4


.. output::

    .. code-block:: bash

        Filled 2D array (gyrokinetics_local/non_linear/fields_zonal_2d/phi_potential_perturbed_norm): 
        (0,2) x (0,2)
        [ (0,0) (1,0) (2,0) 
        (1,0) (2,0) (3,0) 
        (2,0) (3,0) (4,0) ]

        Caught exception (raised intentionally):
        Element 'non_linear/fields_zonal_2d/phi_potential_perturbed_norm(:,:)' 
        must have its coordinate in dimension 0 (any of non_linear/radial_wavevector_norm) filled.
        
        Original value:
        (0,2) x (0,2)
        [ (0,0) (0,1) (0,2) 
        (1,0) (1,1) (1,2) 
        (2,0) (2,1) (2,2) ]

        Copied value:
        (0,2) x (0,2)
        [ (0,0) (0,-1) (0,-2) 
        (-1,0) (-1,-1) (-1,-2) 
        (-2,0) (-2,-1) (-2,-2) ]  

.. seealso::

    API documentation for :cpp:func:`IdsNs::IDS::validate`