#include "ALClasses.h"
#include <iostream>
#include <cstdio>
#include <string>
#include <unistd.h>
#include <fcntl.h>

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

static int g_saved_out, g_saved_err;

void suppress_output() {
    std::cout.flush(); std::cerr.flush();
    g_saved_out = dup(STDOUT_FILENO);
    g_saved_err = dup(STDERR_FILENO);
    int devnull = open("/dev/null", O_WRONLY);
    dup2(devnull, STDOUT_FILENO);
    dup2(devnull, STDERR_FILENO);
    close(devnull);
}

void restore_output() {
    std::cout.flush(); std::cerr.flush();
    dup2(g_saved_out, STDOUT_FILENO);
    dup2(g_saved_err, STDERR_FILENO);
    close(g_saved_out); close(g_saved_err);
}

int test_open_rp_backend(const std::string& backend_name, const std::string& db_path) {
    int status = 0;
    std::string uri = "imas:" + backend_name + "?path=" + db_path;

    std::cout << "--- Testing OPEN_RP with " << backend_name << " backend ---" << std::endl;

    // Test A: Existing pulse - should succeed
    std::cout << "  Test A: Opening existing pulse" << std::endl;

    // Step 1: Create pulse and write time data only
    std::cout << "    Step 1: Creating pulse with time data (time=[0.0, 0.1, 0.2])..." << std::endl;
    {
        IdsNs::IDS ids;
        ids.open(uri.c_str(), FORCE_CREATE_PULSE);

        ids._magnetics.ids_properties.homogeneous_time = 1;
        ids._magnetics.time.resize(3);
        ids._magnetics.time(0) = 0.0;
        ids._magnetics.time(1) = 0.1;
        ids._magnetics.time(2) = 0.2;

        // Do not set flux_loop in this step
        ids._magnetics.put();
        ids.close();
        std::cout << "      Time data written" << std::endl;
    }

    // Step 2: Open in OPEN_RP mode and write flux_loop data (without overwriting time)
    std::cout << "    Step 2: Opening existing pulse in OPEN_RP mode and writing flux_loop data..." << std::endl;
    {
        IdsNs::IDS ids;
        int open_status = ids.open(uri.c_str(), OPEN_RP);
        
        if (open_status < 0)
        {
            std::cout << "      ISSUE: Could not open existing pulse with OPEN_RP (status=" << open_status << ")" << std::endl;
            status = 1;
        }
        else
        {
            std::cout << "      Successfully opened existing pulse" << std::endl;

            ids._magnetics.get();

            ids._magnetics.flux_loop.resize(2);
            ids._magnetics.flux_loop(0).flux.data.resize(3);
            ids._magnetics.flux_loop(0).flux.data(0) = 100.0;
            ids._magnetics.flux_loop(0).flux.data(1) = 101.0;
            ids._magnetics.flux_loop(0).flux.data(2) = 102.0;
            ids._magnetics.flux_loop(1).flux.data.resize(3);
            ids._magnetics.flux_loop(1).flux.data(0) = 200.0;
            ids._magnetics.flux_loop(1).flux.data(1) = 201.0;
            ids._magnetics.flux_loop(1).flux.data(2) = 202.0;

            ids._magnetics.put();
            ids.close();
            std::cout << "      Flux loop data written" << std::endl;
        }
    }

    // Step 3: Verify both time and flux_loop data exist (OPEN_RP preserves existing data)
    std::cout << "    Step 3: Verifying that both time and flux_loop data exist..." << std::endl;
    {
        IdsNs::IDS ids;
        ids.open(uri.c_str(), OPEN_R);

        ids._magnetics.get();
        
        // Verify time data
        int time_slices = ids._magnetics.time.size();
        std::cout << "      Found " << time_slices << " time slices" << std::endl;

        if (time_slices != 3)
        {
            std::cout << "      ISSUE: Expected 3 time slices, got " << time_slices << std::endl;
            std::cout << "      Data was overwritten instead of preserved" << std::endl;
            status = 1;
        }
        else
        {
            std::cout << "      Time values: ";
            for (int i = 0; i < time_slices; i++)
                std::cout << ids._magnetics.time(i) << " ";
            std::cout << std::endl;

            double expected_times[] = {0.0, 0.1, 0.2};
            for (int i = 0; i < 3; i++)
            {
                if (ids._magnetics.time(i) != expected_times[i])
                {
                    std::cout << "      ISSUE: Expected time[" << i << "]=" << expected_times[i] 
                              << ", got " << ids._magnetics.time(i) << std::endl;
                    status = 1;
                }
            }
        }

        // Verify flux_loop data
        int flux_loop_count = ids._magnetics.flux_loop.size();
        std::cout << "      Found " << flux_loop_count << " flux_loop elements" << std::endl;

        if (flux_loop_count != 2)
        {
            std::cout << "      ISSUE: Expected 2 flux_loop elements, got " << flux_loop_count << std::endl;
            status = 1;
        }
        else
        {
            std::cout << "      flux_loop(0).flux.data: ";
            for (int i = 0; i < ids._magnetics.flux_loop(0).flux.data.size(); i++)
                std::cout << ids._magnetics.flux_loop(0).flux.data(i) << " ";
            std::cout << std::endl;

            std::cout << "      flux_loop(1).flux.data: ";
            for (int i = 0; i < ids._magnetics.flux_loop(1).flux.data.size(); i++)
                std::cout << ids._magnetics.flux_loop(1).flux.data(i) << " ";
            std::cout << std::endl;

            // Verify flux_loop data values
            if (ids._magnetics.flux_loop(0).flux.data(0) != 100.0 ||
                ids._magnetics.flux_loop(0).flux.data(1) != 101.0 ||
                ids._magnetics.flux_loop(0).flux.data(2) != 102.0)
            {
                std::cout << "      ISSUE: flux_loop(0) data mismatch" << std::endl;
                status = 1;
            }
            if (ids._magnetics.flux_loop(1).flux.data(0) != 200.0 ||
                ids._magnetics.flux_loop(1).flux.data(1) != 201.0 ||
                ids._magnetics.flux_loop(1).flux.data(2) != 202.0)
            {
                std::cout << "      ISSUE: flux_loop(1) data mismatch" << std::endl;
                status = 1;
            }
        }

        if (status == 0)
            std::cout << "      Data correctly preserved (time from Step 1, flux_loop from Step 2)" << std::endl;

        ids.close();
    }

    // Test B: Non-existing pulse - should fail
    std::cout << "  Test B: Opening non-existing pulse" << std::endl;
    {
        std::string new_uri = "imas:" + backend_name + "?path=" + db_path + "_nonexistent";
        IdsNs::IDS ids;
        bool rejected = false;

        // Redirect stdout/stderr to suppress error output from IMAS-Core
        // The library prints "Error opening URI..." before throwing exception
        suppress_output();

        try
        {
            int open_status = ids.open(new_uri.c_str(), OPEN_RP);
            if (open_status < 0)
            {
                rejected = true;
            }
        }
        catch (const std::exception& e)
        {
            // Exception thrown as expected for non-existing pulse
            rejected = true;
        }
        catch (...)
        {
            // Unknown exception also counts as rejection
            rejected = true;
        }

        // Restore stdout/stderr
        restore_output();

        if (rejected)
        {
            std::cout << "    Correctly rejected non-existing pulse" << std::endl;
            std::cout << "    OPEN_RP correctly requires existing entry" << std::endl;
        }
        else
        {
            std::cout << "    ISSUE: OPEN_RP should reject non-existing pulse" << std::endl;
            status = 1;
            ids.close();
        }
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

    std::cout << "=== Testing OPEN_RP (read-protected / fail if not exists) mode ===" << std::endl;

    // Test MDSPLUS backend
    if (is_backend_available("mdsplus"))
    {
        total_status |= test_open_rp_backend("mdsplus", "./test_db_mdsplus_test_open_rp_mdsplus");
    }
    else
    {
        std::cout << "--- MDSPLUS backend not available, skipping ---" << std::endl;
    }

    // Test HDF5 backend
    if (is_backend_available("hdf5"))
    {
        total_status |= test_open_rp_backend("hdf5", "./test_db_hdf5_test_open_rp_hdf5");
    }
    else
    {
        std::cout << "--- HDF5 backend not available, skipping ---" << std::endl;
    }

    // Test ASCII backend
    total_status |= test_open_rp_backend("ascii", "./test_db_ascii_test_open_rp_ascii");

    if (total_status == 0)
        std::cout << "=== OPEN_RP test PASSED (all available backends) ===" << std::endl;
    else
        std::cout << "=== OPEN_RP test NOT PASSED ===" << std::endl;

    return total_status;
}
