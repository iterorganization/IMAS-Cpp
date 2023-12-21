#include "ALClasses.h"

using namespace IdsNs;

int main(int argc, char **argv)
{
  char * userName = NULL;
  int pulse = 12;   // your choice
  int run = 1;     // your choice
  int refpulse = 0; // dummy, not used
  int refrun = 0;  // dummy, not used

  userName = getenv("USER");
  if(userName == NULL) 
    {
      printf( "PANIC: $USER not found! Exiting...");
      exit(1);
    }
  
  std::cout << "Create pulsefile for pulse = " << pulse << " run = " << run << "\n";
  IdsNs::IDS ids(12,1,0,0);
  ids.createEnv(userName, "test", "3");

  ids.close();
}
