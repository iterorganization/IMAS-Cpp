#include <iostream>
#include <string>
#include <cassert>
#include <vector>

// Include the generated coordinate_identifier header
// Assuming it's in the build directory or proper include path
#include "coordinate_identifier.h"

// Test function for basic identifier operations
void test_basic_operations() {
    std::cout << "Testing basic identifier operations..." << std::endl;
    
    // Test get_index
    int index_x = coordinate_identifier::get_index("x");
    assert(index_x == 1);
    std::cout << "✓ get_index('x') = " << index_x << std::endl;
    
    int index_phi = coordinate_identifier::get_index("phi");
    assert(index_phi == 5);
    std::cout << "✓ get_index('phi') = " << index_phi << std::endl;
    
    int index_unknown = coordinate_identifier::get_index("unknown_coord");
    assert(index_unknown == -999999999);
    std::cout << "✓ get_index('unknown_coord') = " << index_unknown << " (expected for unknown)" << std::endl;
    
    // Test get_name
    std::string name_1 = coordinate_identifier::get_name(1);
    assert(name_1 == "x");
    std::cout << "✓ get_name(1) = '" << name_1 << "'" << std::endl;
    
    std::string name_5 = coordinate_identifier::get_name(5);
    assert(name_5 == "phi");
    std::cout << "✓ get_name(5) = '" << name_5 << "'" << std::endl;
    
    std::string name_unknown = coordinate_identifier::get_name(9999);
    assert(name_unknown == "unknown");
    std::cout << "✓ get_name(9999) = '" << name_unknown << "' (expected for unknown)" << std::endl;
    
    // Test get_description
    std::string desc_1 = coordinate_identifier::get_description(1);
    assert(desc_1 == "First cartesian coordinate in the horizontal plane");
    std::cout << "✓ get_description(1) = '" << desc_1 << "'" << std::endl;
    
    std::string desc_unknown = coordinate_identifier::get_description(9999);
    assert(desc_unknown == "unknown");
    std::cout << "✓ get_description(9999) = '" << desc_unknown << "' (expected for unknown)" << std::endl;
}

// Test function for get_type_data_by_name
void test_get_type_data_by_name() {
    std::cout << "\nTesting get_type_data_by_name..." << std::endl;
    
    int index;
    std::string description;
    
    // Test with known identifier
    bool found = coordinate_identifier::get_type_data_by_name("x", index, description);
    assert(found == true);
    assert(index == 1);
    assert(description == "First cartesian coordinate in the horizontal plane");
    std::cout << "✓ get_type_data_by_name('x') -> index=" << index 
              << ", description='" << description << "'" << std::endl;
    
    // Test with another known identifier
    found = coordinate_identifier::get_type_data_by_name("velocity_parallel", index, description);
    assert(found == true);
    assert(index == 105);
    assert(description == "Velocity component parallel to the magnetic field");
    std::cout << "✓ get_type_data_by_name('velocity_parallel') -> index=" << index 
              << ", description='" << description << "'" << std::endl;
    
    // Test with unknown identifier
    found = coordinate_identifier::get_type_data_by_name("unknown_coord", index, description);
    assert(found == false);
    assert(index == -999999999);
    assert(description == "unknown");
    std::cout << "✓ get_type_data_by_name('unknown_coord') -> found=" << found 
              << ", index=" << index << ", description='" << description << "'" << std::endl;
}

// Test function for template set_identifier
void test_template_set_identifier() {
    std::cout << "\nTesting template set_identifier..." << std::endl;
    
    // Define a simple test class with required members
    struct TestIdentifier {
        int index;
        std::string name;
        std::string description;
        
        TestIdentifier() : index(-999999999), name(""), description("") {}
    };
    
    // Test with known identifier
    TestIdentifier data1;
    coordinate_identifier::set_identifier(data1, "phi");
    
    assert(data1.index == 5);
    assert(data1.name == "phi");
    assert(data1.description == "Toroidal angle");
    
    std::cout << "✓ set_identifier with 'phi':" << std::endl;
    std::cout << "  index: " << data1.index << std::endl;
    std::cout << "  name: '" << data1.name << "'" << std::endl;
    std::cout << "  description: '" << data1.description << "'" << std::endl;
    
    // Test with unknown identifier
    TestIdentifier data2;
    coordinate_identifier::set_identifier(data2, "nonexistent");
    
    assert(data2.index == -999999999);
    assert(data2.name == "nonexistent");
    assert(data2.description == "unknown");
    
    std::cout << "✓ set_identifier with 'nonexistent':" << std::endl;
    std::cout << "  index: " << data2.index << std::endl;
    std::cout << "  name: '" << data2.name << "'" << std::endl;
    std::cout << "  description: '" << data2.description << "'" << std::endl;
    
    // Test with another known identifier
    TestIdentifier data3;
    coordinate_identifier::set_identifier(data3, "energy_kinetic");
    
    assert(data3.index == 301);
    assert(data3.name == "energy_kinetic");
    assert(data3.description == "Kinetic energy");
    
    std::cout << "✓ set_identifier with 'energy_kinetic':" << std::endl;
    std::cout << "  index: " << data3.index << std::endl;
    std::cout << "  name: '" << data3.name << "'" << std::endl;
    std::cout << "  description: '" << data3.description << "'" << std::endl;
}

// Test function for comprehensive identifier testing
void test_comprehensive_identifiers() {
    std::cout << "\nTesting comprehensive identifier list..." << std::endl;
    
    // Define a simple test class with required members
    struct TestIdentifier {
        int index;
        std::string name;
        std::string description;
        
        TestIdentifier() : index(-999999999), name(""), description("") {}
    };
    
    // Test a selection of identifiers
    std::vector<std::pair<std::string, int>> test_cases = {
        {"unspecified", 0},
        {"x", 1},
        {"y", 2},
        {"z", 3},
        {"r", 4},
        {"phi", 5},
        {"psi", 10},
        {"rho_tor", 11},
        {"theta", 20},
        {"velocity", 100},
        {"momentum", 200},
        {"energy_hamiltonian", 300},
        {"lambda", 400},
        {"n_phi", 500}
    };
    
    for (const auto& test_case : test_cases) {
        const std::string& name = test_case.first;
        int expected_index = test_case.second;
        
        // Test get_index
        int actual_index = coordinate_identifier::get_index(name);
        assert(actual_index == expected_index);
        
        // Test get_name
        std::string actual_name = coordinate_identifier::get_name(expected_index);
        assert(actual_name == name);
        
        // Test get_type_data_by_name
        int index;
        std::string description;
        bool found = coordinate_identifier::get_type_data_by_name(name, index, description);
        assert(found == true);
        assert(index == expected_index);
        
        // Test set_identifier
        TestIdentifier data;
        coordinate_identifier::set_identifier(data, name);
        assert(data.index == expected_index);
        assert(data.name == name);
        assert(!data.description.empty());
        
        std::cout << "✓ " << name << " (index: " << expected_index << ") - all functions work correctly" << std::endl;
    }
}

int main() {
    std::cout << "=== Coordinate Identifier Test Program ===" << std::endl;
    
    try {
        test_basic_operations();
        test_get_type_data_by_name();
        test_template_set_identifier();
        test_comprehensive_identifiers();
        
        std::cout << "\n=== All tests passed! ✓ ===" << std::endl;
        std::cout << "The identifier system is working correctly." << std::endl;
        
    } catch (const std::exception& e) {
        std::cerr << "\n Test failed with exception: " << e.what() << std::endl;
        return 1;
    } catch (...) {
        std::cerr << "\n Test failed with unknown exception!" << std::endl;
        return 1;
    }
    
    return 0;
}
