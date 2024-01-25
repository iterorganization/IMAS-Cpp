#include <iostream>
#include <cassert>

//Definition of the class structures in file ALClasses.h
#include "ALClasses.h"

using namespace IdsNs;

int main(int argc, char *argv[])
{
    IDS::core_profiles ids;
    bool isDefined = false;

    isDefined = ids.isDefined();
    std::cout << std::boolalpha << "Is IDS defined (should be 'false'): " << isDefined << std::endl;
    assert(isDefined == false);

    ids.ids_properties.homogeneous_time = IDS_TIME_MODE_HOMOGENEOUS; 
    ids.time.resize(1);
    ids.time(0) = 1.1;

    isDefined = ids.isDefined();
    std::cout << std::boolalpha << "Is IDS defined (should be 'true'): " << isDefined << std::endl;
    assert(isDefined == true);

    return 0;
}
