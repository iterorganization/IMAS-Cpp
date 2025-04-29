#include <stdlib.h>
#include "ALClasses.h"
#include <blitz/array.h>
#include <vector>
#include <string>
#include <cmath>
#include <iostream>

using namespace blitz;
using namespace IdsNs;

void save_data(const char* uri);
void display_data(IDS::core_profiles &ids);
void exitIfError(al_status_t &status);

// Structure to hold assertion results
struct Assertion {
    bool passed;
    std::string description;
};

// Utility function to check array sizes in a range
std::vector<Assertion> checkArraySizeInRange(IdsNs::Ids &ids, int start, int end, 
                                             const std::string &array_path, int expected_size, 
                                             const std::string &ids_name) {
    std::vector<Assertion> assertions;
    if (ids_name == "core_profiles") {
        IDS::core_profiles *core_profiles = dynamic_cast<IDS::core_profiles*>(&ids);
        if (!core_profiles) {
            assertions.push_back({false, "Failed to cast Ids to core_profiles for " + array_path});
            return assertions;
        }
        for (int i = start; i <= end; ++i) {
            if (i >= core_profiles->profiles_1d.size()) {
                assertions.push_back({false, "Index " + std::to_string(i) + " out of bounds for " + array_path});
                continue;
            }
            int actual_size = 0;
            if (array_path == "profiles_1d.ion") {
                actual_size = core_profiles->profiles_1d(i).ion.size();
            } else if (array_path == "profiles_1d.ion.state") {
                // Skip for now, handled in specific tests
                continue;
            } else {
                assertions.push_back({false, "Unsupported array path: " + array_path});
                continue;
            }
            bool passed = (actual_size == expected_size);
            std::string desc = array_path + "(" + std::to_string(i) + ").size() == " + 
                              std::to_string(expected_size);
            assertions.push_back({passed, desc});
        }
    } else {
        assertions.push_back({false, "Unsupported IDS type: " + ids_name});
    }
    return assertions;
}

// Utility function to check path values in a range
std::vector<Assertion> checkPathValuesInRange(IdsNs::Ids &ids, int start, int end, 
                                              const std::string &path, double expected_value, 
                                              const std::string &ids_name, bool is_time = false) {
    std::vector<Assertion> assertions;
    double epsilon = std::numeric_limits<double>::epsilon();
    if (ids_name == "core_profiles") {
        IDS::core_profiles *core_profiles = dynamic_cast<IDS::core_profiles*>(&ids);
        if (!core_profiles) {
            assertions.push_back({false, "Failed to cast Ids to core_profiles for " + path});
            return assertions;
        }
        for (int i = start; i <= end; ++i) {
            if (i >= core_profiles->profiles_1d.size()) {
                assertions.push_back({false, "Index " + std::to_string(i) + " out of bounds for " + path});
                continue;
            }
            bool passed = false;
            std::string desc;
            if (path == "profiles_1d.time") {
                double actual = core_profiles->profiles_1d(i).time;
                double expected = is_time ? (double)(i) + 1.0 : expected_value;
                passed = std::abs(actual - expected) < epsilon;
                desc = path + "(" + std::to_string(i) + ") == " + std::to_string(expected);
            } else if (path == "profiles_1d.ion.state.z_min") {
                // Handled in specific tests
                continue;
            } else {
                assertions.push_back({false, "Unsupported path: " + path});
                continue;
            }
            assertions.push_back({passed, desc});
        }
    } else {
        assertions.push_back({false, "Unsupported IDS type: " + ids_name});
    }
    return assertions;
}

// Utility function to check if a value is uninitialized (value == -9e40)
std::vector<Assertion> checkUninitializedInRange(IdsNs::Ids &ids, int start, int end, 
                                                 const std::string &path, const std::string &ids_name) {
    std::vector<Assertion> assertions;
    double epsilon = std::numeric_limits<double>::epsilon();
    if (ids_name == "core_profiles") {
        IDS::core_profiles *core_profiles = dynamic_cast<IDS::core_profiles*>(&ids);
        if (!core_profiles) {
            assertions.push_back({false, "Failed to cast Ids to core_profiles for " + path});
            return assertions;
        }
        for (int i = start; i <= end; ++i) {
            if (i >= core_profiles->profiles_1d.size()) {
                assertions.push_back({false, "Index " + std::to_string(i) + " out of bounds for " + path});
                continue;
            }
            bool passed = false;
            std::string desc;
            if (path == "profiles_1d.time") {
                double actual = core_profiles->profiles_1d(i).time;
                passed = std::abs(actual + 9e40) < epsilon;
                desc = path + "(" + std::to_string(i) + ") is uninitialized";
            } else {
                assertions.push_back({false, "Unsupported path: " + path});
                continue;
            }
            assertions.push_back({passed, desc});
        }
    } else {
        assertions.push_back({false, "Unsupported IDS type: " + ids_name});
    }
    return assertions;
}

// Utility function to add time assertions
void addTimeAssertions(std::vector<Assertion>& assertions, IdsNs::Ids &ids, 
                       int profile_idx, double expected_time, bool is_initialized, 
                       const std::string &ids_name) {
    double epsilon = std::numeric_limits<double>::epsilon();
    if (ids_name == "core_profiles") {
        IDS::core_profiles *core_profiles = dynamic_cast<IDS::core_profiles*>(&ids);
        if (!core_profiles) {
            assertions.push_back({false, "Failed to cast Ids to core_profiles for time assertions"});
            return;
        }
        if (is_initialized) {
            assertions.push_back({
                std::abs(core_profiles->profiles_1d(profile_idx).time - expected_time) < epsilon,
                "profiles_1d(" + std::to_string(profile_idx) + ").time == " + 
                std::to_string(expected_time)
            });
        } else {
            assertions.push_back({
                std::abs(core_profiles->profiles_1d(profile_idx).time + 9e40) < epsilon,
                "profiles_1d(" + std::to_string(profile_idx) + ").time is uninitialized"
            });
        }
    } else {
        assertions.push_back({false, "Unsupported IDS type: " + ids_name});
    }
}

