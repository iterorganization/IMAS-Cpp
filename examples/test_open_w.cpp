#include "ALClasses.h"
#include <iostream>
#include <cstdio>
#include <string>

using namespace IdsNs;

// Helper function to check if a backend is available
bool is_backend_available(const std::string& backend_name) {
    std::string test_uri = "imas:" + backend_name + "?path=./test_db_backend_check_" + backend_name;
    
    try {
        IdsNs::IDS ids;
        int status = ids.open(test_uri.c_str(), FORCE_CREATE_PULSE);
        if (status < 0) {
            return false;
        }
        ids.close();
        
        return true;
    }
    catch (...) {
        return false;
    }
}

int test_open_w_backend(const std::string& backend_name, const std::string& db_path) {
    int status = 0;
    std::string uri = "imas:" + backend_name + "?path=" + db_path;

    std::cout << "--- Testing OPEN_W with " << backend_name << " backend ---" << std::endl;

    // Step 1: Create pulse and write initial data
    std::cout << "  Step 1: Creating pulse with initial data..." << std::endl;
    {
        IdsNs::IDS ids;
        ids.open(uri.c_str(), FORCE_CREATE_PULSE);

        ids._magnetics.ids_properties.homogeneous_time = 1;
        ids._magnetics.ids_properties.comment = "test comment";
        ids._magnetics.time.resize(2);
        ids._magnetics.time(0) = 0.0;
        ids._magnetics.time(1) = 0.1;

        ids._magnetics.put();
        ids.close();
        std::cout << "    Initial data written (time with 2 slices, comment='test comment')" << std::endl;
    }

    // Step 2: Open in OPEN_W mode and overwrite with new data
    std::cout << "  Step 2: Opening in OPEN_W mode and writing new data..." << std::endl;
    {
        IdsNs::IDS ids;
        ids.open(uri.c_str(), OPEN_W);

        ids._magnetics.ids_properties.homogeneous_time = 1;
        ids._magnetics.ids_properties.name = "new name";
        // Do not set comment - OPEN_W should remove the old one

        ids._magnetics.time.resize(5);
        for (int i = 0; i < 5; i++)
            ids._magnetics.time(i) = 1.0 + 0.1 * i;

        ids._magnetics.flux_loop.resize(2);
        ids._magnetics.flux_loop(0).flux.data.resize(5);
        for (int i = 0; i < 5; i++)
            ids._magnetics.flux_loop(0).flux.data(i) = 100.0 + i;
        ids._magnetics.flux_loop(1).flux.data.resize(5);
        for (int i = 0; i < 5; i++)
            ids._magnetics.flux_loop(1).flux.data(i) = 200.0 + i;

        ids._magnetics.put();
        ids.close();
        std::cout << "    New data written (time with 5 slices, name='new name')" << std::endl;
    }

    // Step 3: Open in OPEN_R mode and verify OPEN_W behavior
    std::cout << "  Step 3: Verifying OPEN_W behavior..." << std::endl;
    {
        IdsNs::IDS ids;
        ids.open(uri.c_str(), OPEN_R);

        ids._magnetics.get();
        
        // Verify comment was removed (should be empty)
        std::cout << "    ids_properties.comment: '" << ids._magnetics.ids_properties.comment << "'" << std::endl;
        if (ids._magnetics.ids_properties.comment == "test comment")
        {
            std::cout << "    ISSUE: comment should have been removed by OPEN_W" << std::endl;
            status = 1;
        }
        else
        {
            std::cout << "    Comment correctly removed by OPEN_W" << std::endl;
        }

        // Verify name is set
        std::cout << "    ids_properties.name: '" << ids._magnetics.ids_properties.name << "'" << std::endl;
        if (ids._magnetics.ids_properties.name != "new name")
        {
            std::cout << "    ISSUE: Expected name='new name', got '" << ids._magnetics.ids_properties.name << "'" << std::endl;
            status = 1;
        }
        else
        {
            std::cout << "    Name correctly set" << std::endl;
        }

        // Verify time has new size (5, not 2)
        int time_slices = ids._magnetics.time.size();
        std::cout << "    Found " << time_slices << " time slices" << std::endl;

        if (time_slices != 5)
        {
            std::cout << "    ISSUE: Expected 5 time slices (new data), got " << time_slices << std::endl;
            status = 1;
        }
        else
        {
            std::cout << "    Time correctly overwritten (5 slices instead of original 2)" << std::endl;
            
            // Verify first time value
            if (ids._magnetics.time(0) != 1.0)
            {
                std::cout << "    ISSUE: Expected time(0)=1.0, got " << ids._magnetics.time(0) << std::endl;
                status = 1;
            }
        }

        // Verify flux_loop data exists
        int flux_loop_count = ids._magnetics.flux_loop.size();
        std::cout << "    Found " << flux_loop_count << " flux_loop elements" << std::endl;

        if (flux_loop_count != 2)
        {
            std::cout << "    ISSUE: Expected 2 flux_loop elements, got " << flux_loop_count << std::endl;
            status = 1;
        }
        else
        {
            std::cout << "    Flux loop data correctly written" << std::endl;
        }

        if (status == 0)
            std::cout << "    OPEN_W correctly removed old data and wrote new data" << std::endl;

        ids.close();
    }

    if (status == 0)
        std::cout << "  " << backend_name << " backend: PASSED" << std::endl;
    else
        std::cout << "  " << backend_name << " backend: NOT PASSED" << std::endl;

    return status;
}

int main(int argc, char *argv[])
{
    int total_status = 0;

    std::cout << "=== Testing OPEN_W (write + remove existing) mode ===" << std::endl;

    // Test MDSPLUS backend
    if (is_backend_available("mdsplus"))
    {
        total_status |= test_open_w_backend("mdsplus", "./test_db_mdsplus_test_open_w_mdsplus");
    }
    else
    {
        std::cout << "--- MDSPLUS backend not available, skipping ---" << std::endl;
    }

    // Test HDF5 backend
    if (is_backend_available("hdf5"))
    {
        total_status |= test_open_w_backend("hdf5", "./test_db_hdf5_test_open_w_hdf5");
    }
    else
    {
        std::cout << "--- HDF5 backend not available, skipping ---" << std::endl;
    }

    // Test ASCII backend
    total_status |= test_open_w_backend("ascii", "./test_db_ascii_test_open_w_ascii");

    if (total_status == 0)
        std::cout << "=== OPEN_W test PASSED (all available backends) ===" << std::endl;
    else
        std::cout << "=== OPEN_W test NOT PASSED ===" << std::endl;

    return total_status;
}
