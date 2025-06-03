=========================================================================================================
Create DBEntry from scratch using *legacy* mode
=========================================================================================================

This example focuses on creating DBEntry using **legacy** mode method.

.. seealso::

    API documentation for :cpp:func:`IdsNs::IDS::setBackend`, :cpp:func:`IdsNs::IDS::openEnv` (legacy)
    
.. warning::

    The legacy method is deprecated from ``AL>=5.0.0``.

    It is recommended to use the **URI** approach instead.

.. literalinclude::../code_samples/tutorial/example_001_open_database.cpp
    :start-after: // This example focuses on creating DBEntry using legacy mode method
    :end-before:  // This example focuses on opening DBEntry using URI
    :language: cpp
    :dedent: 4
