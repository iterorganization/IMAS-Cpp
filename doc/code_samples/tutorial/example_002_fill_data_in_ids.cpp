#include "ALClasses.h"
#include <string>
#include "example_002_fill_data_in_ids.h"

using namespace IdsNs;

// This example focuses on creating empty IDS and allocating arrays inside IDS structure
void creating_completly_new_ids()
{
    IdsNs::IDS::core_profiles core_profiles;

    core_profiles.ids_properties.homogeneous_time = IDS_TIME_MODE_HOMOGENEOUS;

    // Note! Every IDS must have <ids>/ids_properties/homogeneous_time field set with one of possible values
    // Possible homogeneous_time values are:
    // IDS_TIME_MODE_HETEROGENEOUS: All time-dependent quantities in the IDS may have different time coordinates.
    // IDS_TIME_MODE_HOMOGENEOUS: All time-dependent quantities in this IDS use the same time coordinate, namely <ids>/time
    // IDS_TIME_MODE_INDEPENDENT: The IDS stores no time-dependent data.
    
    // when ids_properties.homogeneous_time is set to IDS_TIME_MODE_HOMOGENEOUS, 
    // all time-dependent fields values correspond to <ids>.time vector.
    core_profiles.time.resize(3);
    for(int i=0; i<3; i++){
        core_profiles.time(i) = i;
    } 

    //  size of time dependent variables must be equal to the size of time vector

    core_profiles.global_quantities.ip.resize(3);
    for(int i=0; i<3; i++){
        core_profiles.global_quantities.ip(i) = i;
    }
    // IDS will be cleaned up when exiting the scope where it is declared

    // IDSs can be printed using std::cout
    std::cout << "Pritnting core_profiles:                                "<< std::endl;
    std::cout << "empty_core_profiles.ids_properties.homogeneous_time: \n" << core_profiles.ids_properties.homogeneous_time << std::endl;
    std::cout << "empty_core_profiles.time:                            \n" << core_profiles.time  << std::endl;
    std::cout << "empty_core_profiles.global_quantities.ip:            \n" << core_profiles.global_quantities.ip  << std::endl;
}

// This example focuses on handling arrays of structures and default values
void default_values_and_aos_operations()
{

    IdsNs::IDS::edge_profiles edge_profiles_1;

    // set mandatory field
    edge_profiles_1.ids_properties.homogeneous_time = IDS_TIME_MODE_HOMOGENEOUS;

    // edge_profiles/grid_ggd is array of structures and must be resized before accessing any of it's elements
    edge_profiles_1.grid_ggd.resize(1);
    edge_profiles_1.grid_ggd(0).identifier.name = "First test struct";

    IdsNs::IDS::edge_profiles edge_profiles_2;
    edge_profiles_2.grid_ggd.resize(1);
    edge_profiles_2.grid_ggd(0).identifier.name = "Second test struct";
    
    // after calling resize,  data will be deleted.
    // after calling resizeAndPreserve, the data will be preserved.
    int size_before_resize = edge_profiles_1.grid_ggd.size();
    edge_profiles_1.grid_ggd.resizeAndPreserve(edge_profiles_1.grid_ggd.size() + edge_profiles_2.grid_ggd.size());

    for(int i=0; i<edge_profiles_2.grid_ggd.size(); i++){
        edge_profiles_1.grid_ggd(i+size_before_resize) = edge_profiles_2.grid_ggd(i);
    }

    for(int i=0; i<edge_profiles_1.grid_ggd.size(); i++){
         std::cout<<"edge_profiles/grid_ggd after merge:\n"<<edge_profiles_1.grid_ggd(i).identifier.name<<std::endl;
    }


    // ids fields have default values different for every data type
    std::cout<<"Default value for \"INT\"   data  (edge_profiles/midplane/index)                                   : "<< edge_profiles_1.midplane.index<<"\n";
    std::cout<<"Default value for \"FLOAT\"   data  (edge_profiles/vacuum_toroidal_field/vacuum_toroidal_field/r0) : "<< edge_profiles_1.vacuum_toroidal_field.r0<<"\n";
    std::cout<<"Default value for \"COMPLEX\" data                                                                 : "<< EMPTY_COMPLEX << "\n";
    std::cout<<"Default value for 1+ dimensional data                                                              : "<< edge_profiles_1.vacuum_toroidal_field.b0<<"\n";

}

