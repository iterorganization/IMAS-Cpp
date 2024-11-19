=========================================================================================================
Create IDS with Arrays of Structures (AoS)
=========================================================================================================

This example focuses on creating empty IDS and allocating arrays inside IDS structure.

.. literalinclude:: ../code_samples/tutorial/example_002_fill_data_in_ids.cpp
    :start-after: // This example focuses on creating empty IDS and allocating arrays inside IDS structure
    :end-before:  // This example focuses on handling arrays of structures and default values
    :language: cpp
    :dedent: 4

.. output::

    .. code-block:: bash

        Saved values of core_profiles from creating_completly_new_ids() function
        empty_core_profiles.ids_properties.homogeneous_time: 
        1
        empty_core_profiles.time:                            
        (0,2)
        [ 0 1 2 ]

        empty_core_profiles.global_quantities.ip:            
        (0,2)
        [ 0 1 2 ]