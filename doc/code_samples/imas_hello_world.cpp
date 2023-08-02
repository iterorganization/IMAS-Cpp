// Include the Access Layer
#include "UALClasses.h"
#include <iostream>

// The Access Layer declares types in the IdsNs namespace. For brevity of
// examples we will use it here, even though it is considered bad practice:
// https://stackoverflow.com/questions/1452721/why-is-using-namespace-std-considered-bad-practice
using namespace IdsNs;

int main(int argc, char *argv[]) {
    std::cout << "Hello world!" << std::endl;
    std::cout << "Using access layer version: " << UAL_VERSION;
    std::cout << " with data dictionary version: " << DD_VERSION << std::endl;

    return 0;
}