// This example focuses on creating multi-dimensional arrays, using copmlex type and copying IDS structures
void copying_and_validating_ids()
{
    
    IdsNs::IDS::gyrokinetics_local gyrokinetics_local;

    // there is mandatory field <ids>/ids_properties/homogeneous_time
    gyrokinetics_local.ids_properties.homogeneous_time =  IDS_TIME_MODE_HOMOGENEOUS;

    // some IDS fields contain multi-dimensional arrays
    gyrokinetics_local.non_linear.fields_zonal_2d.phi_potential_perturbed_norm.resize(3,3);
    for(int x=0 ;x<3; x++){
        for(int y=0; y<3; y++){
            gyrokinetics_local.non_linear.fields_zonal_2d.phi_potential_perturbed_norm(x,y) = x+y;
        }
    }

    std::cout<<"Filled 2D array (gyrokinetics_local/non_linear/fields_zonal_2d/phi_potential_perturbed_norm): \n"<<gyrokinetics_local.non_linear.fields_zonal_2d.phi_potential_perturbed_norm<<"\n";
    
    // some fields have coordinates consistency. <isd>.validate() method checks for this consistency.
    // example of field of this type is gyrokinetics_local/non_linear/fields_zonal_2d/phi_potential_perturbed_norm
    // it's first dimension size must be equal to non_linear/radial_wavevector_norm size and second dimension size equal to non_linear/time_norm

    try{
        gyrokinetics_local.validate();
    }
    catch (IdsNs::ValidationException ve){
        std::cout << "Caught exception (raised intentionally):\n"<<ve.what() << std::endl;
    }

    // to fix this
    gyrokinetics_local.non_linear.radial_wavevector_norm.resize(3);
    gyrokinetics_local.non_linear.time_norm.resize(3);
 
    for(int i=0;i<3;i++){
        gyrokinetics_local.non_linear.radial_wavevector_norm(i) = i;
        gyrokinetics_local.non_linear.time_norm(i) = i;
    }

    //gyrokinetics_local/linear.wavevector(i1)/eigenmode(i2)/fields.phi_potential_perturbed_norm has two dimensions and stores complex numbers
    gyrokinetics_local.linear.wavevector.resize(1);
    gyrokinetics_local.linear.wavevector(0).eigenmode.resize(1);
    gyrokinetics_local.linear.wavevector(0).eigenmode(0).fields.phi_potential_perturbed_norm.resize(3,3);
    gyrokinetics_local.linear.wavevector(0).eigenmode(0).time_norm.resize(3);
    for(int i=0;i<3;i++){
        gyrokinetics_local.linear.wavevector(0).eigenmode(0).time_norm(i) = i;
    }

    for(int x=0 ;x<3; x++){
        for(int y=0; y<3; y++){
            gyrokinetics_local.linear.wavevector(0).eigenmode(0).fields.phi_potential_perturbed_norm(x,y) = complex<double>((double)x,(double)y);
        }
    }
    gyrokinetics_local.linear.wavevector(0).eigenmode(0).angle_pol.resize(3);
    for(int i=0;i<3;i++){
        gyrokinetics_local.linear.wavevector(0).eigenmode(0).angle_pol(i) = i;
    }

    // IDS copy can be created by putting it to the memory backend and getting it again
    IdsNs::IDS::gyrokinetics_local gyrokinetics_copy;
    IdsNs::IDS ids;

    // create memory backend Data Entry and associate the gyrokinetics_local IDSs
    ids.open("imas:memory?path=/", FORCE_CREATE_PULSE);
    gyrokinetics_local.setPulseCtx(ids.getPulseCtx());
    gyrokinetics_copy.setPulseCtx(ids.getPulseCtx());

    // copy the IDS through the memory backend
    gyrokinetics_local.put();
    gyrokinetics_copy.get();

    for(int x=0 ;x<3; x++){
        for(int y=0; y<3; y++){
                gyrokinetics_copy.linear.wavevector(0).eigenmode(0).fields.phi_potential_perturbed_norm(x,y) = complex<double>((double)-x,(double)-y);
            }
    }

    std::cout<<"Original value:\n" <<gyrokinetics_local.linear.wavevector(0).eigenmode(0).fields.phi_potential_perturbed_norm<<"\n";
    std::cout<<"Copied value:\n"<<gyrokinetics_copy.linear.wavevector(0).eigenmode(0).fields.phi_potential_perturbed_norm<<"\n";

}
