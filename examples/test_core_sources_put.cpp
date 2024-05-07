#include "ALClasses.h"

using namespace IdsNs;


int main(int argc, char **argv)
{
  int pulse=12,
    run = 2,
    refpulse = 0,
    refrun = 0;
  int i,j,k,l;
  int s=2, t=12;
  char uri[]="imas:mdsplus?path=./test_db_test_core_sources_put";
  char *userName = getenv("USER");
  if (userName == NULL)
    {
      std::cerr << "PANIC: $USER not found! Exiting...\n";
      return 1;
    }
  
  // Define a first generic vector and its time base
  double* time = new double[t]; 
  double* vect1DDouble = new double[t];
  for (i=0; i<t; i++)
    {
      time[i]= 1.0 * i;
      vect1DDouble[i] = time[i]*10.0;
    }
  IdsNs::IDS ids;
  ids.open(uri, FORCE_CREATE_PULSE);

  // allocate the ids fields
  ids._core_sources.source.resize(s);
  ids._core_sources.time.resize(t);
  for (i=0; i<t; i++)
    ids._core_sources.time(i) = time[i];

  for (i=0; i<s; i++)
    {
      ids._core_sources.source(i).profiles_1d.resize(t);
      for (j=0; j<t; j++)
	{
	  ids._core_sources.source(i).profiles_1d(j).grid.rho_tor_norm.resize(j);
	  for (k=0; k<j; k++)
	    ids._core_sources.source(i).profiles_1d(j).grid.rho_tor_norm(k) = vect1DDouble[k];
	  ids._core_sources.source(i).profiles_1d(j).time = time[j];
	  ids._core_sources.source(i).profiles_1d(j).ion.resize(i);
	  for (k=0; k<i; k++)
	    {
	      ids._core_sources.source(i).profiles_1d(j).ion(k).z_ion = time[k];
	      ids._core_sources.source(i).profiles_1d(j).ion(k).particles.resize(j);
	      for (l=0; l<j; l++)
		ids._core_sources.source(i).profiles_1d(j).ion(k).particles(l) = 2*l+k;
	      ids._core_sources.source(i).profiles_1d(j).ion(k).state.resize(10);
	      for (l=0; l<10; l++)
		ids._core_sources.source(i).profiles_1d(j).ion(k).state(l).z_min = l;
	    }
	}
    }

  ids._core_sources.ids_properties.homogeneous_time = 1;
  ids._core_profiles.ids_properties.comment = "This is a test IDS in C++";

  std::cout << "Start Putting the core_profiles IDS\n";

  ids._core_sources.put();
  
  std::cout << "core_sources IDS pulse:" << pulse << " run:" << run << " saved\n";

  ids.close();
  
  delete[] time; 
  delete[] vect1DDouble;

  return 0;
}
