#include "ALClasses.h"

using namespace IdsNs;

int main(int argc, char **argv)
{
  char * userName = NULL;
  int pulse = 12;   // your choice
  int run = 1;     // your choice
  int refpulse = 0; // dummy, not used
  int refrun = 0;  // dummy, not used
  char uri[]="imas:mdsplus?path=./test_db_test_pulse_create";
  userName = getenv("USER");
  if(userName == NULL) 
    {
      printf( "PANIC: $USER not found! Exiting...");
      exit(1);
    }
    
  IdsNs::IDS ids;
  ids.open(uri, FORCE_CREATE_PULSE);

  ids.close();
}
