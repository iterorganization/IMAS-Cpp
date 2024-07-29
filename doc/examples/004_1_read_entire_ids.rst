=========================================================================================================
Read Entire IDS
=========================================================================================================

This example focuses on reading whole IDS from entry.

.. literalinclude:: ../code_samples/tutorial/example_004_read_data_from_entry.cpp
    :start-after: // This example focuses on reading whole IDS from entry.
    :end-before:  // This example focuses on reading IDS slices from entry
    :language: cpp
    :dedent: 4


.. output::

    .. code-block:: bash
        
        is equilibrium defined?:1

.. seealso::

    API documentation for :cpp:func:`IdsNs::IDS::open`, :cpp:func:`IdsNs::IDS::put`, :cpp:func:`IdsNs::IDS::get`