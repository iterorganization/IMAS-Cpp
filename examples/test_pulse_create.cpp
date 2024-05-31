#include "ALClasses.h"
#include <string>
using namespace IdsNs;

int main(int argc, char **argv)
{
  std::string uri = "imas:mdsplus?path=./test_db_test_pulse_create";

  IdsNs::IDS ids;
  ids.open(uri, FORCE_CREATE_PULSE);

  ids.close();
}
