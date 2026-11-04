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

int test_open_a_backend(const std::string& backend_name, const std::string& db_path) {
    int status = 0;
    std::string uri = "imas:" + backend_name + "?path=" + db_path;

    std::cout << "--- Testing OPEN_A with " << backend_name << " backend ---" << std::endl;

    // Step 1: Create pulse and write time data only
    std::cout << "  Step 1: Creating pulse with time data (time=[0.0, 0.1])..." << std::endl;
    {
        IdsNs::IDS ids;
        ids.open(uri.c_str(), FORCE_CREATE_PULSE);

        ids._magnetics.ids_properties.homogeneous_time = 1;
        ids._magnetics.time.resize(2);
        ids._magnetics.time(0) = 0.0;
        ids._magnetics.time(1) = 0.1;

        // Do not set flux_loop in this step
        ids._magnetics.put();
        ids.close();
        std::cout << "    Time data written" << std::endl;
    }

    // Step 2: Open in OPEN_A mode and write flux_loop data (without overwriting time)
    std::cout << "  Step 2: Opening in OPEN_A mode and writing flux_loop data..." << std::endl;
    {
        IdsNs::IDS ids;
        ids.open(uri.c_str(), OPEN_A);

        ids._magnetics.get();

        ids._magnetics.flux_loop.resize(2);
        ids._magnetics.flux_loop(0).flux.data.resize(2);
        ids._magnetics.flux_loop(0).flux.data(0) = 100.0;
        ids._magnetics.flux_loop(0).flux.data(1) = 101.0;
        ids._magnetics.flux_loop(1).flux.data.resize(2);
        ids._magnetics.flux_loop(1).flux.data(0) = 200.0;
        ids._magnetics.flux_loop(1).flux.data(1) = 201.0;

        ids._magnetics.put();
        ids.close();
        std::cout << "    Flux loop data written" << std::endl;
    }

    // Step 3: Open in OPEN_R mode and verify both time and flux_loop exist
    std::cout << "  Step 3: Verifying that both time and flux_loop data exist..." << std::endl;
    {
        IdsNs::IDS ids;
        ids.open(uri.c_str(), OPEN_R);

        ids._magnetics.get();
        
        // Verify time data
        int time_slices = ids._magnetics.time.size();
        std::cout << "    Found " << time_slices << " time slices" << std::endl;

        if (time_slices != 2)
        {
            std::cout << "    ISSUE: Expected 2 time slices, got " << time_slices << std::endl;
            status = 1;
        }
        else
        {
            std::cout << "    Time values: ";
            for (int i = 0; i < time_slices; i++)
                std::cout << ids._magnetics.time(i) << " ";
            std::cout << std::endl;

            double expected_times[] = {0.0, 0.1};
            for (int i = 0; i < 2; i++)
            {
                if (ids._magnetics.time(i) != expected_times[i])
                {
                    std::cout << "    ISSUE: Expected time[" << i << "]=" << expected_times[i] 
                              << ", got " << ids._magnetics.time(i) << std::endl;
                    status = 1;
                }
            }
        }

        // Verify flux_loop data
        int flux_loop_count = ids._magnetics.flux_loop.size();
        std::cout << "    Found " << flux_loop_count << " flux_loop elements" << std::endl;

        if (flux_loop_count != 2)
        {
            std::cout << "    ISSUE: Expected 2 flux_loop elements, got " << flux_loop_count << std::endl;
            status = 1;
        }
        else
        {
            std::cout << "    flux_loop(0).flux.data: ";
            for (int i = 0; i < ids._magnetics.flux_loop(0).flux.data.size(); i++)
                std::cout << ids._magnetics.flux_loop(0).flux.data(i) << " ";
            std::cout << std::endl;

            std::cout << "    flux_loop(1).flux.data: ";
            for (int i = 0; i < ids._magnetics.flux_loop(1).flux.data.size(); i++)
                std::cout << ids._magnetics.flux_loop(1).flux.data(i) << " ";
            std::cout << std::endl;

            // Verify flux_loop data values
            if (ids._magnetics.flux_loop(0).flux.data(0) != 100.0 ||
                ids._magnetics.flux_loop(0).flux.data(1) != 101.0)
            {
                std::cout << "    ISSUE: flux_loop(0) data mismatch" << std::endl;
                status = 1;
            }
            if (ids._magnetics.flux_loop(1).flux.data(0) != 200.0 ||
                ids._magnetics.flux_loop(1).flux.data(1) != 201.0)
            {
                std::cout << "    ISSUE: flux_loop(1) data mismatch" << std::endl;
                status = 1;
            }
        }

        if (status == 0)
            std::cout << "    Data correctly preserved (time from Step 1, flux_loop from Step 2)" << std::endl;

        ids.close();
    }

    // Step 4: Test OPEN_A with non-existing entry (should create new)
    std::cout << "  Step 4: Testing OPEN_A with non-existing entry..." << std::endl;
    {
        std::string new_uri = "imas:" + backend_name + "?path=" + db_path + "_new";
        IdsNs::IDS ids;
        ids.open(new_uri.c_str(), OPEN_A);

        ids._magnetics.ids_properties.homogeneous_time = 1;
        ids._magnetics.time.resize(1);
        ids._magnetics.time(0) = 1.0;
        ids._magnetics.flux_loop.resize(1);
        ids._magnetics.flux_loop(0).flux.data.resize(1);
        ids._magnetics.flux_loop(0).flux.data(0) = 999.0;

        ids._magnetics.put();
        ids.close();
        std::cout << "    New entry created successfully with OPEN_A" << std::endl;
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

    std::cout << "=== Testing OPEN_A (append / update) mode ===" << std::endl;

    // Test MDSPLUS backend
    if (is_backend_available("mdsplus"))
    {
        total_status |= test_open_a_backend("mdsplus", "./test_db_mdsplus_test_open_a_mdsplus");
    }
    else
    {
        std::cout << "--- MDSPLUS backend not available, skipping ---" << std::endl;
    }

    // Test HDF5 backend
    if (is_backend_available("hdf5"))
    {
        total_status |= test_open_a_backend("hdf5", "./test_db_hdf5_test_open_a_hdf5");
    }
    else
    {
        std::cout << "--- HDF5 backend not available, skipping ---" << std::endl;
    }

    // Test ASCII backend
    total_status |= test_open_a_backend("ascii", "./test_db_ascii_test_open_a_ascii");

    if (total_status == 0)
        std::cout << "=== OPEN_A test PASSED (all available backends) ===" << std::endl;
    else
        std::cout << "=== OPEN_A test NOT PASSED ===" << std::endl;

    return total_status;
}
