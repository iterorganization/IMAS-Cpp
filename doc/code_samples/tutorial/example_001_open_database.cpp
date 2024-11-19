#include "ALClasses.h"
#include "example_001_open_database.h"
#include <string>
// If using C++ earlier than C++20, comment out the following include
// #include <format>
using namespace IdsNs;


// This example focuses on creating DBEntry using legacy mode method
void create_db_entry_legacy()
{

    std::string userName         = getenv("USER");
    std::string db_name          = "testdb";
    int pulse                    = 1;
    int run                      = 10;
    std::string dd_major_version = "3";

    // create data entry object (using legacy method, deprecated from AL5)
    IdsNs::IDS ids(pulse, run, 0, 0);
    ids.setBackend(HDF5_BACKEND);
    
    // this time we are creating completly new entry
    ids.createEnv(userName.c_str(), db_name.c_str(), dd_major_version.c_str());    
    // to open existing entry use ids.openEnv(userName, db_name, version)

    // You can access IDSes in here - take a look at sample code dealing with IDSes for details
    
    ids.close();
}

// This example focuses on opening DBEntry using URI
void open_db_entry_uri()
{

    std::string userName         = getenv("USER");
    std::string db_name          = "testdb";
    int pulse                    = 1;
    int run                      = 10;
    std::string backend          = "hdf5";
    std::string dd_major_version = "3";

    // std::string uri = std::format("imas:{}?user={};pulse={};run={};database={};version={}",backend, userName, pulse, run, db_name, version);

    // If you're using a C++ version older than C++20, make sure to use string concatenation instead of std::format.
    
    std::string uri = std::string("imas:")+backend + std::string("?user=") + userName + ";pulse=" + std::to_string(pulse)
    + ";run=" + std::to_string(run) + ";database=" + db_name + ";version=" + dd_major_version;
    

    IdsNs::IDS ids;
    int status = ids.open(uri.c_str(),FORCE_CREATE_PULSE);
    // Commonly used DBEntry modes are:
    //  OPEN_PULSE
    //  CREATE_PULSE
    //  FORCE_CREATE_PULSE

    // You can access IDSes in here - take a look at sample code dealing with IDSes for details

    ids.close();
}

// This example focuses on creating DBEntry using URI
void create_db_entry_uri_with_path()
{
    IdsNs::IDS ids;
    int status = ids.open("imas:mdsplus?path=./testdb_mdsplus",FORCE_CREATE_PULSE);
    // ls testdb_mdsplus
    // -> ids_001.characteristics  ids_001.datafile  ids_001.tree
    // Structure of this directory does not depends on entry content. All IDS data are stored in printed files
    
    status = ids.open("imas:hdf5?path=./testdb_hdf5",FORCE_CREATE_PULSE);
    // ls ./testdb_hdf5 
    // -> master.h5
    // Structure of this directory depends on entry content. Every IDS with data will be stored in <ids_name>.h5 file
    
    status = ids.open("imas:ascii?path=./testdb_ascii",FORCE_CREATE_PULSE);
    // ls ./testdb_ascii
    // -> {empty}
    // Structure of this directory depends on entry content. Every IDS with data will be stored in <ids_name>.ids file
}