// Utility function to run a test and collect assertions
bool runTest(int test_number, const std::string &request, const std::string &exclude, 
             IDS::core_profiles &ids, const std::vector<Assertion> &assertions) {
    
    bool all_passed = true;
    for (size_t i = 0; i < assertions.size(); ++i) {
        if (!assertions[i].passed) {
            all_passed = false;
            std::cout << "Assertion #" << i << " failed for test " << test_number 
                      << " (request=" << request << "): " << assertions[i].description << std::endl;
        }
    }
    std::cout << "Partial plugin test " << test_number << " completed with " 
              << assertions.size() << " assertions." << std::endl;
    return all_passed;
}

// Utility function to add some specific assertions
void addSpecificAssertions(std::vector<Assertion>& assertions, IdsNs::Ids &ids, 
                        int profile_idx, int ion_idx, size_t expected_size, 
                        const std::string &ids_name,
                        const std::vector<std::pair<int, int>>& z_min_checks = {}) {
    if (ids_name == "core_profiles") {
        IDS::core_profiles *core_profiles = dynamic_cast<IDS::core_profiles*>(&ids);
        if (!core_profiles) {
            assertions.push_back({false, "Failed to cast Ids to core_profiles for state assertions"});
            return;
        }
        assertions.push_back({
            core_profiles->profiles_1d(profile_idx).ion(ion_idx).state.size() == expected_size,
            "profiles_1d(" + std::to_string(profile_idx) + ").ion(" + std::to_string(ion_idx) + 
            ").state.size() == " + std::to_string(expected_size)
        });
        for (const auto& [state_idx, z_min] : z_min_checks) {
            assertions.push_back({
                core_profiles->profiles_1d(profile_idx).ion(ion_idx).state(state_idx).z_min == z_min,
                "profiles_1d(" + std::to_string(profile_idx) + ").ion(" + std::to_string(ion_idx) + 
                ").state(" + std::to_string(state_idx) + ").z_min == " + std::to_string(z_min)
            });
        }
    } else {
        assertions.push_back({false, "Unsupported IDS type: " + ids_name});
    }
}

