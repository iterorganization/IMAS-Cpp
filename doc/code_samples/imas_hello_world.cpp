// Include the Access Layer
#include "ALClasses.h"
#include <iostream>

// The Access Layer declares types in the IdsNs namespace. For brevity of
// examples we will use it here, even though it is considered bad practice:
// https://stackoverflow.com/questions/1452721/why-is-using-namespace-std-considered-bad-practice
using namespace IdsNs;

int main(int argc, char *argv[]) {
    std::cout << "Hello world!" << std::endl;
    std::cout << "Access Layer version info:" << std::endl;
    std::cout << "  Low level version: " << getALVersion() << std::endl;
    std::cout << "  Data Dictionary version: " << al_dd_version << std::endl;
    std::cout << "  C++ HLI version: " << al_cpp_version << std::endl;

    return 0;
}
