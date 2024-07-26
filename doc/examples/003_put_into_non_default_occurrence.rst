========================================================================================================================
Put IDS into non-default occurrence
========================================================================================================================

This example focuses on putting IDS into another occurrence.

.. literalinclude:: ../code_samples/tutorial/example_003_write_data_into_entry.cpp
    :start-after:  // This example focuses on putting IDS into another occurrence
    :language: cpp
    :dedent: 4


.. output::

    .. code-block:: bash
    
        equilibrium.ids_properties.homogeneous_time: 
        1
        equilibrium.time:                            
        (0,2)
        [ 1 2 3 ]

        equilibrium.vacuum_toroidal_field.b0:        
        (0,2)
        [ 11 22 33 ]

        equilibrium.vacuum_toroidal_field.r0:        
        25.5
        equilibrium.ids_properties.comment           
        comment
        0 1 comment
        1 2 comment

.. seealso::

    API documentation for :cpp:func:`IdsNs::IDS::open`, :cpp:func:`IdsNs::IDS::put`, :cpp:func:`IdsNs::IDS::list_all_occurrences`