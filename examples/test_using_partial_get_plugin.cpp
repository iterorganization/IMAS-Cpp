#include <stdlib.h>
#include "ALClasses.h"

#include <blitz/array.h>
using namespace blitz;

#define PARTIAL_GET "partial_get"
using namespace IdsNs;

void save_data(const char* uri);
void exitIfError(al_status_t &status);


int main(int argc, char** argv){

  char uri[]="imas:hdf5?path=./test_db_test_core_profiles";
  save_data(uri);

  IdsNs::IDS data_entry;
  data_entry.open(uri, OPEN_PULSE);

  IDS::core_profiles ids = data_entry._core_profiles;

  //One example without excludes
  ids.partialGet("ids_properties;profiles_1d(1:5:1)", ""); // ids.partialGet(const std::string& includes, const std::string& excludes)

  printf("ids_properties.homogeneous_time = %d\n", ids.ids_properties.homogeneous_time);
  printf("In this example, shape of the profiles_1d AOS is unchanged, for example,\n");
  printf("we expect 10 elements in profiles_1d, found = %d\n", ids.profiles_1d.size());
  printf("However, only attributes of the first 5 elements of profiles_1d are filled, for example the time values are: \n", ids.profiles_1d.size());
  for (int i = 0; i < ids.profiles_1d.size(); i++) {
    printf("profiles_1d.time[%d] = %f\n", i, ids.profiles_1d(i).time);
  }
  data_entry.close();
}

void exitIfError(al_status_t &status) {
  if (status.code != 0) {
       printf("%s\n", status.message);
       exit(-1);
  }
}

void save_data(const char* uri) {
  IdsNs::IDS data_entry;
  data_entry.open(uri, OPEN_PULSE);
  IDS::core_profiles ids = data_entry._core_profiles;
  double  vect1DDouble_1[10], vect1DDouble_2[12];
  int number = 10; //number of elements
  int pulse = 12,
    run = 2,
    refpulse = 0,
    refrun = 0,
    i,j, Sz,idx;

  //The parameters passed to this creator define the pulse and run number. The second pair of arguments defines the reference pulse and run
  //and is used when the a new database is created, as in this example.
  //All the AL classes belong to the idsNs namespace
  //

  //! Define a first generic vector and its time base
  double time_1[] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0};
  for (i=0; i<10;i++)
    vect1DDouble_1[i] = time_1[i]*10;

  //! Define a second generic vector
  double time_2[] = {11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0};
  for (i=0; i<12;i++)
    vect1DDouble_2[i] = time_2[i]*2.+10.;

  //! allocate the ids fields
  //printf("SIZE %d %d \n",sizeof(time_1), sizeof(time_1)/sizeof(time_1[0]));
  Sz= sizeof(time_1)/sizeof(time_1[0]);
  ids.profiles_1d.resize(Sz);
  printf("Completed allocation of %d profiles_1d\n", Sz);
  //
  for(i=0; i < Sz; i++) {
    //! Varies the size of the array of structure children with time index
    ids.profiles_1d(i).grid.rho_tor_norm.resize(i+1);
    for (j=0; j<=i;j++)
      ids.profiles_1d(i).grid.rho_tor_norm(j) = vect1DDouble_1[j];
    ids.profiles_1d(i).time = time_1[i];

    ids.profiles_1d(i).ion.resize(i+1);
    // ! Test nested arrays of structure (type 2 AoS below a type 3), varying also the size of the nested AoS
    for (j=0;j<= i; j++) {
      ids.profiles_1d(i).ion(j).z_ion = time_1[j];
      // ! Fixed radial grid size = 3, for ion #j of time slice #i (already quite complicated)
      ids.profiles_1d(i).ion(j).density.resize(i+1);
      for (int k=0; k<=i; k++)
	ids.profiles_1d(i).ion(j).density(k) = vect1DDouble_1[k]+j;
      //   Test 3rd level of nested arrays of structure (type 2 AoS below a type 2 AoS below a type 3)
      ids.profiles_1d(i).ion(j).state.resize(10);
      for (int k=0; k<10; k++)
        ids.profiles_1d(i).ion(j).state(k).z_min = k;
    }
  }
  printf("Completed filling of profiles_1d fields\n");
  //! Fill the ids fields with data
  ids.ids_properties.homogeneous_time = 0; //! Mandatory to define this property
  ids.ids_properties.comment = "Testing the partial get plugin";
  ids.global_quantities.ip.resize(sizeof(time_2)/sizeof(time_2)[0]);
  for(int ii=0; ii < sizeof(time_2)/sizeof(time_2[0]); ii++)
    ids.global_quantities.ip(ii) = vect1DDouble_2[ii];

  ids.time.resize(sizeof(time_2)/sizeof(time_2[0]));
  for (j=0;j< sizeof(time_2)/sizeof(time_2[0]); j++)
    ids.time(j)=time_2[j];

  printf("\nStart Putting the core_profiles IDS\n");

  ids.put();
  printf("core_profiles IDS pulse:%d, run:%d, refpulse:%d, refrun:%d saved\n", pulse, run, refpulse, refrun);
  data_entry.close();

} 




