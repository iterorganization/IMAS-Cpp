#include <iostream>

//Definition of the class structures in file ALClasses.h
#include "ALClasses.h"
#include "al_const.h"

using namespace IdsNs;

int main(int argc, char *argv[])
{
    std::cout << "Lowlevel version: " << getALVersion() << std::endl;
    std::cout << "C++ HLI version: " << al_cpp_version << std::endl;
    std::cout << "Data dictionary version: " << al_dd_version << std::endl;
    return 0;
}
