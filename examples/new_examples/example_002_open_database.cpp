#include "ALClasses.h"
#include <string>


using namespace IdsNs;

void creating_completly_new_ids()
{
    // This example focuses on creating empty IDS and allocating arrays inside IDS structure

    char uri[]="imas:mdsplus?path=./test_db_test_core_profiles";
    IdsNs::IDS ids;

    // Open a new pulse in the database with force creation option
    ids.open(uri, FORCE_CREATE_PULSE);

    // Note! Every IDS must have <ids>/ids_properties/homogeneous_time field set with one of possible values
    // Possible homogeneous_time values are:
    //  IDS_TIME_MODE_HETEROGENEOUS: All time-dependent quantities in the IDS may have different time coordinates.
    //  IDS_TIME_MODE_HOMOGENEOUS: All time-dependent quantities in this IDS use the same time coordinate, namely <ids>/time
    //  IDS_TIME_MODE_INDEPENDENT: The IDS stores no time-dependent data.

    ids._core_profiles.ids_properties.homogeneous_time = IDS_TIME_MODE_HOMOGENEOUS;

    // it is also recommended to provide basic information regarding data source
    // even though this information is not required to store IDS, it is highly recommended
    // to fill these fields.
    //  <ids>/ids_properties/comment
    //  <ids>/ids_properties/provider
    //  <ids>/ids_properties/creation_date

    // when ids_properties.homogeneous_time is set to IDS_TIME_MODE_HOMOGENEOUS, 
    // all time-dependent fields values correspond to <ids>.time vector.

    ids._core_profiles.time.resize(3);
    for(int i=0; i<3; i++)
        ids._core_profiles.time(i)=i;

    // size of time dependent variables must be equal to the size of time vector

    ids._core_profiles.global_quantities.ip.resize(3);
    for(int i=0; i<3; i++)
        ids._core_profiles.global_quantities.ip(i)=i;
    ids.close();
}

void default_values_and_aos_operations()
{
    // This example focuses on handling arrays of structures and default values

    IdsNs::IDS ids_1;

    // set mandatory field
    ids_1._edge_profiles.ids_properties.homogeneous_time = IDS_TIME_MODE_HOMOGENEOUS;

    // edge_profiles/grid_ggd is array of structures and must be resized before accessing any of it's elements
    ids_1._edge_profiles.grid_ggd.resize(1);
    ids_1._edge_profiles.grid_ggd(0).identifier.name = "First test struct";

    IdsNs::IDS ids_2;
    ids_2._edge_profiles.grid_ggd.resize(1);
    ids_2._edge_profiles.grid_ggd(0).identifier.name = "Second test struct";

    ids_1._edge_profiles.grid_ggd.resize(2);
    ids_1._edge_profiles.grid_ggd(1) = ids_2._edge_profiles.grid_ggd(0);

    // ids fields have default values different for every data type
    std::cout<<"Default value for \"INT\"   data  (edge_profiles/midplane/index) : "<<ids_1._edge_profiles.midplane.index<<"\n";
    std::cout<<"Default value for \"FLOAT\"   data  (edge_profiles/vacuum_toroidal_field/vacuum_toroidal_field/r0) : "<< ids_1._edge_profiles.vacuum_toroidal_field.r0<<"\n";
    std::cout<<"Default value for \"COMPLEX\" data      : "<< EMPTY_COMPLEX << "\n";
    std::cout<<"Default value for 1+ dimensional data      : "<<ids_1._edge_profiles.vacuum_toroidal_field.b0<<"\n";

}

