//Definition of the class structures in file ALClasses.h
#include "ALClasses.h"

using namespace IdsNs;
int main(int argc, char *argv[])
{
   float time=10;
   int icoil,i, pulse, number=1;
   char dum[23];
   int interp = 2;
   char* userName = getenv("USER");
   
   if(userName == NULL) 
   {
        printf( "PANIC: $USER not found! Exiting...");
        exit(1);
    }



   IdsNs::IDS *II,*JJ;
   II = new IDS();
   if(argc != 4) {
    printf("usage : test_getslice_pf_active num_pulse, time, interp\n");
    exit(1);
   }
   pulse = atoi(argv[1]);
   time = atof(argv[2]);
   interp = atoi(argv[3]);

   IdsNs::IDS ids1(pulse,1,pulse,0);
   ids1.openEnv(userName, "test", "3"); //Open the database

   ids1._pf_active.getSlice(time, interp);

   printf("coil1,2  name:%s,  %s\n",ids1._pf_active.coil(0).name.c_str(),ids1._pf_active.coil(1).name.c_str());
   cout << "pf_activeSYSTEMS at time " << time << "\n" << ids1._pf_active;

   printf("\n\n======   Pulse %d   ===============\nAt time %g  with interp = %d\n",pulse, time, interp);

   for (icoil=0; icoil< ids1._pf_active.coil.extent(0);icoil++) {
     printf("coil(%d).current.data:", icoil);
     for (int i=0;i<ids1._pf_active.coil(icoil).current.data.extent(0);i++)
       printf("%g ",  ids1._pf_active.coil(icoil).current.data(i));
       puts(" ");
      printf("coil(%d).current.time: ",icoil);
     for (int i=0;i< ids1._pf_active.coil(icoil).current.time.extent(0);i++)
       printf("%g ",  ids1._pf_active.coil(icoil).current.time(i)) ;
       puts(" ");
   puts("======");
   }
   ids1.close();
}