void execute(char** argv) {
    char uri[] = "imas:hdf5?path=./test_db_test_core_profiles";
    save_data(uri);
    IdsNs::IDS data_entry;

    data_entry.open(uri, OPEN_PULSE);
    IDS::core_profiles ids = data_entry._core_profiles;

    bool all_tests_passed = true;
    int test_index = 0;
    double epsilon = std::numeric_limits<double>::epsilon();

    // TEST 1: Check ids_properties
    {
        std::vector<Assertion> assertions;
        ids.partialGet("ids_properties", "");
        assertions.push_back({ids.ids_properties.comment.length() != 0, 
                             "ids_properties.comment.length() != 0"});
        assertions.push_back({ids.profiles_1d.size() == 0, "profiles_1d.size() == 0"});
        all_tests_passed &= runTest(++test_index, "ids_properties", "", ids, assertions);
    }

    // TEST 2: Check profiles_1d(:)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(:)", "");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        auto time_checks = checkPathValuesInRange(ids, 0, 9, "profiles_1d.time", 0, "core_profiles", true);
        assertions.insert(assertions.end(), time_checks.begin(), time_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(:)", "", ids, assertions);
    }

    // TEST 3: Check profiles_1d(1:5:1)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(1:5:1)", "");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        auto time_checks = checkPathValuesInRange(ids, 0, 4, "profiles_1d.time", 0, "core_profiles", true);
        auto uninit_checks = checkUninitializedInRange(ids, 5, 9, "profiles_1d.time", "core_profiles");
        assertions.insert(assertions.end(), time_checks.begin(), time_checks.end());
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(1:5:1)", "", ids, assertions);
    }

    // TEST 4: Check profiles_1d(1:5:1) with exclude profiles_1d(2)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(1:5:1)", "profiles_1d(2)");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        std::vector<std::tuple<int, double, bool>> time_checks = {
            {0, 1.0, true}, {1, 0.0, false}, {2, 3.0, true}, {3, 4.0, true}, {4, 5.0, true}
        };
        for (const auto& [idx, time, initialized] : time_checks) {
            addTimeAssertions(assertions, ids, idx, time, initialized, "core_profiles");
        }
        auto uninit_checks = checkUninitializedInRange(ids, 5, 9, "profiles_1d.time", "core_profiles");
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(1:5:1)", "profiles_1d(2)", ids, assertions);
    }

    // TEST 5: Check profiles_1d(:) with exclude profiles_1d(2)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(:)", "profiles_1d(2)");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        addTimeAssertions(assertions, ids, 0, 1.0, true, "core_profiles");
        addTimeAssertions(assertions, ids, 1, 0.0, false, "core_profiles");
        auto time_checks = checkPathValuesInRange(ids, 2, 9, "profiles_1d.time", 0, "core_profiles", true);
        assertions.insert(assertions.end(), time_checks.begin(), time_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(:)", "profiles_1d(2)", ids, assertions);
    }

    // TEST 6: Check ids_properties;profiles_1d(1:5:2) with exclude profiles_1d(2)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("ids_properties;profiles_1d(1:5:2)", "profiles_1d(2)");
        assertions.push_back({ids.ids_properties.comment.length() != 0, 
                             "ids_properties.comment.length() != 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        std::vector<std::tuple<int, double, bool>> time_checks = {
            {0, 1.0, true}, {1, 0.0, false}, {2, 3.0, true}, {3, 0.0, false}, {4, 5.0, true}
        };
        for (const auto& [idx, time, initialized] : time_checks) {
            addTimeAssertions(assertions, ids, idx, time, initialized, "core_profiles");
        }
        auto uninit_checks = checkUninitializedInRange(ids, 5, 9, "profiles_1d.time", "core_profiles");
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        all_tests_passed &= runTest(++test_index, "ids_properties;profiles_1d(1:5:2)", 
                                   "profiles_1d(2)", ids, assertions);
    }

    // TEST 7: Check profiles_1d(1:5:2)/ion(3)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(1:5:2)/ion(3)", "");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        std::vector<std::tuple<int, int, size_t>> ion_sizes = {
            {0, 0, 1}, {1, 0, 0}, {2, 0, 3}, {3, 0, 0}, {4, 0, 5}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : ion_sizes) {
            assertions.push_back({
                ids.profiles_1d(profile_idx).ion.size() == expected_size,
                "profiles_1d(" + std::to_string(profile_idx) + ").ion.size() == " + 
                std::to_string(expected_size)
            });
        }
        std::vector<std::tuple<int, int, size_t>> state_checks = {
            {0, 0, 0}, {2, 0, 0}, {2, 1, 0}, {2, 2, 10}, 
            {4, 0, 0}, {4, 1, 0}, {4, 2, 10}, {4, 3, 0}, {4, 4, 0}
        };
        std::map<std::pair<int, int>, std::vector<std::pair<int, int>>> z_min_checks = {
            {{2, 2}, {{5, 5}, {6, 6}}},
            {{4, 2}, {{5, 5}, {6, 6}}}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : state_checks) {
            addSpecificAssertions(assertions, ids, profile_idx, ion_idx, expected_size, 
                              "core_profiles", z_min_checks[{profile_idx, ion_idx}]);
        }
        auto uninit_checks = checkUninitializedInRange(ids, 0, 9, "profiles_1d.time", "core_profiles");
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(1:5:2)/ion(3)", "", ids, assertions);
    }

    // TEST 8: Check profiles_1d(1:5:2)/ion(3);profiles_1d(1:5:2)/ion(1)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(1:5:2)/ion(3);profiles_1d(1:5:2)/ion(1)", "");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        auto ion_sizes = checkArraySizeInRange(ids, 0, 4, "profiles_1d.ion", 0, "core_profiles");
        ion_sizes[0].passed = ids.profiles_1d(0).ion.size() == 1;
        ion_sizes[0].description = "profiles_1d(0).ion.size() == 1";
        ion_sizes[2].passed = ids.profiles_1d(2).ion.size() == 3;
        ion_sizes[2].description = "profiles_1d(2).ion.size() == 3";
        ion_sizes[4].passed = ids.profiles_1d(4).ion.size() == 5;
        ion_sizes[4].description = "profiles_1d(4).ion.size() == 5";
        assertions.insert(assertions.end(), ion_sizes.begin(), ion_sizes.end());
        std::vector<std::tuple<int, int, size_t>> state_checks = {
            {0, 0, 10}, {2, 0, 10}, {2, 1, 0}, {2, 2, 10}, 
            {4, 0, 10}, {4, 1, 0}, {4, 2, 10}, {4, 3, 0}, {4, 4, 0}
        };
        std::map<std::pair<int, int>, std::vector<std::pair<int, int>>> z_min_checks = {
            {{2, 2}, {{5, 5}, {6, 6}}},
            {{4, 2}, {{5, 5}, {6, 6}}}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : state_checks) {
            addSpecificAssertions(assertions, ids, profile_idx, ion_idx, expected_size, 
                              "core_profiles", z_min_checks[{profile_idx, ion_idx}]);
        }
        auto uninit_checks = checkUninitializedInRange(ids, 0, 9, "profiles_1d.time", "core_profiles");
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(1:5:2)/ion(3);profiles_1d(1:5:2)/ion(1)", 
                                   "", ids, assertions);
    }

    // TEST 9: Check profiles_1d(1:5:2)/ion(3);profiles_1d(1:5:2)/time
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(1:5:2)/ion(3);profiles_1d(1:5:2)/time", "");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        auto ion_sizes = checkArraySizeInRange(ids, 0, 4, "profiles_1d.ion", 0, "core_profiles");
        ion_sizes[0].passed = ids.profiles_1d(0).ion.size() == 1;
        ion_sizes[2].passed = ids.profiles_1d(2).ion.size() == 3;
        ion_sizes[4].passed = ids.profiles_1d(4).ion.size() == 5;
        assertions.insert(assertions.end(), ion_sizes.begin(), ion_sizes.end());
        std::vector<std::tuple<int, int, size_t>> state_checks = {
            {0, 0, 0}, {2, 0, 0}, {2, 1, 0}, {2, 2, 10}, 
            {4, 0, 0}, {4, 1, 0}, {4, 2, 10}, {4, 3, 0}, {4, 4, 0}
        };
        std::map<std::pair<int, int>, std::vector<std::pair<int, int>>> z_min_checks = {
            {{2, 2}, {{5, 5}, {6, 6}}},
            {{4, 2}, {{5, 5}, {6, 6}}}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : state_checks) {
            addSpecificAssertions(assertions, ids, profile_idx, ion_idx, expected_size, 
                              "core_profiles", z_min_checks[{profile_idx, ion_idx}]);
        }
        std::vector<std::tuple<int, double, bool>> time_checks = {
            {0, 1.0, true}, {2, 3.0, true}, {4, 5.0, true}, 
            {1, 0.0, false}, {3, 0.0, false}, {5, 0.0, false}, {6, 0.0, false}
        };
        for (const auto& [idx, time, initialized] : time_checks) {
            addTimeAssertions(assertions, ids, idx, time, initialized, "core_profiles");
        }
        auto uninit_checks = checkUninitializedInRange(ids, 7, 9, "profiles_1d.time", "core_profiles");
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(1:5:2)/ion(3);profiles_1d(1:5:2)/time", 
                                   "", ids, assertions);
    }

    // TEST 10: Check ids_properties;profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time
    {
        std::vector<Assertion> assertions;
        ids.partialGet("ids_properties;profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time", "");
        assertions.push_back({ids.ids_properties.comment.length() != 0, 
                             "ids_properties.comment.length() != 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        std::vector<std::tuple<int, int, size_t>> ion_sizes = {
            {0, 0, 1}, {1, 0, 2}, {2, 0, 3}, {3, 0, 4}, {4, 0, 5}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : ion_sizes) {
            assertions.push_back({
                ids.profiles_1d(profile_idx).ion.size() == expected_size,
                "profiles_1d(" + std::to_string(profile_idx) + ").ion.size() == " + 
                std::to_string(expected_size)
            });
        }
        auto ion_sizes_rest = checkArraySizeInRange(ids, 5, 9, "profiles_1d.ion", 0, "core_profiles");
        assertions.insert(assertions.end(), ion_sizes_rest.begin(), ion_sizes_rest.end());
        auto time_checks = checkPathValuesInRange(ids, 0, 9, "profiles_1d.time", 0, "core_profiles", true);
        assertions.insert(assertions.end(), time_checks.begin(), time_checks.end());
        all_tests_passed &= runTest(++test_index, 
                                   "ids_properties;profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time", 
                                   "", ids, assertions);
    }

    // TEST 11: Check ids_properties;profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time with exclude
    {
        std::vector<Assertion> assertions;
        ids.partialGet("ids_properties;profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time", 
                      "profiles_1d(2:3:1);profiles_1d(5)/ion(1)");
        assertions.push_back({ids.ids_properties.comment.length() != 0, 
                             "ids_properties.comment.length() != 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        std::vector<std::tuple<int, int, size_t>> ion_sizes = {
            {0, 0, 1}, {1, 0, 0}, {2, 0, 0}, {3, 0, 4}, {4, 0, 5}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : ion_sizes) {
            assertions.push_back({
                ids.profiles_1d(profile_idx).ion.size() == expected_size,
                "profiles_1d(" + std::to_string(profile_idx) + ").ion.size() == " + 
                std::to_string(expected_size)
            });
        }
        std::vector<std::tuple<int, double, bool>> time_checks = {
            {0, 1.0, true}, {3, 4.0, true}, {4, 5.0, true}, {5, 6.0, true}, {6, 7.0, true},
            {1, 0.0, false}, {2, 0.0, false}
        };
        for (const auto& [idx, time, initialized] : time_checks) {
            addTimeAssertions(assertions, ids, idx, time, initialized, "core_profiles");
        }
        assertions.push_back({
            ids.profiles_1d(3).ion(0).state(5).z_min == 5,
            "profiles_1d(3).ion(0).state(5).z_min == 5"
        });
        assertions.push_back({
            ids.profiles_1d(3).ion(0).state(6).z_min == 6,
            "profiles_1d(3).ion(0).state(6).z_min == 6"
        });
        assertions.push_back({
            ids.profiles_1d(4).ion(0).state.size() == 0,
            "profiles_1d(4).ion(0).state.size() == 0"
        });
        all_tests_passed &= runTest(++test_index, 
                                   "ids_properties;profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time", 
                                   "profiles_1d(2:3:1);profiles_1d(5)/ion(1)", ids, assertions);
    }

    // TEST 12: Check empty request
    {
        std::vector<Assertion> assertions;
        ids.partialGet("", "");
        assertions.push_back({ids.ids_properties.comment.length() != 0, 
                             "ids_properties.comment.length() != 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        auto time_checks = checkPathValuesInRange(ids, 0, 9, "profiles_1d.time", 0, "core_profiles", true);
        assertions.insert(assertions.end(), time_checks.begin(), time_checks.end());
        all_tests_passed &= runTest(++test_index, "", "", ids, assertions);
    }

    // TEST 13: Check profiles_1d(1:5:2)/ion(:);profiles_1d(1:5:2)/time
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(1:5:2)/ion(:);profiles_1d(1:5:2)/time", "");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        auto ion_sizes = checkArraySizeInRange(ids, 0, 4, "profiles_1d.ion", 0, "core_profiles");
        ion_sizes[0].passed = ids.profiles_1d(0).ion.size() == 1;
        ion_sizes[2].passed = ids.profiles_1d(2).ion.size() == 3;
        ion_sizes[4].passed = ids.profiles_1d(4).ion.size() == 5;
        assertions.insert(assertions.end(), ion_sizes.begin(), ion_sizes.end());
        std::vector<std::tuple<int, int, size_t>> state_checks = {
            {0, 0, 10}, {2, 0, 10}, {2, 1, 10}, {2, 2, 10}, 
            {4, 0, 10}, {4, 1, 10}, {4, 2, 10}, {4, 3, 10}, {4, 4, 10}
        };
        std::map<std::pair<int, int>, std::vector<std::pair<int, int>>> z_min_checks = {
            {{4, 2}, {{5, 5}, {6, 6}}},
            {{4, 3}, {{5, 5}, {6, 6}}}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : state_checks) {
            addSpecificAssertions(assertions, ids, profile_idx, ion_idx, expected_size, 
                              "core_profiles", z_min_checks[{profile_idx, ion_idx}]);
        }
        std::vector<std::tuple<int, double, bool>> time_checks = {
            {0, 1.0, true}, {2, 3.0, true}, {4, 5.0, true}, 
            {3, 0.0, false}, {5, 0.0, false}, {6, 0.0, false}
        };
        for (const auto& [idx, time, initialized] : time_checks) {
            addTimeAssertions(assertions, ids, idx, time, initialized, "core_profiles");
        }
        auto uninit_checks = checkUninitializedInRange(ids, 7, 9, "profiles_1d.time", "core_profiles");
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(1:5:2)/ion(:);profiles_1d(1:5:2)/time", 
                                   "", ids, assertions);
    }

    // TEST 14: Check profiles_1d(:) with exclude profiles_1d(:)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(:)", "profiles_1d(:)");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 0, "profiles_1d.size() == 0"});
        all_tests_passed &= runTest(++test_index, "profiles_1d(:)", "profiles_1d(:)", ids, assertions);
    }

    // TEST 15: Check profiles_1d(1:5)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(1:5)", "");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        auto time_checks = checkPathValuesInRange(ids, 0, 4, "profiles_1d.time", 0, "core_profiles", true);
        auto uninit_checks = checkUninitializedInRange(ids, 5, 9, "profiles_1d.time", "core_profiles");
        assertions.insert(assertions.end(), time_checks.begin(), time_checks.end());
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(1:5)", "", ids, assertions);
    }

    // TEST 16: Check profiles_1d(1:5) with exclude profiles_1d(1:2)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(1:5)", "profiles_1d(1:2)");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        auto time_checks = checkPathValuesInRange(ids, 2, 4, "profiles_1d.time", 0, "core_profiles", true);
        auto uninit_checks = checkUninitializedInRange(ids, 0, 1, "profiles_1d.time", "core_profiles");
        auto uninit_checks_5_9 = checkUninitializedInRange(ids, 5, 9, "profiles_1d.time", "core_profiles");
        uninit_checks.insert(uninit_checks.end(), uninit_checks_5_9.begin(), uninit_checks_5_9.end());
        assertions.insert(assertions.end(), time_checks.begin(), time_checks.end());
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(1:5)", "profiles_1d(1:2)", ids, assertions);
    }

    // TEST 17: Check profiles_1d(::2)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(::2)", "");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        for (int i = 0; i < 5; ++i) {
            addTimeAssertions(assertions, ids, 2*i, (double)(2*i) + 1.0, true, "core_profiles");
            addTimeAssertions(assertions, ids, 2*i+1, 0.0, false, "core_profiles");
        }
        all_tests_passed &= runTest(++test_index, "profiles_1d(::2)", "", ids, assertions);
    }

    // TEST 18: Check profiles_1d(:3)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(:3)", "");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        auto time_checks = checkPathValuesInRange(ids, 0, 2, "profiles_1d.time", 0, "core_profiles", true);
        auto uninit_checks = checkUninitializedInRange(ids, 3, 9, "profiles_1d.time", "core_profiles");
        assertions.insert(assertions.end(), time_checks.begin(), time_checks.end());
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(:3)", "", ids, assertions);
    }

    // TEST 19: Check profiles_1d(4:)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(4:)", "");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        auto uninit_checks = checkUninitializedInRange(ids, 0, 2, "profiles_1d.time", "core_profiles");
        auto time_checks = checkPathValuesInRange(ids, 3, 9, "profiles_1d.time", 0, "core_profiles", true);
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        assertions.insert(assertions.end(), time_checks.begin(), time_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(4:)", "", ids, assertions);
    }

    // TEST 20: Check profiles_1d(1:5) with exclude profiles_1d(3)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(1:5)", "profiles_1d(3)");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        std::vector<std::tuple<int, double, bool>> time_checks = {
            {0, 1.0, true}, {1, 2.0, true}, {2, 0.0, false}, {3, 4.0, true}, {4, 5.0, true}
        };
        for (const auto& [idx, time, initialized] : time_checks) {
            addTimeAssertions(assertions, ids, idx, time, initialized, "core_profiles");
        }
        auto uninit_checks = checkUninitializedInRange(ids, 5, 9, "profiles_1d.time", "core_profiles");
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(1:5)", "profiles_1d(3)", ids, assertions);
    }

    // TEST 21: Check profiles_1d(:) with exclude profiles_1d(1:2)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(:)", "profiles_1d(1:2)");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        std::vector<std::tuple<int, double, bool>> time_checks = {
            {0, 0.0, false}, {1, 0.0, false}, {2, 3.0, true}, {3, 4.0, true}, 
            {4, 5.0, true}, {5, 6.0, true}, {6, 7.0, true}, {7, 8.0, true}, 
            {8, 9.0, true}, {9, 10.0, true}
        };
        for (const auto& [idx, time, initialized] : time_checks) {
            addTimeAssertions(assertions, ids, idx, time, initialized, "core_profiles");
        }
        all_tests_passed &= runTest(++test_index, "profiles_1d(:)", "profiles_1d(1:2)", ids, assertions);
    }

    // TEST 22: Check profiles_1d(1:5:2)/ion(3) with exclude profiles_1d(5)/ion(3)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(1:5:2)/ion(3)", "profiles_1d(5)/ion(3)");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        std::vector<std::tuple<int, int, size_t>> ion_sizes = {
            {0, 0, 1}, {1, 0, 0}, {2, 0, 3}, {3, 0, 0}, {4, 0, 0}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : ion_sizes) {
            assertions.push_back({
                ids.profiles_1d(profile_idx).ion.size() == expected_size,
                "profiles_1d(" + std::to_string(profile_idx) + ").ion.size() == " + 
                std::to_string(expected_size)
            });
        }
        assertions.push_back({ids.profiles_1d(4).ion.size() == 0, "profiles_1d(4).ion(0).size() == 0"});
        std::vector<std::tuple<int, int, size_t>> state_checks = {
            {0, 0, 0}, {2, 0, 0}, {2, 1, 0}, {2, 2, 10}
        };
        std::map<std::pair<int, int>, std::vector<std::pair<int, int>>> z_min_checks = {
            {{2, 2}, {{5, 5}, {6, 6}}}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : state_checks) {
            addSpecificAssertions(assertions, ids, profile_idx, ion_idx, expected_size, 
                              "core_profiles", z_min_checks[{profile_idx, ion_idx}]);
        }
        auto uninit_checks = checkUninitializedInRange(ids, 0, 9, "profiles_1d.time", "core_profiles");
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(1:5:2)/ion(3)", "profiles_1d(5)/ion(3)", ids, assertions);
    }

    // TEST 23: Check profiles_1d(1:5:1)/ion(1:4:2) with exclude profiles_1d(3)/ion(1)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(1:5:1)/ion(1:4:2)", "profiles_1d(3)/ion(1)");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        std::vector<std::tuple<int, int, size_t>> ion_sizes = {
            {0, 0, 1}, {1, 0, 2}, {2, 0, 3}, {3, 0, 4}, {4, 0, 5}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : ion_sizes) {
            assertions.push_back({
                ids.profiles_1d(profile_idx).ion.size() == expected_size,
                "profiles_1d(" + std::to_string(profile_idx) + ").ion.size() == " + 
                std::to_string(expected_size)
            });
        }
        std::vector<std::tuple<int, int, size_t>> state_checks = {
            {2, 0, 0}, {2, 1, 0}, 
            {4, 0, 10}, {4, 1, 0}, {4, 2, 10}, {4, 3, 0}, {4, 4, 0}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : state_checks) {
            addSpecificAssertions(assertions, ids, profile_idx, ion_idx, expected_size, "core_profiles");
        }
        auto uninit_checks = checkUninitializedInRange(ids, 0, 9, "profiles_1d.time", "core_profiles");
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(1:5:1)/ion(1:4:2)", "profiles_1d(3)/ion(1)", ids, assertions);
    }

    // TEST 24: Check profiles_1d(:)/time with exclude profiles_1d(3:5)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(:)/time", "profiles_1d(3:5)");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        std::vector<std::tuple<int, double, bool>> time_checks = {
            {0, 1.0, true}, {1, 2.0, true}, {2, 0.0, false}, {3, 0.0, false}, 
            {4, 0.0, false}, {5, 6.0, true}, {6, 7.0, true}, {7, 8.0, true}, 
            {8, 9.0, true}, {9, 10.0, true}
        };
        for (const auto& [idx, time, initialized] : time_checks) {
            addTimeAssertions(assertions, ids, idx, time, initialized, "core_profiles");
        }
        all_tests_passed &= runTest(++test_index, "profiles_1d(:)/time", "profiles_1d(3:5)", ids, assertions);
    }

    // TEST 25: Check ids_properties;profiles_1d(1:5:2) with exclude profiles_1d(1:3:2)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("ids_properties;profiles_1d(1:5:2)", "profiles_1d(1:3:2)");
        assertions.push_back({ids.ids_properties.comment.length() != 0, 
                             "ids_properties.comment.length() != 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        std::vector<std::tuple<int, double, bool>> time_checks = {
            {0, 0.0, false}, {1, 0.0, false}, {2, 0.0, false}, {3, 0.0, false}, 
            {4, 5.0, true}
        };
        for (const auto& [idx, time, initialized] : time_checks) {
            addTimeAssertions(assertions, ids, idx, time, initialized, "core_profiles");
        }
        auto uninit_checks = checkUninitializedInRange(ids, 5, 9, "profiles_1d.time", "core_profiles");
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        all_tests_passed &= runTest(++test_index, "ids_properties;profiles_1d(1:5:2)", 
                                   "profiles_1d(1:3:2)", ids, assertions);
    }

    // TEST 26: Check profiles_1d(1:5:2)/ion(:) with exclude profiles_1d(3)/ion(2)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(1:5:2)/ion(:)", "profiles_1d(3)/ion(2)");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        std::vector<std::tuple<int, int, size_t>> ion_sizes = {
            {0, 0, 1}, {1, 0, 0}, {2, 0, 3}, {3, 0, 0}, {4, 0, 5}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : ion_sizes) {
            assertions.push_back({
                ids.profiles_1d(profile_idx).ion.size() == expected_size,
                "profiles_1d(" + std::to_string(profile_idx) + ").ion.size() == " + 
                std::to_string(expected_size)
            });
        }
        std::vector<std::tuple<int, int, size_t>> state_checks = {
            {0, 0, 10}, {2, 0, 10}, {2, 1, 0}, 
            {4, 0, 10}, {4, 1, 10}, {4, 2, 10}, {4, 3, 10}, {4, 4, 10}
        };
        std::map<std::pair<int, int>, std::vector<std::pair<int, int>>> z_min_checks = {
            {{4, 2}, {{5, 5}, {6, 6}}},
            {{4, 3}, {{5, 5}, {6, 6}}}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : state_checks) {
            addSpecificAssertions(assertions, ids, profile_idx, ion_idx, expected_size, 
                              "core_profiles", z_min_checks[{profile_idx, ion_idx}]);
        }
        auto uninit_checks = checkUninitializedInRange(ids, 0, 9, "profiles_1d.time", "core_profiles");
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(1:5:2)/ion(:)", "profiles_1d(3)/ion(2)", ids, assertions);
    }

    // TEST 27: Check profiles_1d(::2)/time with exclude profiles_1d(4)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(::2)/time", "profiles_1d(4)");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        std::vector<std::tuple<int, double, bool>> time_checks = {
            {0, 1.0, true}, {1, 0.0, false}, {2, 3.0, true}, {3, 0.0, false}, 
            {4, 5.0, true}, {5, 0.0, false}, {6, 7.0, true}, {7, 0.0, false}, 
            {8, 9.0, true}, {9, 0.0, false}
        };
        for (const auto& [idx, time, initialized] : time_checks) {
            addTimeAssertions(assertions, ids, idx, time, initialized, "core_profiles");
        }
        all_tests_passed &= runTest(++test_index, "profiles_1d(::2)/time", "profiles_1d(4)", ids, assertions);
    }

    // TEST 28: Check profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time with exclude profiles_1d(5:6)/ion(3)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time", "profiles_1d(5:6)/ion(3)");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        std::vector<std::tuple<int, int, size_t>> ion_sizes = {
            {0, 0, 1}, {1, 0, 2}, {2, 0, 3}, {3, 0, 4}, {4, 0, 5}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : ion_sizes) {
            assertions.push_back({
                ids.profiles_1d(profile_idx).ion.size() == expected_size,
                "profiles_1d(" + std::to_string(profile_idx) + ").ion.size() == " + 
                std::to_string(expected_size)
            });
        }
        auto ion_sizes_rest = checkArraySizeInRange(ids, 5, 9, "profiles_1d.ion", 0, "core_profiles");
        assertions.insert(assertions.end(), ion_sizes_rest.begin(), ion_sizes_rest.end());
        auto time_checks = checkPathValuesInRange(ids, 0, 9, "profiles_1d.time", 0, "core_profiles", true);
        assertions.insert(assertions.end(), time_checks.begin(), time_checks.end());
        std::vector<std::tuple<int, int, size_t>> state_checks = {
            {4, 0, 10}, {4, 1, 0}, {4, 2, 0}, {4, 3, 0}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : state_checks) {
            addSpecificAssertions(assertions, ids, profile_idx, ion_idx, expected_size, "core_profiles");
        }
        all_tests_passed &= runTest(++test_index, 
                                   "profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time", 
                                   "profiles_1d(5:6)/ion(3)", ids, assertions);
    }

    // TEST 29: Check profiles_1d(:3)/ion(2) with exclude profiles_1d(2)/ion(2)
    {
        std::vector<Assertion> assertions;
        ids.partialGet("profiles_1d(:3)/ion(2)", "profiles_1d(2)/ion(2)");
        assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        std::vector<std::tuple<int, int, size_t>> ion_sizes = {
            {0, 0, 1}, {1, 0, 0}, {2, 0, 3}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : ion_sizes) {
            assertions.push_back({
                ids.profiles_1d(profile_idx).ion.size() == expected_size,
                "profiles_1d(" + std::to_string(profile_idx) + ").ion.size() == " + 
                std::to_string(expected_size)
            });
        }
        std::vector<std::tuple<int, int, size_t>> state_checks = {
            {0, 1, 0}, {2, 1, 10}
        };
        std::map<std::pair<int, int>, std::vector<std::pair<int, int>>> z_min_checks = {
            {{2, 2}, {{5, 5}, {6, 6}}}
        };
        for (const auto& [profile_idx, ion_idx, expected_size] : state_checks) {
            addSpecificAssertions(assertions, ids, profile_idx, ion_idx, expected_size, 
                              "core_profiles", z_min_checks[{profile_idx, ion_idx}]);
        }
        auto uninit_checks = checkUninitializedInRange(ids, 0, 9, "profiles_1d.time", "core_profiles");
        assertions.insert(assertions.end(), uninit_checks.begin(), uninit_checks.end());
        all_tests_passed &= runTest(++test_index, "profiles_1d(:3)/ion(2)", "profiles_1d(2)/ion(2)", ids, assertions);
    }

    // TEST 30: Check profiles_1d() (expecting ALPluginException)
    {
        std::vector<Assertion> assertions;
        bool exception_caught = false;
        
        int status = ids.partialGet("profiles_1d()", "");
        exception_caught = (status < 0);
        assertions.push_back({
            exception_caught,
            exception_caught ? "ALPluginException caught as expected for profiles_1d()" 
                             : "Expected ALPluginException not thrown for profiles_1d()"
        });
        all_tests_passed &= runTest(++test_index, "profiles_1d()", "", ids, assertions);
    }

    // TEST 31: Check profiles_1d() (expecting ALPluginException)
    {
        std::vector<Assertion> assertions;
        bool exception_caught = false;
        
        int status = ids.partialGet("profiles_1d("")", "");
        exception_caught = (status < 0);
        assertions.push_back({
            exception_caught,
            exception_caught ? "ALPluginException caught as expected for profiles_1d()" 
                             : "Expected ALPluginException not thrown for profiles_1d()"
        });
        all_tests_passed &= runTest(++test_index, "profiles_1d("")", "", ids, assertions);
    }

    // TEST 32: Check profiles_1d(-1) (expecting ALPluginException)
    {
        std::vector<Assertion> assertions;
        bool exception_caught = false;
        
        int status = ids.partialGet("profiles_1d(-1)", "");
        exception_caught = (status < 0);
        assertions.push_back({
            exception_caught,
            exception_caught ? "ALPluginException caught as expected for profiles_1d()" 
                             : "Expected ALPluginException not thrown for profiles_1d()"
        });
        all_tests_passed &= runTest(++test_index, "profiles_1d(-1)", "", ids, assertions);
    }

    // TEST 33: Check profiles_1d(9999) (expecting no data at all from profiles_1d, only allocated)
    {
        std::vector<Assertion> assertions;
        bool exception_caught = false;
        
        int status = ids.partialGet("profiles_1d(9999)", "");
         assertions.push_back({ids.ids_properties.comment.length() == 0, 
                             "ids_properties.comment.length() == 0"});
        assertions.push_back({ids.profiles_1d.size() == 10, "profiles_1d.size() == 10"});
        std::vector<std::tuple<int, double, bool>> time_checks = {
            {0, 1.0, false}, {1, 2.0, false}, {2, 3.0, false}, {3, 4.0, false}, 
            {4, 5.0, false}, {5, 6.0, false}, {6, 7.0, false}, {7, 8.0, false}, 
            {8, 9.0, false}, {9, 10.0, false}
        };
        for (const auto& [idx, time, initialized] : time_checks) {
            addTimeAssertions(assertions, ids, idx, time, initialized, "core_profiles");
        }

        all_tests_passed &= runTest(++test_index, "profiles_1d(9999)", "", ids, assertions);
    }

    std::cout << "----------------------------------------\n\n";
    if (all_tests_passed) {
        std::cout << "Partial get plugin tests successful.\n";
        exit(0);
    } else {
        std::cout << "ERROR: Partial get plugin tests have failed.\n";
        exit(-1);
    }

    data_entry.close();
}

