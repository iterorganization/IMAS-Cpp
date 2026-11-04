#include "ALClasses.h"
#include <iostream>
#include <cstdio>
#include <string>
#include <filesystem>
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

int test_open_x_backend(const std::string& backend_name, const std::string& db_path) {
    int status = 0;
    std::string uri = "imas:" + backend_name + "?path=" + db_path;

    std::cout << "--- Testing OPEN_X with " << backend_name << " backend ---" << std::endl;

    // Test A: Existing pulse - should fail
    std::cout << "  Test A: Opening existing pulse (should fail)" << std::endl;

    // Step 1: Create pulse with initial data
    std::cout << "    Step 1: Creating pulse with initial data..." << std::endl;
    {
        IdsNs::IDS ids;
        ids.open(uri.c_str(), FORCE_CREATE_PULSE);

        ids._magnetics.ids_properties.homogeneous_time = 1;
        ids._magnetics.ids_properties.comment = "initial comment";
        ids._magnetics.time.resize(2);
        ids._magnetics.time(0) = 0.0;
        ids._magnetics.time(1) = 0.1;

        ids._magnetics.put();
        ids.close();
        std::cout << "      Initial data written" << std::endl;
    }

    // Step 2: Try to open in OPEN_X mode (should fail because entry exists)
    std::cout << "    Step 2: Attempting to open existing pulse in OPEN_X mode..." << std::endl;
    {
        IdsNs::IDS ids;
        bool failed_as_expected = false;

        // Redirect stdout/stderr to suppress error output from IMAS-Core
        suppress_output();

        try
        {
            int open_status = ids.open(uri.c_str(), OPEN_X);
            if (open_status < 0)
            {
                failed_as_expected = true;
            }
        }
        catch (const std::exception& e)
        {
            // Exception thrown as expected for existing pulse
            failed_as_expected = true;
        }
        catch (...)
        {
            // Unknown exception also counts as failure
            failed_as_expected = true;
        }

        // Restore stdout/stderr
        restore_output();

        if (failed_as_expected)
        {
            std::cout << "      Correctly rejected existing pulse" << std::endl;
            std::cout << "      OPEN_X correctly requires non-existing entry" << std::endl;
        }
        else
        {
            std::cout << "      ISSUE: OPEN_X should reject existing pulse" << std::endl;
            status = 1;
            ids.close();
        }
    }

    // Test B: Non-existing pulse - should succeed
    std::cout << "  Test B: Opening non-existing pulse (should succeed)" << std::endl;

    // Step 1: Open non-existing entry in OPEN_X mode and write data
    std::cout << "    Step 1: Opening non-existing pulse in OPEN_X mode and writing data..." << std::endl;
    {
        std::string new_uri = "imas:" + backend_name + "?path=" + db_path + "_new_2";
        IdsNs::IDS ids;
        int open_status = ids.open(new_uri.c_str(), OPEN_X);

        if (open_status < 0)
        {
            std::cout << "      ISSUE: OPEN_X failed to create new entry (status=" << open_status << ")" << std::endl;
            status = 1;
        }
        else
        {
            std::cout << "      Successfully opened non-existing pulse" << std::endl;

            ids._magnetics.ids_properties.homogeneous_time = 1;
            ids._magnetics.ids_properties.name = "open_x_test";
            ids._magnetics.time.resize(3);
            ids._magnetics.time(0) = 1.0;
            ids._magnetics.time(1) = 1.1;
            ids._magnetics.time(2) = 1.2;

            ids._magnetics.flux_loop.resize(1);
            ids._magnetics.flux_loop(0).flux.data.resize(3);
            ids._magnetics.flux_loop(0).flux.data(0) = 100.0;
            ids._magnetics.flux_loop(0).flux.data(1) = 101.0;
            ids._magnetics.flux_loop(0).flux.data(2) = 102.0;

            ids._magnetics.put();
            ids.close();
            std::cout << "      Data written successfully" << std::endl;
        }
    }

    // Step 2: Verify data was written correctly
    std::cout << "    Step 2: Verifying data was written correctly..." << std::endl;
    {
        std::string new_uri = "imas:" + backend_name + "?path=" + db_path + "_new_2";
        IdsNs::IDS ids;
        ids.open(new_uri.c_str(), OPEN_R);

        ids._magnetics.get();

        // Verify ids_properties.name
        std::cout << "      ids_properties.name: '" << ids._magnetics.ids_properties.name << "'" << std::endl;
        if (ids._magnetics.ids_properties.name != "open_x_test")
        {
            std::cout << "      ISSUE: Expected name='open_x_test', got '" << ids._magnetics.ids_properties.name << "'" << std::endl;
            status = 1;
        }

        // Verify time data
        int time_slices = ids._magnetics.time.size();
        std::cout << "      Found " << time_slices << " time slices" << std::endl;

        if (time_slices != 3)
        {
            std::cout << "      ISSUE: Expected 3 time slices, got " << time_slices << std::endl;
            status = 1;
        }
        else
        {
            double expected_times[] = {1.0, 1.1, 1.2};
            for (int i = 0; i < 3; i++)
            {
                if (ids._magnetics.time(i) != expected_times[i])
                {
                    std::cout << "      ISSUE: Expected time[" << i << "]=" << expected_times[i]
                              << ", got " << ids._magnetics.time(i) << std::endl;
                    status = 1;
                }
            }
            std::cout << "      Time values correctly written" << std::endl;
        }

        // Verify flux_loop data
        int flux_loop_count = ids._magnetics.flux_loop.size();
        std::cout << "      Found " << flux_loop_count << " flux_loop elements" << std::endl;

        if (flux_loop_count != 1)
        {
            std::cout << "      ISSUE: Expected 1 flux_loop element, got " << flux_loop_count << std::endl;
            status = 1;
        }
        else
        {
            std::cout << "      flux_loop(0).flux.data: ";
            for (int i = 0; i < ids._magnetics.flux_loop(0).flux.data.size(); i++)
                std::cout << ids._magnetics.flux_loop(0).flux.data(i) << " ";
            std::cout << std::endl;

            if (ids._magnetics.flux_loop(0).flux.data(0) != 100.0 ||
                ids._magnetics.flux_loop(0).flux.data(2) != 102.0)
            {
                std::cout << "      ISSUE: flux_loop data mismatch" << std::endl;
                status = 1;
            }
            else
            {
                std::cout << "      Flux loop data correctly written" << std::endl;
            }
        }

        ids.close();
    }

    // Test C: Try to open the same entry again with OPEN_X (should fail)
    std::cout << "  Test C: Re-opening same entry in OPEN_X mode (should fail)" << std::endl;
    {
        std::string new_uri = "imas:" + backend_name + "?path=" + db_path + "_new_2";
        IdsNs::IDS ids;
        bool failed_as_expected = false;

        // Redirect stdout/stderr to suppress error output from IMAS-Core
        suppress_output();

        try
        {
            int open_status = ids.open(new_uri.c_str(), OPEN_X);
            if (open_status < 0)
            {
                failed_as_expected = true;
            }
        }
        catch (const std::exception& e)
        {
            failed_as_expected = true;
        }
        catch (...)
        {
            failed_as_expected = true;
        }

        // Restore stdout/stderr
        restore_output();

        if (failed_as_expected)
        {
            std::cout << "    Correctly rejected already existing entry" << std::endl;
        }
        else
        {
            std::cout << "    ISSUE: OPEN_X should reject entry created in Test B" << std::endl;
            status = 1;
            ids.close();
        }
    }

    if (status == 0)
        std::cout << "  " << backend_name << " backend: PASSED" << std::endl;
    else
        std::cout << "  " << backend_name << " backend: NOT PASSED" << std::endl;

    // Cleanup test databases
    try {
        std::filesystem::remove_all(db_path);
        std::filesystem::remove_all(db_path + "_new_2");
    } catch (const std::filesystem::filesystem_error& e) {
        std::cerr << "Warning: Cleanup failed: " << e.what() << std::endl;
    }

    return status;
}

int main(int argc, char *argv[])
{
    int total_status = 0;

    std::cout << "=== Testing OPEN_X (write + fail if exists) mode ===" << std::endl;

    // Test MDSPLUS backend
    if (is_backend_available("mdsplus"))
    {
        total_status |= test_open_x_backend("mdsplus", "./test_db_mdsplus_test_open_x_mdsplus");
    }
    else
    {
        std::cout << "--- MDSPLUS backend not available, skipping ---" << std::endl;
    }

    // Test HDF5 backend
    if (is_backend_available("hdf5"))
    {
        total_status |= test_open_x_backend("hdf5", "./test_db_hdf5_test_open_x_hdf5");
    }
    else
    {
        std::cout << "--- HDF5 backend not available, skipping ---" << std::endl;
    }

    // Test ASCII backend
    total_status |= test_open_x_backend("ascii", "./test_db_ascii_test_open_x_ascii");

    if (total_status == 0)
        std::cout << "=== OPEN_X test PASSED (all available backends) ===" << std::endl;
    else
        std::cout << "=== OPEN_X test NOT PASSED ===" << std::endl;

    return total_status;
}
