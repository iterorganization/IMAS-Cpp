// Definition of the class structures in file ALClasses.h
#include "ALClasses.h"

using namespace IdsNs;

int main(int argc, char* argv[]) {
  double vect1DDouble_1[10], vect1DDouble_2[12];
  int number = 10;  // number of elements
  char treename[] = "ids";
  char uri[]="imas:ascii?path=./test_db_test_core_profiles_serialize";
  int pulse = 12, run = 2, refpulse = 0, refrun = 0, i, j, Sz, idx;

  char* userName = getenv("USER");
  if (userName == NULL) {
    printf("PANIC: $USER not found! Exiting...");
    exit(1);
  }

  // The parameters passed to this creator define the pulse and run number. The
  // second pair of arguments defines the reference pulse and run and is used
  // when the a new database is created, as in this example. All the AL classes
  // belong to the idsNs namespace
  //

  //! Define a first generic vector and its time base
  double time_1[] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0};
  for (i = 0; i < 10; i++) vect1DDouble_1[i] = time_1[i] * 10;

  //! Define a second generic vector
  double time_2[] = {11.0, 12.0, 13.0, 14.0, 15.0, 16.0,
                     17.0, 18.0, 19.0, 20.0, 21.0, 22.0};
  for (i = 0; i < 12; i++) vect1DDouble_2[i] = time_2[i] * 2. + 10.;

  IdsNs::IDS ids;
  ids.open(uri, FORCE_CREATE_PULSE);

  //! allocate the ids fields
  // printf("SIZE %d %d \n",sizeof(time_1), sizeof(time_1)/sizeof(time_1[0]));
  Sz = sizeof(time_1) / sizeof(time_1[0]);
  ids._core_profiles.profiles_1d.resize(Sz);
  printf("Completed allocation of %d profiles_1d\n", Sz);
  //
  for (i = 0; i < Sz; i++) {
    //! Varies the size of the array of structure children with time index
    ids._core_profiles.profiles_1d(i).grid.rho_tor_norm.resize(i+1);
    for (j = 0; j <= i; j++)
      ids._core_profiles.profiles_1d(i).grid.rho_tor_norm(j) =
          vect1DDouble_1[j];
    ids._core_profiles.profiles_1d(i).time = time_1[i];

    ids._core_profiles.profiles_1d(i).ion.resize(i + 1);
    // ! Test nested arrays of structure (type 2 AoS below a type 3), varying
    // also the size of the nested AoS
    for (j = 0; j <= i; j++) {
      ids._core_profiles.profiles_1d(i).ion(j).z_ion = time_1[j];
      // ! Fixed radial grid size = 3, for ion #j of time slice #i (already
      // quite complicated)
      ids._core_profiles.profiles_1d(i).ion(j).density.resize(i+1);
      for (int k = 0; k <= i; k++)
        ids._core_profiles.profiles_1d(i).ion(j).density(k) =
            vect1DDouble_1[k] + j;
      //   Test 3rd level of nested arrays of structure (type 2 AoS below a type
      //   2 AoS below a type 3)
      ids._core_profiles.profiles_1d(i).ion(j).state.resize(10);
      for (int k = 0; k < 10; k++)
        ids._core_profiles.profiles_1d(i).ion(j).state(k).z_min = k;
    }
  }
  printf("Completed filling of profiles_1d fields\n");
  //! Fill the ids fields with data
  ids._core_profiles.ids_properties.homogeneous_time =
      0;  //! Mandatory to define this property
  ids._core_profiles.ids_properties.comment =
      "This is a test ids V3 Put by C++";
  ids._core_profiles.global_quantities.ip.resize(sizeof(time_2) /
                                                 sizeof(time_2)[0]);
  for (int ii = 0; ii < sizeof(time_2) / sizeof(time_2[0]); ii++)
    ids._core_profiles.global_quantities.ip(ii) = vect1DDouble_2[ii];

  ids._core_profiles.time.resize(sizeof(time_2) / sizeof(time_2[0]));
  for (j = 0; j < sizeof(time_2) / sizeof(time_2[0]); j++)
    ids._core_profiles.time(j) = time_2[j];

  printf("\nStart Serializing the core_profiles IDS\n");
  std::string data = ids._core_profiles.serialize();
  printf("Done serializing\n");

  printf("\nStart deserializing the core_profiles IDS\n");
  
  IdsNs::IDS ids2;
  ids2.open(uri, FORCE_CREATE_PULSE);
  ids2._core_profiles.deserialize(data);
  printf("Done deserializing\n");

  printf("\nStart testing if deserialized IDS is the same as the original\n");
  double eps = 1e-6;
  for (i = 0; i < Sz; i++) {
    for (j = 0; j <= i; j++)
      if(abs(ids._core_profiles.profiles_1d(i).grid.rho_tor_norm(j) - ids2._core_profiles.profiles_1d(i).grid.rho_tor_norm(j)) > eps)
        printf("ERROR: deserialized rho_tor_norm values are different from the original ones\n");
    if(abs(ids._core_profiles.profiles_1d(i).time - ids2._core_profiles.profiles_1d(i).time) > eps)
      printf("ERROR: deserialized time values are different from the original ones\n");

    for (j = 0; j <= i; j++) {
      if(abs(ids._core_profiles.profiles_1d(i).ion(j).z_ion - ids2._core_profiles.profiles_1d(i).ion(j).z_ion) > eps)
        printf("ERROR: deserialized z_ion values are different from the original ones\n");
      for (int k = 0; k <= i; k++)
        if(abs(ids._core_profiles.profiles_1d(i).ion(j).density(k) - ids2._core_profiles.profiles_1d(i).ion(j).density(k)) > eps)
          printf("ERROR: deserialized density values are different from the original ones\n");
      for (int k = 0; k < 10; k++)
        if(abs(ids._core_profiles.profiles_1d(i).ion(j).state(k).z_min - ids2._core_profiles.profiles_1d(i).ion(j).state(k).z_min) > eps)
          printf("ERROR: deserialized z_min values are different from the original ones\n");
    }
  }
  printf("Done testing\n");

  ids.close();
  ids2.close();
}
