//Definition of the class structures in file ALClasses.h
#include "ALClasses.h"

using namespace IdsNs;


int main(int argc, char *argv[])
{
  double  vect1DDouble_1[10], vect1DDouble_2[12];
  int number = 10; //number of elements
  int pulse = 12,
    run = 3,
    refpulse = 0,
    refrun = 0,
    i,j, Sz,idx;
  char treename[]="ids";
  char uri[]="imas:mdsplus?path=./test_db";
  bool first_slice = true;

  char* userName = getenv("USER");
  if(userName == NULL) 
    {
      printf( "PANIC: $USER not found! Exiting...");
      exit(1);
    }

  //The parameters passed to this creator define the pulse and run number. The second pair of arguments defines the reference pulse and run
  //and is used when the a new database is created, as in this example.
  //All the AL classes belong to the idsNs namespace

  //! Define a first generic vector and its time base
  double time_1[] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0};
  for (i=0; i<10;i++)
    vect1DDouble_1[i] = time_1[i]*10;

  //! Define a second generic vector
  double time_2[] = {11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0};
  for (i=0; i<12;i++)
    vect1DDouble_2[i] = time_2[i]*2.+10.;

  IdsNs::IDS ids;
  ids.open(uri, FORCE_CREATE_PULSE);

  ids._core_profiles.ids_properties.homogeneous_time = 1; //! Mandatory to define this property
  ids._core_profiles.ids_properties.comment = "This is a test ids V3 Put_slice by C++";

  printf("put_slice_core_profiles IDS pulse:%d, run:%d, refpulse:%d, refrun:%d\n",pulse,run,refpulse,refrun);


  ids._core_profiles.profiles_1d.resize(1);
  ids._core_profiles.time.resize(1);
  ids._core_profiles.global_quantities.ip.resize(1); // Allocate all variables, time coordinate of size 1

  Sz= sizeof(time_1)/sizeof(time_1[0]);
  for( i=0; i < Sz; i++) {
    //
    ids._core_profiles.global_quantities.ip(0) = vect1DDouble_1[i];
    ids._core_profiles.time(0) = time_1[i];
    ids._core_profiles.profiles_1d(0).grid.rho_tor_norm.resize(i+1); // Varies the size of the array of structure children with time index
    for(j=0; j<=i;j++)
      ids._core_profiles.profiles_1d(0).grid.rho_tor_norm(j) = vect1DDouble_1[j];
    ids._core_profiles.profiles_1d(0).time= time_1[i];
    ids._core_profiles.profiles_1d(0).ion.resize(i+1); // Test nested arrays of structure (type 2 AoS below a type 3), varying also the size of the nested AoS
    for(j=0; j<=i;j++) {
      ids._core_profiles.profiles_1d(0).ion(j).z_ion = time_1[j];
      ids._core_profiles.profiles_1d(0).ion(j).density.resize(i+1); // Fixed radial grid size = 3, for ion #j of time slice #i (already quite complicated)
      for(int i1=0; i1<=i; i1++)
	ids._core_profiles.profiles_1d(0).ion(j).density(i1) = vect1DDouble_1[i1] + j;

      ids._core_profiles.profiles_1d(0).ion(j).state.resize(10); // Test 3rd level of nested arrays of structure (type 2 AoS below a type 2 AoS below a type 3)
      for (int k=0;k<10;k++)
	ids._core_profiles.profiles_1d(0).ion(j).state(k).z_min = k;

    }
     if (first_slice)
     {
          cout << "Put first slice\n";
          ids._core_profiles.put();
          first_slice = false;
     }
     else
     {
        cout << "Append new slice\n";
        ids._core_profiles.putSlice();
     }
    printf("PutSlice core_profiles IDS %d\n",i);
  }
  printf("\nEnd of PutSlice core_profiles IDS\n");

  ids.close();
}
