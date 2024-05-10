//Definition of the class structures in file ALClasses.h
#include "ALClasses.h"

using namespace IdsNs;
int main(int argc, char *argv[])
{
    float time=10;
    int icoil,i;
    char uri[]="imas:mdsplus?path=./test_db_test_pf_active";
   
   IdsNs::IDS ids;
   ids.open(uri, OPEN_PULSE);

   ids._pf_active.get();

   printf("ids_properties= comment_of:%s, Homog:%d\n",ids._pf_active.ids_properties.comment.c_str(), ids._pf_active.ids_properties.homogeneous_time );

   if (ids._pf_active.coil.extent(0) >= 2)
   {
       printf("coil1,2  name:%s,%s\n",ids._pf_active.coil(0).name.c_str(),ids._pf_active.coil(1).name.c_str());
   }
   
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
   ids.close();

}
