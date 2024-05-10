#include "ALClasses.h"

using namespace IdsNs;

int main(int argc, char *argv[])
{
  float time = 0.2;
  int dynamicsize = 10;
  int staticsize = 3;
  char uri[]="imas:mdsplus?path=./test_db_test_magnetics";

  IdsNs::IDS ids;
  ids.open(uri, FORCE_CREATE_PULSE);

  // set static data
  ids._magnetics.ids_properties.homogeneous_time = 1;

  // set dynamic data
  ids._magnetics.time.resize(dynamicsize);
  for (int i=0; i<dynamicsize; i++)
    ids._magnetics.time(i) = 0.1*i;

  ids._magnetics.flux_loop.resize(staticsize);
  for (int j=0; j<staticsize; j++)
    {
      ids._magnetics.flux_loop(j).flux.data.resize(dynamicsize);
      for (int i=0; i<dynamicsize; i++)
	  ids._magnetics.flux_loop(j).flux.data(i) = j*100.0+i;
    }

  std::cout << "putting magnetics\n"; 
  ids._magnetics.put();

  ids.close();
  
}
