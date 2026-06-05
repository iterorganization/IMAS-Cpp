.. include:: ./doc_common/using_al.rst

Using the Access Layer with your C++ program
--------------------------------------------

The following example program will load the C++ interface to the Access Layer
to print the version of the access layer and data dictionary.

.. highlight:: c++


.. literalinclude:: code_samples/imas_hello_world.cpp
    :caption: ``imas_hello_world.cpp``

.. seealso:: :ref:`Version constants`

If you save this as a file ``imas_hello_world.cpp``, you can compile it as
follows:

.. code-block:: bash

    g++ imas_hello_world.cpp `pkg-config --libs --cflags imas-cpp` -pthread -o imas_hello_world

We use ``pkg-config`` to output the required libraries and compiler flags to use
the C++ Access Layer. Feel free to use a different compiler than gcc, and/or add
additional compilation flags to your liking.

.. note::

    Compilation and linking flags for the IMAS-Cpp library can simply be obtained with the following pkg-config names:

    - ``imas-cpp`` (or ``al-cpp`` for compatibility with versions < 5.6) for the data access library (definition of IDS objects, I/O functions, etc...)
    - ``imas-identifiers-cpp`` (or ``al-identifiers-cpp``) for the :doc:identifiers library <identifiers>


When the compilation is successful, a program ``imas_hello_world``
was compiled for you. When you execute it, the result is:

.. code-block:: console

    $ ./imas_hello_world
    Hello world!
    Access Layer version info:
      Low level version: 5.0.0
      Data Dictionary version: 3.39.0
      C++ HLI version: 5.0.0


Congratulations if this runs successfully! You have included the C++ Access
Layer successfully in a program. In the next sections of the documentation you
can see how to:

- :ref:`Loading and storing IMAS data`
- :ref:`Use Interface Data Structures`

