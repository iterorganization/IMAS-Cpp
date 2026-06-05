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
        IdsNs::IDS ids;
        int status = ids.open("imas:hdf5?path=/path/to/data", OPEN_PULSE);
        
        if (status != 0) {
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
    ids._magnetics.get();
    
    // Explore the data
    std::cout << "IDS comment: " << ids._magnetics.ids_properties.comment << std::endl;
    std::cout << "Time points: " << ids._magnetics.time.extent(0) << std::endl;
    
    // Access nested data
    if (ids._magnetics.flux_loop.extent(0) > 0) {
        std::cout << "First flux loop data points: " 
                  << ids._magnetics.flux_loop(0).flux.data.extent(0) << std::endl;
    }


Modify and Store Data
---------------------

You can create new data, modify existing data, and store it back:

.. code-block:: cpp

    // Set mandatory properties
    ids._core_profiles.ids_properties.homogeneous_time = IDS_TIME_MODE_HOMOGENEOUS;
    ids._core_profiles.ids_properties.comment = "Test data from C++";
    
    // Allocate and fill time array
    ids._core_profiles.time.resize(3);
    ids._core_profiles.time(0) = 0.0;
    ids._core_profiles.time(1) = 1.0;
    ids._core_profiles.time(2) = 2.0;
    
    // Store it to the database (occurrence 0)
    int status = ids._core_profiles.put();
    
    if (status != 0) {
        std::cerr << "Unable to write core_profiles" << std::endl;
        return 1;
    }


Clean Up
--------

Always close the database entry when you're done:

.. code-block:: cpp

    ids.close();


Key Classes and Methods Reference
----------------------------------

+-----------------------------------------------------------+--------------------------------------------+
| Class/Method                                              | Purpose                                    |
+===========================================================+============================================+
| ``IdsNs::IDS ids;``                                       | Create IDS database entry object           |
+-----------------------------------------------------------+--------------------------------------------+
| ``ids.open(uri, mode)``                                   | Open database entry (returns status)       |
+-----------------------------------------------------------+--------------------------------------------+
| ``ids._<ids_name>.get()``                                 | Load entire IDS (occurrence 0)             |
+-----------------------------------------------------------+--------------------------------------------+
| ``ids._<ids_name>.get(occurrence)``                       | Load entire IDS at occurrence              |
+-----------------------------------------------------------+--------------------------------------------+
| ``ids._<ids_name>.put()``                                 | Store IDS to disk (occurrence 0)           |
+-----------------------------------------------------------+--------------------------------------------+
| ``ids._<ids_name>.put(occurrence)``                       | Store IDS at occurrence                    |
+-----------------------------------------------------------+--------------------------------------------+
| ``ids._<ids_name>.getSlice(time, interp)``                | Load time slice (occurrence 0)             |
+-----------------------------------------------------------+--------------------------------------------+
| ``ids._<ids_name>.putSlice()``                            | Append time slice to disk                  |
+-----------------------------------------------------------+--------------------------------------------+
| ``ids.close()``                                           | Close the database entry                   |
+-----------------------------------------------------------+--------------------------------------------+


Common Use Cases
----------------

**Load data and extract a specific time slice:**

.. code-block:: cpp

    // Use CLOSEST interpolation (interp_mode = 1)
    ids._equilibrium.getSlice(2.5, 1);
    
    // Access the interpolated data
    std::cout << "R0 at t=2.5: " << ids._equilibrium.vacuum_toroidal_field.r0 << std::endl;


**Check if data is defined:**

.. code-block:: cpp

    if (ids._magnetics.isDefined() 
        && ids._magnetics.flux_loop.extent(0) > 0
        && ids._magnetics.flux_loop(0).flux.data.extent(0) > 0) {
        std::cout << "Flux data is defined" << std::endl;
    }


**Access C++ examples:**

The repository contains several example programs in the ``examples/`` directory:
- ``test_core_profiles_get.cpp``  Load and display data
- ``test_core_profiles_put.cpp``  Store new data
- ``test_magnetics_get.cpp``  Practical magnetics data example


Next Steps
----------

- **Read more about IDSs**: :doc:`Use Interface Data Structures <use_ids>`
- **Learn advanced loading/storing**: :doc:`Loading and storing IMAS data <load_store_ids>`
- **Understand data storage**: :ref:`Data entry URIs`
- **Learn about identifiers**:  :doc:`The identifiers library <identifiers>`
- **Check the full API documentation**: See the `IMAS C++ HLI documentation <https://imas-cpp.readthedocs.io>`__


