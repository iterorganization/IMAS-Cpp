========================================================================================================================
How to run examples
========================================================================================================================

This code examples can be run using already prepared tests in

``al-cpp/doc/code_samples/tutorial/test_new_examples.cpp``.

1. Change the directory to ``al-cpp/doc/code_samples/tutorial``.

.. code-block:: bash

    cd al-cpp/doc/code_samples/tutorial


2. To **compile** the code, run the following command:

.. code-block:: bash

    g++ test_new_examples.cpp `pkg-config --libs --cflags imas-cpp` -pthread -o cplusplus

.. note::

    ``al-*`` package names     (e.g., ``al-cpp``, ``al-identifiers-cpp``) are also available 
    as symlinks and work identically to their ``imas-*`` counterparts.

3. To **run** the code, use the following command:

.. code-block:: bash

    ./cplusplus