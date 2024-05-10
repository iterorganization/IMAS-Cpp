// Definition of the class structures in file ALClasses.h
// This program gets data from the DB entry, just for practicing the AL GET command
// It servers also as a nested of 3 level nested AoS (type 3 at the top, type 2 below)
//
#include "ALClasses.h"

using namespace IdsNs;
int main(int argc, char *argv[])
{

  int nb;
  double time_1[10], vect1DDouble_1[10], time_2[12], vect1DDouble_2[12];
  int idx, status, i, j, k;
  IDS::core_profiles cp;
  
  char uri[]="imas:mdsplus?path=./test_db_test_core_profiles";

  float time=10;

  IdsNs::IDS ids;
  ids.open(uri, OPEN_PULSE);
  
  printf("\nGetting core_profiles \n");
  ids._core_profiles.get();

  printf("ids_properties= comment:%s,"  " Homogeneous:%d\n",
	 ids._core_profiles.ids_properties.comment.c_str(),
	 ids._core_profiles.ids_properties.homogeneous_time );

  nb = ids._core_profiles.profiles_1d.extent(0);
  printf("profiles_1d.time:");
  for (j=0; j< nb; j++)
    printf(" %g",ids._core_profiles.profiles_1d(j).time);
  puts("");

  nb = ids._core_profiles.time.extent(0);
  printf("Main IDS time:");
  for (j=0; j< nb; j++)
    printf(" %g",ids._core_profiles.time(j));
  puts("");

  nb = ids._core_profiles.global_quantities.ip.extent(0);
  printf("Ip:");
  for (j=0; j< nb;j++)
    printf(" %g",ids._core_profiles.global_quantities.ip(j));
  puts("");

  for (i=0; i< sizeof(time_1)/sizeof(time_1[0]); i++){
    printf("\ntime_slice i=%g\n",ids._core_profiles.profiles_1d(i).time);
    printf("rho= ");
    for(j=0; j< ids._core_profiles.profiles_1d(i).grid.rho_tor_norm.size(); j++)
      printf(" %g", ids._core_profiles.profiles_1d(i).grid.rho_tor_norm(j));
    puts("");

    printf("List of ion masses= ");
    for( j=0; j<ids._core_profiles.profiles_1d(i).ion.extent(0);j++)
      printf(" %g",ids._core_profiles.profiles_1d(i).ion(j).z_ion);
    puts("");

    for(j=0; j < ids._core_profiles.profiles_1d(i).ion.size(); j++){
      printf("Ni for ion j at time i:");
      for(k=0; k<ids._core_profiles.profiles_1d(i).ion(j).density.extent(0); k++)
	printf(" %g",ids._core_profiles.profiles_1d(i).ion(j).density(k));
      puts("");
      printf( "List of charge states for ion j at time i:");
      for(k=0; k<ids._core_profiles.profiles_1d(i).ion(j).state.extent(0); k++)
	printf( " %g",ids._core_profiles.profiles_1d(i).ion(j).state(k).z_min);
      puts("");
    }
  }

  ids.close();
}
