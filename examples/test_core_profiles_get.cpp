// Definition of the class structures in file ALClasses.h
// This program gets data from the DB entry, just for practicing the AL GET command
// It servers also as a nested of 3 level nested AoS (type 3 at the top, type 2 below)
//
#include "ALClasses.h"

using namespace IdsNs;
int main(int argc, char *argv[])
{

  int interpol, a1,a2, nb, nbion;
  double time_1[10], vect1DDouble_1[10], time_2[12], vect1DDouble_2[12];
  int idx, pulse, run, refpulse, refrun, status, i, j, k,dum1;
  double double_3;
  IDS::core_profiles cp;

  char longstring[132];
  char treename[]="ids";
  char uri[]="imas:mdsplus?path=./test_db";
  pulse = 12;
  run = 2;
  refpulse = 0;
  refrun =0;

  float time=10;
  int icoil, number=10;
  char dum[23];
  int interp = 2;

  char* userName = NULL;

  userName = getenv("USER");
  if(userName == NULL) 
    {
      printf( "PANIC: $USER not found! Exiting...");
      exit(1);
    }

  ids.open(uri, OPEN_PULSE);
  
  printf("\nGetting core_profiles IDS pulse:%d, run:%d, refpulse:%d, refrun:%d\n", pulse, run, refpulse, refrun);
  ids._core_profiles.get();
  //   cout << "core_profiles pulse: " << pulse << "\n" << ids._core_profiles;

  //printf("\n===============================================\n");
  //printf("\n    Pulse=%d\n",pulse);
  //printf("\n===============================================\n");

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
