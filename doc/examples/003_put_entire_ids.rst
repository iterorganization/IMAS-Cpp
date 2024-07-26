========================================================================================================================
Put entire IDS
========================================================================================================================

This example focuses on putting IDS into entry and passing IDS validation.

.. literalinclude:: ../code_samples/tutorial/example_003_write_data_into_entry.cpp
    :start-after: // This example focuses on putting IDS into entry and passing IDS validation
    :end-before:  // This example focuses on putting multiple slices of IDS into entry
    :language: cpp
    :dedent: 4


.. output::

    .. code-block:: bash

        equilibrium.ids_properties.homogeneous_time: 
        1
        equilibrium.time:                            
        (0,2)
        [ 0 1 2 ]

        equilibrium.vacuum_toroidal_field.b0:        
        (0,2)
        [ 0 1 2 ]   

.. seealso::

    API documentation for :cpp:func:`IdsNs::IDS::open`, :cpp:func:`IdsNs::IDS::put`