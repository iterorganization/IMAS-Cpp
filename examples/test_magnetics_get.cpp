#include "ALClasses.h"

using namespace IdsNs;

int main(int argc, char *argv[])
{
  float time = 0.21;
  int interp = 2;
  int pulse = 54;
  int dynamicsize = 10;
  int staticsize = 3;
  char uri[]="imas:mdsplus?path=./test_db";
  char* userName = getenv("USER");
  if(userName == NULL) 
    {
      printf( "PANIC: $USER not found! Exiting...");
      exit(1);
    }

  ids.open(uri, OPEN_PULSE);

  std::cout << "getting full magnetics\n";
  ids._magnetics.get();

  int slices = ids._magnetics.time.size();
  int fl = ids._magnetics.flux_loop.size();
  std::cout << "nb of time slices = " << slices << std::endl;
  std::cout << "nb of flux_loop elements = " << fl << std::endl;

  for (int j=0; j<fl; j++)
    {
      int d = ids._magnetics.flux_loop(j).flux.data.size();
      std::cout << "nb of data slices for flux_loop(" << j 
		<< ") = " << d << std::endl;

      for (int i=0; i<d; i++)
	std::cout << "data(" << i << ") = " << ids._magnetics.flux_loop(j).flux.data(i) << std::endl;
    }

  std::cout << "get single slice of magnetics\n";
  ids._magnetics.getSlice(time, interp);
 
  std::cout << "time(0) = " << ids._magnetics.time(0) << std::endl;
  std::cout << "flux_loop(0).flux.data(0) = " << ids._magnetics.flux_loop(0).flux.data(0) << std::endl;

  ids.close();
 
}
