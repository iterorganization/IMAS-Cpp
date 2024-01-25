//Definition of the class structures in file ALClasses.h
#include "ALClasses.h"

using namespace IdsNs;
int main(int argc, char *argv[])
{

  int number = 10;
  int i, lentime_1, lentime_2;
  double *time_1,*vect1DDouble_1,*time_2,*vect1DDouble_2;
  bool first_slice = true;

    char* userName = getenv("USER");
    if(userName == NULL) 
    {
        printf( "PANIC: $USER not found! Exiting...");
        exit(1);
    }

  // Allocate a first generic vector and its time base
  lentime_1 = 10;
  vect1DDouble_1 = new double[lentime_1];
  time_1 = new double[lentime_1];

  for(i=0; i< lentime_1;i++){
     time_1[i]=i;
     vect1DDouble_1[i]=i*10;
     //printf("time_1[%d]:%f  vect1DDouble_1[%d]:%f\n",i,time_1[i],i,vect1DDouble_1[i]);
  }
  //Allocate a second generic vector and its time base
  lentime_2 = 12;
  vect1DDouble_2 = new double[lentime_2];
  time_2 = new double[lentime_2];
  for(i=0; i< lentime_2;i++){
     time_2[i]=i+11;
     vect1DDouble_2[i]=2*(i*11)+10;
   //  printf("time_2[%d]:%f  vect1DDouble_2[%d]:%f\n",i,time_2[i],i,vect1DDouble_2[i]);
  }
  puts("");

  int pulse=10, icoil;
  IdsNs::IDS ids(10,1,10,0);
  ids.createEnv(userName, "test", "3");

  ids._pf_active.coil.resize(2);
  ids._pf_active.coil(0).name = "COIL 1";
  ids._pf_active.coil(1).name = "COIL 2";
  ids._pf_active.ids_properties.homogeneous_time = 1; // Mandatory to define this property
  ids._pf_active.ids_properties.comment = "This is a test ids";

  ids._pf_active.time.resize(1);



// start filling the time-dependent part of the ids and put_slice it progressively within a time loop
  ids._pf_active.coil(0).current.data.resize(1);
  ids._pf_active.coil(1).current.data.resize(1);
  //ids._pf_active.coil(0).current.time.resize(1);
  //ids._pf_active.coil(1).current.time.resize(1);



  for( i=0; i <lentime_1; i++){
// for( i=2; i <3; i++){
     ids._pf_active.coil(0).current.data(0)= vect1DDouble_1[i];
     ids._pf_active.coil(1).current.data(0)= vect1DDouble_2[i];
     ids._pf_active.time(0) = time_1[i];

     if (first_slice)
     {
        cout << "Put first slice\n";
        ids._pf_active.put();
        first_slice = false;
     }
     else
     {
        cout << "Append new slice\n";
        ids._pf_active.putSlice();
     }
   }

//______________
/*
 ids._pf_active.get();
   cout << "pf_activeSYSTEMS pulse: " << pulse << "\n" << ids._pf_active;
   printf("\n===============================================\n");
   printf("\n    Pulse=%d\n",pulse);
   printf("\n===============================================\n");

   printf("ids_properties= comment_of:%s,\n homogtime:%d\n",ids._pf_active.ids_properties.comment_of.c_str(),ids._pf_active.ids_properties.homogeneous_time );
   printf("coil1,2  name:%s,%s\n",ids._pf_active.coil(0).name.c_str(),ids._pf_active.coil(1).name.c_str());

   for (icoil=0; icoil< ids._pf_active.coil.extent(0);icoil++) {
        printf("coil(%d).current.data: ",icoil);
        for (int i=0;i<ids._pf_active.coil(icoil).current.data.extent(0);i++)
          printf("%g ",  ids._pf_active.coil(icoil).current.data(i));
          puts(" ");

        printf("coil(%d).current.time: ",icoil);
        for (int i=0;i<ids._pf_active.coil(icoil).current.time.extent(0);i++)
          printf("%g ",  ids._pf_active.coil(icoil).current.time(i)) ;
          puts(" ");
   }
*/

   ids.close();
}
