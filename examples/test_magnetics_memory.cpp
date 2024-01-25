#include "ALClasses.h"

using namespace IdsNs;

int main(int argc, char *argv[])
{
  float time = 0.21;
  int interp = 2;
  int pulse = 54;
  int dynamicsize = 10;
  int staticsize = 3;
  int pulsectx = -1;
  al_status_t al_status;
 
  char* userName = getenv("USER");
  if(userName == NULL) 
    {
      printf( "PANIC: $USER not found! Exiting...");
      exit(1);
    }
  char* uri;
  al_build_uri_from_legacy_parameters(MEMORY_BACKEND, pulse, 3, userName, "test", "3", "", &uri);
  al_status = al_begin_dataentry_action(uri, FORCE_CREATE_PULSE, &pulsectx);
  if (al_status.code) 
    {
      std::cerr << "Error occurred in calling al_begin_dataentry_action\n";
      exit(1);
    }

  IdsNs::IDS ids(pulsectx);

  // set static data
  ids._magnetics.ids_properties.homogeneous_time = 1;

  // set dynamic data
  ids._magnetics.time.resize(dynamicsize);
  for (int i=0; i<dynamicsize; i++)
    ids._magnetics.time(i) = 0.1*i;

  std::cout << ids._magnetics.time;
 
  ids._magnetics.flux_loop.resize(staticsize);
  for (int j=0; j<staticsize; j++)
    {
      ids._magnetics.flux_loop(j).flux.data.resize(dynamicsize);
      for (int i=0; i<dynamicsize; i++)
	  ids._magnetics.flux_loop(j).flux.data(i) = j*100.0+i;
    }
  
  std::cout << "putting magnetics\n"; 
  ids._magnetics.put();

  std::cout << "getting full magnetics\n";
  IdsNs::IDS ids2(pulsectx);
  ids2._magnetics.get();

  int slices = ids2._magnetics.time.size();
  int fl = ids2._magnetics.flux_loop.size();
  std::cout << "nb of time slices = " << slices << std::endl;
  std::cout << "nb of flux_loop elements = " << fl << std::endl;

  for (int j=0; j<fl; j++)
    {
      int d = ids2._magnetics.flux_loop(j).flux.data.size();
      std::cout << "nb of data slices for flux_loop(" << j 
		<< ") = " << d << std::endl;

      for (int i=0; i<d; i++)
	std::cout << "data(" << i << ") = " << ids2._magnetics.flux_loop(j).flux.data(i) << std::endl;
    }


  std::cout << "get single slice of magnetics\n";
  IdsNs::IDS ids3(pulsectx);
  ids3._magnetics.getSlice(time, interp);
 
  std::cout << "homogeneous_time = " << ids3._magnetics.ids_properties.homogeneous_time << std::endl;
  std::cout << "time(0) = " << ids3._magnetics.time(0) << std::endl;
  std::cout << "flux_loop(0).flux.data(0) = " << ids3._magnetics.flux_loop(0).flux.data(0) << std::endl;

  al_status = al_close_pulse(pulsectx, CLOSE_PULSE);
 
}
