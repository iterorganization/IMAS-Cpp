Getting Started with IMAS C++ HLI
==================================

Welcome! This 5-minute guide will get you up and running with the IMAS C++ High Level Interface.

**What is IMAS C++ HLI?**

The IMAS C++ HLI is the IMAS data access library for C++ users/developers. 


Load the IMAS C++ Module
-------------------------

On the ITER SDCC (supercomputing cluster), make the Access Layer available:

.. code-block:: bash

    module load IMAS-Cpp

To see available versions:

.. code-block:: bash

    module avail IMAS-Cpp

If you have a local installation, source the environment file instead:

.. code-block:: bash

    source <install_dir>/bin/al_env.sh


Create a C++ Program and Connect to Data
-----------------------------------------

Create a C++ program and open a database entry using an IMAS URI. A URI tells the Access Layer 
where your data is stored and in what format.

.. code-block:: cpp

    #include "ALClasses.h"
    #include <iostream>

    int main() {
        // Open a database entry
        const char* uri = "imas:hdf5?path=/path/to/data";
        IdsNs::IDS entry(uri);
        
        if (entry.getError() != 0) {
            std::cerr << "Unable to open database" << std::endl;
            return 1;
        }
        
        return 0;
    }

**What's an IMAS URI?**

URIs follow the format: ``imas:backend?query_options``

For example:
- ``imas:hdf5?path=/path/to/data`` – Read from HDF5 files
- ``imas:mdsplus?path=./test_db`` – Read from MDSplus
- ``imas:uda?backend=...`` – Read from UDA backend

Learn more: :ref:`Data entry URIs`


Load and Display Data
---------------------

Fetch an IDS from your database entry:

.. code-block:: cpp

    // Load the magnetics IDS (occurrence 0)
    std::unique_ptr<IdsNs::magnetics> magnetics_ids = entry.magnetics.get(0);
    
    if (entry.getError() != 0) {
        std::cerr << "Unable to read magnetics" << std::endl;
        return 1;
    }
    
    // Explore the data
    std::cout << "IDS comment: " << magnetics_ids->ids_properties.comment << std::endl;
    std::cout << "Time points: " << magnetics_ids->time.size() << std::endl;
    
    // Access nested data
    if (!magnetics_ids->flux_loop.empty()) {
        std::cout << "First flux loop data points: " 
                  << magnetics_ids->flux_loop[0].flux.data.size() << std::endl;
    }


Modify and Store Data
---------------------

You can create new data, modify existing data, and store it back:

.. code-block:: cpp

    // Create a new IDS or modify existing one
    IdsNs::equilibrium eq_ids;
    eq_ids.time.resize(4);
    eq_ids.time = {0.0, 1.0, 2.0, 3.0};
    
    eq_ids.time_slice.resize(4);
    for (int i = 0; i < 4; i++) {
        eq_ids.time_slice[i].profiles_1d.q.resize(4);
        eq_ids.time_slice[i].profiles_1d.q = {1.0, 2.0, 3.0, 4.0};
    }
    
    // Store it to the database
    entry.equilibrium.put(0, &eq_ids);
    
    if (entry.getError() != 0) {
        std::cerr << "Unable to write equilibrium" << std::endl;
        return 1;
    }


Clean Up
--------

The database entry is automatically closed when the DBEntry object goes out of scope, 
but you can explicitly close it if needed:

.. code-block:: cpp

    // Cleanup happens automatically when 'entry' goes out of scope
    // No explicit close needed in C++


Key Classes and Methods Reference
----------------------------------

+-----------------------------------------------------------+--------------------------------------------+
| Class/Method                                              | Purpose                                    |
+===========================================================+============================================+
| ``IdsNs::IDS(uri)``                                       | Open a database entry at the given URI     |
+-----------------------------------------------------------+--------------------------------------------+
| ``entry.<ids_name>.get(occurrence)``                      | Load an entire IDS                         |
+-----------------------------------------------------------+--------------------------------------------+
| ``entry.<ids_name>.put(occurrence, ids*)``                | Store an IDS to disk                       |
+-----------------------------------------------------------+--------------------------------------------+
| ``entry.<ids_name>.getSlice(occurrence, time, interp)``   | Load a specific time slice                 |
+-----------------------------------------------------------+--------------------------------------------+
| ``entry.<ids_name>.putSlice(occurrence, ids*)``           | Store a time slice                         |
+-----------------------------------------------------------+--------------------------------------------+
| ``entry.getError()``                                      | Get the last error code                    |
+-----------------------------------------------------------+--------------------------------------------+


Common Use Cases
----------------

**Load data and extract a specific time slice:**

.. code-block:: cpp

    // Use CLOSEST interpolation (interp_mode = 1)
    std::unique_ptr<IdsNs::equilibrium> eq_data = entry.equilibrium.getSlice(0, 2.5, 1);


**Check if data is defined:**

.. code-block:: cpp

    if (magnetics_ids && !magnetics_ids->flux_loop.empty() 
        && magnetics_ids->flux_loop[0].flux.data.size() > 0) {
        std::cout << "Flux data is defined" << std::endl;
    }


**Access C++ examples:**

The repository contains several example programs in the ``examples/`` directory:
- ``test_core_profiles_get.cpp``  Load and display data
- ``test_core_profiles_put.cpp``  Store new data
- ``test_magnetics_get.cpp``  Practical magnetics data example


Next Steps
----------

- **Read more about IDSs**: :doc:`Use Interface Data Structures <identifiers>`
- **Learn advanced loading/storing**: :doc:`Loading and storing IMAS data <load_store_ids>`
- **Understand data storage**: :ref:`Data entry URIs`
- **Check the full API documentation**: See the `IMAS C++ HLI documentation <https://imas-cpp.readthedocs.io>`__


Common Issues
-------------

**"Unable to open pulse" error:**
- Check that your URI is correct and the data path exists

**IDS not found:**
- Verify the data entry contains this IDS
- Check the return value of ``get()`` methods and ``entry.getError()``

**Need help?**
- Check the :doc:`Using the Access Layer <using_al>` guide
- Consult the `IMAS C++ HLI documentation <https://imas-cpp.readthedocs.io/>`__