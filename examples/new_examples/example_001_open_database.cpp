#include "ALClasses.h"

// If using C++ earlier than C++20, comment out the following include
#include <format>
using namespace IdsNs;

void example_001()
{

    // This example focuses on creating DBEntry using legacy mode method
    /*
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                            data entry parameters                             ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
    */

    char* userName      = getenv("USER");
    char db_name[]      = "test";
    int pulse           = 1;
    int run             = 10;
    char version[]      = "3";

    if(userName == NULL) 
    {
        printf( "PANIC: $USER not found! Exiting...");
        exit(1);
    }

    // create data entry object (using legacy method, deprecated from AL>=5.0.0)
    // Alternatively, we can open an IDS providing legacy arguments: (pulse, run, 0, 0)
    
    IdsNs::IDS ids(pulse, run, 0, 0);
    ids.setBackend(HDF5_BACKEND);
    
    // this time we are creating completly new entry
    
    ids.createEnv(userName, db_name, version);    
    
    //You can access IDSes in here - take a look at sample code dealing with IDSes for details
    
    ids.close();

}

void example_002()
{
    //This example focuses on opening DBEntry using uri created from legacy parameters
    /*
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                            data entry parameters                             ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
    */

    char* userName      = getenv("USER");
    char db_name[]      = "test";
    int pulse           = 1;
    int run             = 10;
    int backend_id      = HDF5_BACKEND;
    char version[]      = "3";
    char* uri;

    /*
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                          opening existing data entry                         ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
    */

    if(userName == NULL) 
    {
        printf( "PANIC: $USER not found! Exiting...");
        exit(1);
    }

    // usage of helper function to generate uri from legacy parameters
    
    al_build_uri_from_legacy_parameters(backend_id, pulse, run, userName, db_name, version, "",&uri);
    IdsNs::IDS ids;
    ids.open(uri,FORCE_CREATE_PULSE);

    // You can access IDSes in here - take a look at sample code dealing with IDSes for details

    ids.close();

}


void example_003()
{
    // This example focuses on opening DBEntry using URI
    /*
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                            data entry parameters                             ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
    */
    char* userName      = getenv("USER");
    std::string db_name = "test";
    int pulse           = 1;
    int run             = 10;
    char backend[]      = "hdf5";
    std::string version = "3";
   
   /*
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                          opening existing data entry                         ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
   */
   // If you're using a C++ version older than C++20, make sure to use this approach. 
   
    // std::string uri = std::string("imas:")+std::string(backend) + std::string("?user=") + std::string(userName) + ";pulse=" + std::to_string(pulse) 
    // + ";run=" + std::to_string(run) + ";database=" + std::string(db_name) + ";version=" + std::string(version);

    std::string uri = std::format("imas:{}?user={};pulse={};run={};database={};version={}",backend, userName, pulse, run, db_name, version);
    IdsNs::IDS ids;
    ids.open(uri.c_str(),FORCE_CREATE_PULSE);

    //You can access IDSes in here - take a look at sample code dealing with IDSes for details

    ids.close();

}

void example_004()
{
    // This example focuses on opening DBEntry using explicit path
    /*
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                          opening existing data entry                         ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
    */
    
    // example of uri with 'path' keyword
    std::string uri_with_path = "imas:hdf5?path=testdb";
    
    IdsNs::IDS ids;
    ids.open(uri_with_path.c_str(),FORCE_CREATE_PULSE);
    
    //You can access IDSes in here - take a look at sample code dealing with IDSes for details

    ids.close();

}

int main(int argc, char *argv[])
{
    example_001();
    example_002();
    example_003();
    example_004();
    return 0;
}