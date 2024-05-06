// Definition of the class structures in file ALClasses.h
#include "ALClasses.h"

using namespace IdsNs;


int main(int argc, char *argv[])
{
  double  time;
  int interp= 2;
  int pulse = 12,
    run = 3,
    refpulse = 0,
    refrun = 0,
    i,j, Sz,idx;
  char treename[]="ids";
  char uri[]="imas:mdsplus?path=./test_db";
  char* userName = NULL;


  if(argc > 1)
    pulse=atoi(argv[1]);


  userName = getenv("USER");
  if(userName == NULL) 
    {
      printf( "PANIC: $USER not found! Exiting...");
      exit(1);
    }
  IdsNs::IDS ids;
  ids.open(uri, OPEN_PULSE);
  
  time = 4;
  printf("===============================================================================\n");
  printf("get_slice core_profiles IDS pulse:%d, run:%d, refpulse:%d, refrun:%d at time:%g\n", pulse, run, refpulse, refrun,time);
  printf("===============================================================================\n\n");
  ids._core_profiles.getSlice(time, interp);

  Sz=ids._core_profiles.profiles_1d.size();
  Sz=ids._core_profiles.profiles_1d.extent(0);

  printf("ids_properties.homogeneous: %d\n",ids._core_profiles.ids_properties.homogeneous_time);
  printf("ids_properties.comment:     %s\n",ids._core_profiles.ids_properties.comment.c_str());
  printf("size of profiles_1d:        %d\n",ids._core_profiles.profiles_1d.size());

  printf("profiles_1d.time:");
  for(i=0; i< ids._core_profiles.profiles_1d.extent(0); i++)
    printf(" %g\n",ids._core_profiles.profiles_1d(i).time);
  puts(" ");

  printf("main IDS time:");
  for(i=0; i< ids._core_profiles.time.extent(0); i++)
    printf(" %g",ids._core_profiles.time(i));
  puts("");

  printf("Ip:");
  for(i=0; i< ids._core_profiles.global_quantities.ip.extent(0); i++)
    printf(" %g\n",ids._core_profiles.global_quantities.ip(i));
  puts("");

  for ( i=0;i<ids._core_profiles.profiles_1d.extent(0);i++) {
    //printf("ZZ %d\n",ids._core_profiles.profiles_1d(i).ion.extent(0));

    printf("Time slice i = %g\n",ids._core_profiles.profiles_1d(i).time);
    for (j=0;j<ids._core_profiles.profiles_1d(i).grid.rho_tor_norm.extent(0);j++) {
      printf("rho = %g",ids._core_profiles.profiles_1d(i).grid.rho_tor_norm(j));
    }
    puts("");
    printf("List of ion masses = ");

    for (j=0;j<ids._core_profiles.profiles_1d(i).ion.extent(0);j++) {
      printf(" %g",ids._core_profiles.profiles_1d(i).ion(j).z_ion);
    }
    puts("");

    for (j=0;j<ids._core_profiles.profiles_1d(i).ion.extent(0);j++) {
      for(int i1=0;i1<ids._core_profiles.profiles_1d(i).ion(j).density.extent(0);i1++)
	printf("Ni for ion j at time i %g\n",ids._core_profiles.profiles_1d(i).ion(j).density(i1));
      printf("Charge states for ion j at time i ");
      for (int k=0;k<ids._core_profiles.profiles_1d(i).ion(j).state.extent(0);k++) {
	printf(" %g",ids._core_profiles.profiles_1d(i).ion(j).state(k).z_min);
      }
      puts("");
    }
  }

  ids.close();

}