// Keep existing functions unchanged
void exitIfError(al_status_t &status) {
    if (status.code != 0) {
        printf("%s\n", status.message);
        exit(-1);
    }
}

void display_data(IDS::core_profiles &ids) {
    printf("ids_properties= comment:%s, Homogeneous:%d\n",
           ids.ids_properties.comment.c_str(),
           ids.ids_properties.homogeneous_time);

    int nb = ids.profiles_1d.extent(0);
    printf("profiles_1d.time:");
    for (int j = 0; j < nb; j++)
        printf(" %g", ids.profiles_1d(j).time);
    puts("");

    nb = ids.time.extent(0);
    printf("Main IDS time:");
    for (int j = 0; j < nb; j++)
        printf(" %g", ids.time(j));
    puts("");

    nb = ids.global_quantities.ip.extent(0);
    printf("Ip:");
    for (int j = 0; j < nb; j++)
        printf(" %g", ids.global_quantities.ip(j));
    puts("");

    for (int i = 0; i < ids.profiles_1d.size(); i++) {
        printf("\ntime_slice i=%g\n", ids.profiles_1d(i).time);
        printf("rho= ");
        for (int j = 0; j < ids.profiles_1d(i).grid.rho_tor_norm.size(); j++)
            printf(" %g", ids.profiles_1d(i).grid.rho_tor_norm(j));
        puts("");

        printf("List of ion masses at time i=%d = ", i);
        for (int j = 0; j < ids.profiles_1d(i).ion.extent(0); j++)
            printf(" %g", ids.profiles_1d(i).ion(j).z_ion);
        puts("");

        for (int j = 0; j < ids.profiles_1d(i).ion.size(); j++) {
            printf("Ni for ion j=%d at time i=%d:", j, i);
            for (int k = 0; k < ids.profiles_1d(i).ion(j).density.extent(0); k++)
                printf(" %g", ids.profiles_1d(i).ion(j).density(k));
            puts("");
            printf("List of charge states for ion j=%d at time i=%d: (%d)", j, i, 
                   ids.profiles_1d(i).ion(j).state.extent(0));
            for (int k = 0; k < ids.profiles_1d(i).ion(j).state.extent(0); k++)
                printf(" %g", ids.profiles_1d(i).ion(j).state(k).z_min);
            puts("");
        }
    }
}

