#include "ALClasses.h"

// If using C++ earlier than C++20, comment out the following include
#include <format>
using namespace IdsNs;

void create_db_entry_legacy()
{

    // This example focuses on creating DBEntry using legacy mode method

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
    IdsNs::IDS ids(pulse, run, 0, 0);
    ids.setBackend(HDF5_BACKEND);
    
    // this time we are creating completly new entry
    ids.createEnv(userName, db_name, version);    
    // to open existing entry use ids.openEnv(userName, db_name, version)

    //You can access IDSes in here - take a look at sample code dealing with IDSes for details
    
    ids.close();

}

void open_db_entry_uri()
{
    // This example focuses on opening DBEntry using URI

    char* userName      = getenv("USER");
    std::string db_name = "test";
    int pulse           = 1;
    int run             = 10;
    char backend[]      = "hdf5";
    std::string version = "3";

    if(userName == NULL)
    {
        printf( "PANIC: $USER not found! Exiting...");
        exit(1);
    }

    std::string uri = std::format("imas:{}?user={};pulse={};run={};database={};version={}",backend, userName, pulse, run, db_name, version);

    // If you're using a C++ version older than C++20, make sure to use string concatenation instead of std::format.
    /*
        std::string uri = std::string("imas:")+std::string(backend) + std::string("?user=") + std::string(userName) + ";pulse=" + std::to_string(pulse)
        + ";run=" + std::to_string(run) + ";database=" + std::string(db_name) + ";version=" + std::string(version);
    */

    IdsNs::IDS ids;
    int status = ids.open(uri.c_str(),FORCE_CREATE_PULSE);
    // Commonly used DBEntry modes are:
    //  OPEN_PULSE
    //  CREATE_PULSE
    //  FORCE_CREATE_PULSE

    if (status != 0)
    {
        printf( "PANIC: Could not create pulsefile");
        exit(1);
    }

    //You can access IDSes in here - take a look at sample code dealing with IDSes for details

    ids.close();

}

void create_db_entry_uri_with_path()
{
    // This example focuses on opening DBEntry using explicit path
    
    // example of uri with 'path' keyword
    std::string uri_with_path = "imas:hdf5?path=testdb";
    
    IdsNs::IDS ids;
    ids.open(uri_with_path.c_str(),FORCE_CREATE_PULSE);
    
    //You can access IDSes in here - take a look at sample code dealing with IDSes for details

    ids.close();

}

int main(int argc, char *argv[])
{
    create_db_entry_legacy();
    open_db_entry_uri();
    create_db_entry_uri_with_path();
    return 0;
}