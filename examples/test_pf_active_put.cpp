//Definition of the class structures in file ALClasses.h
#include "ALClasses.h"

using namespace IdsNs;


int main(int argc, char *argv[])
{
  double * vect1DDouble_1, time_1, vect1DDouble_2, vect1DDouble_3;
  int number = 10; //number of elements
  char* userName = NULL;
  char uri[]="imas:mdsplus?path=./test_db";

    userName = getenv("USER");
    if(userName == NULL) 
    {
        printf( "PANIC: $USER not found! Exiting...");
        exit(1);
    }

  //The parameters passed to this creator define the pulse and run number. The second pair of arguments defines the reference pulse and run
  //and is used when the a new database is created, as in this example.
  //All the AL classes belong to the idsNs namespace

  ids.open(uri, FORCE_CREATE_PULSE);
/////////////////ids::pf_active *pf_actives = ids.pf_active();

  ids._pf_active.ids_properties.comment = "Test data";
//  ids._pf_active.Vertical_Forces.names.resize(64);
//  ids._pf_active.Vertical_Forces.names[0] = "VF name1";

        //A sample int

  ids._pf_active.ids_properties.homogeneous_time = 0; // Mandatory to define this property

  ids._pf_active.coil.resize(2);
  ids._pf_active.coil(0).name = "COIL 1";
  ids._pf_active.coil(1).name = "COIL 2";

  ids._pf_active.coil(0).current.data.resize(number);
  ids._pf_active.coil(0).current.time.resize(number);
  for (int i=0;i<number;i++) {
    ids._pf_active.coil(0).current.data(i)= 2*i;
    ids._pf_active.coil(0).current.time(i) =i ;
  }

  number = number+2;
  ids._pf_active.coil(1).current.data.resize(number);
  ids._pf_active.coil(1).current.time.resize(number);
  for (int i=0;i<number;i++) {
    ids._pf_active.coil(1).current.data(i)= 2*i + 10;
    ids._pf_active.coil(1).current.time(i)= i + number;
  }

  ids._pf_active.put();

  ids.close();
}
