=========================================================================================================
Put Multiple Slices
=========================================================================================================

This example focuses on putting multiple slices of IDS into entry.

.. literalinclude:: ../code_samples/tutorial/example_003_write_data_into_entry.cpp
    :start-after: // This example focuses on putting multiple slices of IDS into entry
    :end-before:  // This example focuses on putting IDS into another occurrence
    :language: cpp
    :dedent: 4


.. output::

    .. code-block:: bash

        summary.ids_properties.homogeneous_time:                          
        1

        summary.time:                                                     
        (0,2)
        [ 50 60 70 ]

        summary.heating_current_drive.nbi(0).beam_current_fraction.value: 
        (0,2) x (0,2)
        [ 1000 1000 1000 
        2000 2000 2000 
        3000 3000 3000 ]

        summary.stationary_phase_flag.value:                              
        (0,2)
        [ 11 12 13 ]   

.. seealso::

    API documentation for :cpp:func:`IdsNs::IDS::open`, :cpp:func:`IdsNs::IDS::putSlice`