void copying_and_validating_ids()
{
    // This example focuses on creating multi-dimensional arrays, using copmlex type and copying IDS structures
    
    IdsNs::IDS ids;

    // there is mandatory field <ids>/ids_properties/homogeneous_time
    ids._gyrokinetics_local.ids_properties.homogeneous_time =  IDS_TIME_MODE_HOMOGENEOUS;
    
    // some IDS fields contain multi-dimensional arrays
    ids._gyrokinetics_local.non_linear.fields_zonal_2d.phi_potential_perturbed_norm.resize(3,3);
    for(int x=0 ;x<3; x++)
    {
        for(int y=0; y<3; y++)
        {
            ids._gyrokinetics_local.non_linear.fields_zonal_2d.phi_potential_perturbed_norm(x,y) = x+y;
        }
    }

    std::cout<<"Filled 2D array (gyrokinetics_local/non_linear/fields_zonal_2d/phi_potential_perturbed_norm): \n"<<ids._gyrokinetics_local.non_linear.fields_zonal_2d.phi_potential_perturbed_norm<<"\n";
    
    // some fields have coordinates consistency. <isd>.validate() method checks for this consistency.
    // example of field of this type is gyrokinetics_local/non_linear/fields_zonal_2d/phi_potential_perturbed_norm
    // it's first dimension size must be equal to non_linear/radial_wavevector_norm size and second dimension size equal to non_linear/time_norm

    try{
        ids._gyrokinetics_local.validate();
    }
    catch (IdsNs::ValidationException ve){
        std::cout << ve.what() << std::endl;
    }

    // to fix this
    ids._gyrokinetics_local.non_linear.radial_wavevector_norm.resize(3);
    ids._gyrokinetics_local.non_linear.time_norm.resize(3);
 
    for(int i=0;i<3;i++){
        ids._gyrokinetics_local.non_linear.radial_wavevector_norm(i) = i;
        ids._gyrokinetics_local.non_linear.time_norm(i) = i;
    }
       
    ids._gyrokinetics_local.linear.wavevector.resize(1);
    ids._gyrokinetics_local.linear.wavevector(0).eigenmode.resize(1);
    ids._gyrokinetics_local.linear.wavevector(0).eigenmode(0).fields.phi_potential_perturbed_norm.resize(3,3);
    ids._gyrokinetics_local.linear.wavevector(0).eigenmode(0).time_norm.resize(3);
    for(int i=0;i<3;i++)
        ids._gyrokinetics_local.linear.wavevector(0).eigenmode(0).time_norm(i)=i;

    for(int x=0 ;x<3; x++){
        for(int y=0; y<3; y++){
            ids._gyrokinetics_local.linear.wavevector(0).eigenmode(0).fields.phi_potential_perturbed_norm(x,y) = complex((double)x,(double)y);
        }
    }
    ids._gyrokinetics_local.linear.wavevector(0).eigenmode(0).angle_pol.resize(3);
    for(int i=0;i<3;i++)
        ids._gyrokinetics_local.linear.wavevector(0).eigenmode(0).angle_pol(i)=i;

    // right way to copy IDS
    IdsNs::IDS gyrokinetics_local, ids_local_copy;

    gyrokinetics_local.open("imas:memory?path=/", FORCE_CREATE_PULSE);
    ids.setPulseCtx(gyrokinetics_local.getPulseCtx());
    ids_local_copy.setPulseCtx(gyrokinetics_local.getPulseCtx());
    ids._gyrokinetics_local.put();
    ids_local_copy._gyrokinetics_local.get();

    for(int x=0 ;x<3; x++){
        for(int y=0; y<3; y++){
                ids_local_copy._gyrokinetics_local.linear.wavevector(0).eigenmode(0).fields.phi_potential_perturbed_norm(x,y) = complex((double)-x,(double)-y);
            }
    }

    // If deep copy is performed, changes to the copied structure will not be propagated to the original object
    std::cout<<"Original value:\n" <<ids._gyrokinetics_local.linear.wavevector(0).eigenmode(0).fields.phi_potential_perturbed_norm<<"\n";
    std::cout<<"Copied value:\n"<<ids_local_copy._gyrokinetics_local.linear.wavevector(0).eigenmode(0).fields.phi_potential_perturbed_norm<<"\n";

}
int main()
{
    creating_completly_new_ids();
    default_values_and_aos_operations();
    copying_and_validating_ids();

    return 0;
}