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

int test_open_r_backend(const std::string& backend_name, const std::string& db_path) {
    int status = 0;
    std::string uri = "imas:" + backend_name + "?path=" + db_path;

    std::cout << "--- Testing OPEN_R with " << backend_name << " backend ---" << std::endl;

    // Step 1: Create pulse and write data
    std::cout << "  Step 1: Creating pulse and writing data..." << std::endl;
    {
        IdsNs::IDS ids;
        ids.open(uri.c_str(), FORCE_CREATE_PULSE);

        ids._magnetics.ids_properties.homogeneous_time = 1;
        ids._magnetics.time.resize(5);
        for (int i = 0; i < 5; i++)
            ids._magnetics.time(i) = 0.1 * i;

        ids._magnetics.flux_loop.resize(2);
        for (int j = 0; j < 2; j++)
        {
            ids._magnetics.flux_loop(j).flux.data.resize(5);
            for (int i = 0; i < 5; i++)
                ids._magnetics.flux_loop(j).flux.data(i) = j * 100.0 + i;
        }

        ids._magnetics.put();
        ids.close();
        std::cout << "    Data written successfully" << std::endl;
    }

    // Step 2: Open in OPEN_R mode and read
    std::cout << "  Step 2: Opening pulse in OPEN_R mode and reading..." << std::endl;
    {
        IdsNs::IDS ids;
        ids.open(uri.c_str(), OPEN_R);

        ids._magnetics.get();
        std::cout << "    Read " << ids._magnetics.time.size() << " time slices" << std::endl;
        std::cout << "    flux_loop(0).flux.data(0) = " << ids._magnetics.flux_loop(0).flux.data(0) << std::endl;

        ids.close();
    }

    // Step 3: Try to write in OPEN_R mode (should fail)
    std::cout << "  Step 3: Attempting to write in OPEN_R mode (should be rejected)..." << std::endl;
    {
        IdsNs::IDS ids;
        ids.open(uri.c_str(), OPEN_R);

        ids._magnetics.time.resize(3);
        for (int i = 0; i < 3; i++)
            ids._magnetics.time(i) = 0.5 * i;

        try
        {
            int put_status = ids._magnetics.put();
            if (put_status < 0)
            {
                std::cout << "    Write correctly rejected in OPEN_R mode (status=" << put_status << ")" << std::endl;
            }
            else
            {
                std::cout << "    ISSUE: Write succeeded in OPEN_R mode (should have been rejected)" << std::endl;
                status = 1;
            }
        }
        catch (const std::exception& e)
        {
            std::cout << "    Write correctly rejected (throw: " << e.what() << ")" << std::endl;
        }
        catch (...)
        {
            std::cout << "    Write correctly rejected (unknown throw)" << std::endl;
        }

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

    std::cout << "=== Testing OPEN_R (read-only) mode ===" << std::endl;

    // Test MDSPLUS backend
    if (is_backend_available("mdsplus"))
    {
        total_status |= test_open_r_backend("mdsplus", "./test_db_mdsplus_test_open_r_mdsplus");
    }
    else
    {
        std::cout << "--- MDSPLUS backend not available, skipping ---" << std::endl;
    }

    // Test HDF5 backend
    if (is_backend_available("hdf5"))
    {
        total_status |= test_open_r_backend("hdf5", "./test_db_hdf5_test_open_r_hdf5");
    }
    else
    {
        std::cout << "--- HDF5 backend not available, skipping ---" << std::endl;
    }

    // Test ASCII backend
    total_status |= test_open_r_backend("ascii", "./test_db_ascii_test_open_r_ascii");

    if (total_status == 0)
        std::cout << "=== OPEN_R test PASSED (all available backends) ===" << std::endl;
    else
        std::cout << "=== OPEN_R test NOT PASSED ===" << std::endl;

    return total_status;
}