void save_data(const char* uri) {
  IdsNs::IDS data_entry;
  data_entry.open(uri, FORCE_CREATE_PULSE);
  IDS::core_profiles ids = data_entry._core_profiles;
  double  vect1DDouble_1[10], vect1DDouble_2[12];
  int number = 10; //number of elements
  int pulse = 12,
    run = 2,
    refpulse = 0,
    refrun = 0,
    i,j, Sz,idx;

  //The parameters passed to this creator define the pulse and run number. The second pair of arguments defines the reference pulse and run
  //and is used when the a new database is created, as in this example.
  //All the AL classes belong to the idsNs namespace
  //

  //! Define a first generic vector and its time base
  double time_1[] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0};
  for (i=0; i<10;i++)
    vect1DDouble_1[i] = time_1[i]*10;

  //! Define a second generic vector
  double time_2[] = {11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0};
  for (i=0; i<12;i++)
    vect1DDouble_2[i] = time_2[i]*2.+10.;

  //! allocate the ids fields
  //printf("SIZE %d %d \n",sizeof(time_1), sizeof(time_1)/sizeof(time_1[0]));
  Sz= sizeof(time_1)/sizeof(time_1[0]);
  ids.profiles_1d.resize(Sz);
  printf("Completed allocation of %d profiles_1d\n", Sz);
  //
  for(i=0; i < Sz; i++) {
    //! Varies the size of the array of structure children with time index
    ids.profiles_1d(i).grid.rho_tor_norm.resize(i+1);
    for (j=0; j<=i;j++)
      ids.profiles_1d(i).grid.rho_tor_norm(j) = vect1DDouble_1[j];
    ids.profiles_1d(i).time = time_1[i];

    ids.profiles_1d(i).ion.resize(i+1);
    // ! Test nested arrays of structure (type 2 AoS below a type 3), varying also the size of the nested AoS
    for (j=0;j<= i; j++) {
      ids.profiles_1d(i).ion(j).z_ion = time_1[j];
      // ! Fixed radial grid size = 3, for ion #j of time slice #i (already quite complicated)
      ids.profiles_1d(i).ion(j).density.resize(i+1);
      for (int k=0; k<=i; k++)
	ids.profiles_1d(i).ion(j).density(k) = vect1DDouble_1[k]+j;
      //   Test 3rd level of nested arrays of structure (type 2 AoS below a type 2 AoS below a type 3)
      ids.profiles_1d(i).ion(j).state.resize(10);
      for (int k=0; k<10; k++)
        ids.profiles_1d(i).ion(j).state(k).z_min = k;
    }
  }
  printf("Completed filling of profiles_1d fields\n");
  //! Fill the ids fields with data
  ids.ids_properties.homogeneous_time = 0; //! Mandatory to define this property
  ids.ids_properties.comment = "Testing the partial get plugin";
  ids.global_quantities.ip.resize(sizeof(time_2)/sizeof(time_2)[0]);
  for(int ii=0; ii < sizeof(time_2)/sizeof(time_2[0]); ii++)
    ids.global_quantities.ip(ii) = vect1DDouble_2[ii];

  ids.time.resize(sizeof(time_2)/sizeof(time_2[0]));
  for (j=0;j< sizeof(time_2)/sizeof(time_2[0]); j++)
    ids.time(j)=time_2[j];

  printf("\nStart Putting the core_profiles IDS\n");

  ids.put();
  printf("core_profiles IDS pulse:%d, run:%d, refpulse:%d, refrun:%d saved\n", pulse, run, refpulse, refrun);
  data_entry.close();

} 

int main(int argc, char** argv) {
    execute(argv);
    return 0;
}