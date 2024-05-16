#include "ALClasses.h"

using namespace IdsNs;


int main(int argc, char **argv)
{
  int i,j,k,l;
  int s=2, t=12;
  bool first_slice = true;
  char uri[]="imas:mdsplus?path=./test_db_test_core_sources";

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

  ids._core_sources.ids_properties.homogeneous_time = 1;
  ids._core_sources.ids_properties.comment = "This is a test IDS in C++";

  ids._core_sources.time.resize(1);


  for (i=0; i<s; i++)
    {
      ids._core_sources.source(i).profiles_1d.resize(1);
      ids._core_sources.source(i).profiles_1d(0).ion.resize(i);

      // time loop
      for (j=0; j<t; j++)
	{
	  ids._core_sources.time = time[j];
	  ids._core_sources.source(i).profiles_1d(0).grid.rho_tor_norm.resize(j);
	  for (k=0; k<j; k++)
	    ids._core_sources.source(i).profiles_1d(0).grid.rho_tor_norm(k) = vect1DDouble[k];
	  ids._core_sources.source(i).profiles_1d(0).time = time[j];
	  for (k=0; k<i; k++)
	    {
	      ids._core_sources.source(i).profiles_1d(0).ion(k).z_ion = time[k];
	      ids._core_sources.source(i).profiles_1d(0).ion(k).particles.resize(j);
	      for (l=0; l<j; l++)
		ids._core_sources.source(i).profiles_1d(0).ion(k).particles(l) = 2*l+k;
	      ids._core_sources.source(i).profiles_1d(0).ion(k).state.resize(10);
	      for (l=0; l<10; l++)
		ids._core_sources.source(i).profiles_1d(0).ion(k).state(l).z_min = l;
	    }
	  if (first_slice)
	    {
	      cout << "Put first slice\n";
	      ids._core_sources.put();
	      first_slice = false;
	    }
	  else
	    {
      	      cout << "Append new slice\n";
	      ids._core_sources.putSlice();
	    }
	}
    }

  std::cout << "core_sources IDS saved\n";

  ids.close();
  
  delete[] time; 
  delete[] vect1DDouble;
  
  return 0;
}
