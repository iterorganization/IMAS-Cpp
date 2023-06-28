.. include:: ../../doc_common/using_al.rst

Using the Access Layer with your C++ program
--------------------------------------------

The following example program will load the C++ interface to the Access Layer
to print the version of the access layer and data dictionary.

.. highlight:: c++


.. literalinclude:: code_samples/imas_hello_world.cpp
    :caption: ``imas_hello_world.cpp``


If you save this as a file ``imas_hello_world.cpp``, you can compile it as
follows:

.. code-block:: bash

    gcc `pkg-config --libs --cflags al-cpp` -pthread imas_hello_world.cpp -o imas_hello_world

We use ``pkg-config`` to output the required libraries and compiler flags to use
the C++ Access Layer. Feel free to use a different compiler than gcc, and/or add
additional compilation flags to your liking.

When the compilation is successful, a program ``imas_hello_world``
was compiled for you. When you execute it, the result is:

.. code-block:: console

    $ ./imas_hello_world
    Hello world!
    Using access layer version: 4.11.4 with data dictionary version: 3.38.1


Congratulations if this runs successfully! You have included the C++ Access
Layer successfully in a program. In the next sections of the documentation you
can see how to:

- :ref:`Loading and storing IMAS data`
- :ref:`Use Interface Data Structures`

