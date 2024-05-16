#include "ALClasses.h"

using namespace IdsNs;


int main(int argc, char **argv)
{
  int i,j,k,l,ni,nj,nk,nl;
  char uri[]="imas:mdsplus?path=./test_db_test_core_sources";

  IdsNs::IDS ids;
  ids.open(uri, OPEN_PULSE);

  std::cout << "core_sources IDS opened\n";

  std::cout << "ids_properties.homogeneous_time = " << ids._core_sources.ids_properties.homogeneous_time << "\n";
  std::cout << "ids_properties.comment = " << ids._core_sources.ids_properties.comment << "\n";
  
  ni = ids._core_sources.source.extent(0);
  std::cout << "number of sources = " << ni << "\n";

  for (i=0; i<ni; i++)
    {
      nj = ids._core_sources.source(i).profiles_1d.extent(0);
      std::cout << "source(" << i << ").profiles_1d size = " << nj << "\n";
      for (j=0; j<nj; j++)
	{
	  std::cout << "profiles_1d(" << j << ").time = " << ids._core_sources.source(i).profiles_1d(j).time<< "\n";
	  nk = ids._core_sources.source(i).profiles_1d(j).grid.rho_tor_norm.extent(0);
	  std::cout << "profiles_1d(" << j << ").grid.rho_tor_norm = ";
	  for (k=0; k<nk; k++)
	    std::cout << ids._core_sources.source(i).profiles_1d(j).grid.rho_tor_norm << " ";
	  std::cout << "\n";

	  nk = ids._core_sources.source(i).profiles_1d(j).ion.extent(0);
	  std::cout << "profiles_1d(" << j << ").ion size = " << nk << "\n";
	  for (k=0; k<nk; k++)
	    {
	      nl = ids._core_sources.source(i).profiles_1d(j).ion(k).state.extent(0);
	      for (l=0; l<nl; l++)
		std::cout << "profiles_1(" << j << ").ion(" << k << ").state(" << l << ").z_min = " << ids._core_sources.source(i).profiles_1d(j).ion(k).state(l).z_min << "\n";
	    }
	}
    }
  
  ids.close();

  return 0;
}
