=========================================================================================================
Read IDS Slices
=========================================================================================================

This example focuses on reading IDS slices from entry.

.. literalinclude:: ../code_samples/tutorial/example_004_read_data_from_entry.cpp
    :start-after:  // This example focuses on reading IDS slices from entry
    :language: cpp
    :dedent: 4


.. output::

    .. code-block:: bash
        
        summary/global_quantities/ip/value slice at time=1.75 in PREVIOUS_SAMPLE mode: 10 (Should be 10.0)
        summary/global_quantities/ip/value slice at time=1.75 in CLOSEST_SAMPLE mode: 11 (Should be 11.0)
        summary/global_quantities/ip/value slice at time=1.75 in INTERPOLATION mode: 10.75 (Should be 10.75)

    
.. seealso::

    API documentation for :cpp:func:`IdsNs::IDS::open`, :cpp:func:`IdsNs::IDS::put`, :cpp:func:`IdsNs::IDS::getSlice`