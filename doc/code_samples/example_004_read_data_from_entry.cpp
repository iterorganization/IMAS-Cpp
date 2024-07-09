#include "ALClasses.h"
#include <string>


using namespace IdsNs;

void read_entire_ids()
{
    // This example focuses on reading whole IDS from entry.
    // We are storing and reading back an IDS - equilibrium. Data are stored inside MDS+ file.
    
    // NOTE: this block of code uses 'FORCE_CREATE_PULSE' mode in order to create example data
    IdsNs::IDS ids;
    int status = ids.open("imas:mdsplus?path=./testdb_mdsplus", FORCE_CREATE_PULSE);

    IdsNs:IDS::equilibrium  equilibrium;

    // fill IDS with example data
    equilibrium.ids_properties.homogeneous_time = IDS_TIME_MODE_HOMOGENEOUS;
    equilibrium.time.resize(3);
    for(int i=0; i<3; i++){
        equilibrium.time(i) = i;
    }

    equilibrium.vacuum_toroidal_field.b0.resize(3);
    for(int i=0; i<3; i++){
        equilibrium.vacuum_toroidal_field.b0(i) = i;
    }
    equilibrium.setPulseCtx(ids.getPulseCtx());
    equilibrium.put();

    ids.close();

    // NOTE: this block of code uses 'OPEN_PULSE' mode in order to read example data
    status = ids.open("imas:mdsplus?path=./testdb_mdsplus", OPEN_PULSE);
    ids._equilibrium.get();
    equilibrium = ids._equilibrium;
    
    // here you can access content of the IDS equilibrium
    // some_variable = equilibrium.some_element
    // equilibrium.some_element = ...
    // etc.

    // one may check if IDS was filled with data using <ids>.isDefined() method
    std::cout<<"is equilibrium defined?:"<< equilibrium.isDefined()<<"\n";
}

void read_slice()
{
    // This example focuses on reading IDS slices from entry
    // We are storing and reading back an IDS - summary. Data are stored inside MDS+ file.

    // NOTE: this block of code uses 'FORCE_CREATE_PULSE' mode in order to create example data
    IdsNs::IDS ids;
    int status = ids.open("imas:mdsplus?path=./testdb_mdsplus", FORCE_CREATE_PULSE);
    
    // fill IDS with example data
    IdsNs::IDS::summary summary;
    summary.ids_properties.homogeneous_time = IDS_TIME_MODE_HOMOGENEOUS;
    
    summary.global_quantities.ip.value.resize(3);
    for(int i=0; i<3; i++){
        summary.global_quantities.ip.value(i) = 10+i;
    }
    summary.heating_current_drive.nbi.resize(1);
    summary.heating_current_drive.nbi(0).beam_current_fraction.value.resize(3,3);
    for(int i=0;i<3;i++){
        for(int j=0; j<3; j++){
            summary.heating_current_drive.nbi(0).beam_current_fraction.value(i,j) = 100*i;
        }
    }
    summary.time.resize(3);
    for(int i=0;i<3;i++){
        summary.time(i) = 1+i;
    }
    summary.heating_current_drive.nbi.resize(1);
    
    summary.setPulseCtx(ids.getPulseCtx());
    summary.put();
    ids.close();

    // NOTE: this block of code uses 'OPEN_PULSE' mode in order to read example data
    status = ids.open("imas:mdsplus?path=./testdb_mdsplus", OPEN_PULSE);
    // Access Layer API shares 3 different methods of interpolating values from DBEntry
    // PREVIOUS_SAMPLE
    // CLOSEST_SAMPLE¶
    // INTERPOLATION

    // this part of code presents PREVIOUS_SAMPLE. It is interpolation method that returns the previous time slice if the requested time does not exactly exist in the original IDS
    // if requested time is outside of time array, first, or last slice will be returned respectively
    ids._summary.getSlice(1.75, PREVIOUS_SAMPLE);
    summary = ids._summary;

    // previous time value for 1.75 is 1.0
    // summary/global_quantities/ip/value and time=1 is 10.0
    std::cout<< "summary/global_quantities/ip/value for time=1: " << summary.global_quantities.ip.value << " (Should be 10.0)"<<"\n";

    // this part of code presents CLOSEST_SAMPLE. It is interpolation method that returns the closest time slice in the original IDS
    // if requested time is equally spaced between two time slices, slice with higher index will be returned
    ids._summary.getSlice(1.75, CLOSEST_SAMPLE);
    summary = ids._summary;
    
    // closest time value to 1.75 is 2.0
    // value for summary/global_quantities/ip/value and time=2 is 11.0
    std::cout<< "summary/global_quantities/ip/value for time=1: " << summary.global_quantities.ip.value << " (Should be 10.0)"<<"\n";

    // this part of code presents INTERPOLATION. It is interpolation method that returns a linear interpolation between the existing slices before and after the requested time.
    // NOTE: The linear interpolation will be successful only if, between the two time slices of an interpolated dynamic array of structure,
    // the same leaves are populated and they have the same size.
    // Otherwise DBEntry.get_slice() will interpolate all fields with a compatible size and leave others empty.


    // NOTE: If time requested is smaller than <ids>.time[0], first slice will be returned. If requested time exceeds highest time, last slice will be returned.
    ids._summary.getSlice(1.75, INTERPOLATION);
    summary = ids._summary;
    
    // interpolated value for summary/global_quantities/ip/value and time=1.75 is 10.75
    std::cout<< "summary/global_quantities/ip/value for time=1: " << summary.global_quantities.ip.value << " (Should be 10.75)"<<"\n";

}

void partial_get()
{
    // The C++ interface does not support partial_get
    ;
}
