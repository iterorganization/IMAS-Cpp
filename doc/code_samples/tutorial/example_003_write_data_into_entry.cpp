#include "ALClasses.h"
#include <string>


using namespace IdsNs;

// This example focuses on putting IDS into entry and passing IDS validation
void put_entire_ids()
{
    IdsNs::IDS ids;
    int status = ids.open("imas:mdsplus?path=./testdb_mdsplus",FORCE_CREATE_PULSE);

    IdsNs:IDS::equilibrium  equilibrium;

    // set mandatory field
    equilibrium.ids_properties.homogeneous_time = IDS_TIME_MODE_HOMOGENEOUS;

    // when ids_properties.homogeneous_time is set to IDS_TIME_MODE_HOMOGENEOUS,
    // all time-dependent fields values correspond to <ids>.time vector.
    equilibrium.time.resize(3);
    for(int i=0; i<3; i++){
        equilibrium.time(i) = i;
    }


    equilibrium.setPulseCtx(ids.getPulseCtx());
    
    equilibrium.vacuum_toroidal_field.b0.resize(3);
    for(int i=0; i<3; i++){
        equilibrium.vacuum_toroidal_field.b0(i) = i;
    }

    equilibrium.put();

    // NOTE: some IDS fields are put automatically by Access Layer. Examples of this type of fields are:
    // - <ids>/ids_properties/version_put/data_dictionary
    // - <ids>/ids_properties/version_put/access_layer
    // - <ids>/ids_properties/version_put/access_layer_language

    //IDSs can be printed using std::cout
    std::cout << "Pritnting equilibrium:                         " << std::endl;
    std::cout << "equilibrium.ids_properties.homogeneous_time: \n" << equilibrium.ids_properties.homogeneous_time  << std::endl;
 	std::cout << "equilibrium.time:                            \n" << equilibrium.time  << std::endl;
    std::cout << "equilibrium.vacuum_toroidal_field.b0:        \n" << equilibrium.vacuum_toroidal_field.b0  << std::endl;

}

// This example focuses on putting multiple slices of IDS into entry
void put_slice()
{

    IdsNs::IDS ids;
    int status = ids.open("imas:mdsplus?path=./testdb_mdsplus",FORCE_CREATE_PULSE);

    IdsNs::IDS::summary summary;

    summary.ids_properties.homogeneous_time = IDS_TIME_MODE_HOMOGENEOUS;
    summary.heating_current_drive.nbi.resize(1);
    summary.setPulseCtx(ids.getPulseCtx());
    for(int i=0; i<5; i++){
        // NOTE: time-independent data is being put only if it is empty in entry
        // In this case summary/stationary_phase_flag/source will be put only at first iteration.
        // Suggested way to fill this type of fields is to do this outside loop
        summary.stationary_phase_flag.source = "Name saved by example code iteration: " + std::to_string(i);
        
        // Fill example data
        summary.stationary_phase_flag.value.resize(1);
        summary.stationary_phase_flag.value(0) = 10*i;

        // Fill 2D data
        summary.heating_current_drive.nbi(0).beam_current_fraction.value.resize(3,1);
        for(int i=0;i<3;i++){
                summary.heating_current_drive.nbi(0).beam_current_fraction.value(i,0) = 100*i;
        }

        // NOTE: it is user's responsibility to organize <ids>/time field in ascending manner
        // breaking this rule will make get_slice() command to fail
        // slice time is being appended to <ids>/time stored in entry
        summary.time.resize(1);
        summary.time(0) = i;
        summary.putSlice();
    }

    // multiple slices can be put into entry as well
    summary.stationary_phase_flag.value.resize(3);
    for(int i=0; i<3; i++){
        summary.stationary_phase_flag.value(i) = 11+i;
    }
    summary.heating_current_drive.nbi(0).beam_current_fraction.value.resize(3,3);
    for(int i=0; i<3; i++){
        for(int j=0; j<3; j++){
            summary.heating_current_drive.nbi(0).beam_current_fraction.value(i,j) = 1000+1000*i;
        }
    }
    summary.time.resize(3);
    for(int i=0;i<3;i++){
        summary.time(i) = 50+10*i;
    }
    summary.putSlice();


    //IDSs can be printed using std::cout
    std::cout << "Pritnting summary:                                                  " << std::endl;
    std::cout << "summary.ids_properties.homogeneous_time:                          \n" << summary.ids_properties.homogeneous_time  << std::endl;
 	std::cout << "summary.time:                                                     \n" << summary.time  << std::endl;
    std::cout << "summary.heating_current_drive.nbi(0).beam_current_fraction.value: \n" << summary.heating_current_drive.nbi(0).beam_current_fraction.value  << std::endl;
    std::cout << "summary.stationary_phase_flag.value:                              \n" << summary.stationary_phase_flag.value  << std::endl;

}

// This example focuses on putting IDS into another occurrence
void put_into_non_default_occurrence()
{

    IdsNs::IDS ids;
    int status = ids.open("imas:mdsplus?path=./testdb_mdsplus",FORCE_CREATE_PULSE);

    // default occurrence for get/put is 0
    // list of available occurrences can be found inside Data Dictionary documentation.
    IdsNs:IDS::equilibrium  equilibrium;

    // set mandatory field
    equilibrium.ids_properties.homogeneous_time = IDS_TIME_MODE_HOMOGENEOUS;
    equilibrium.ids_properties.comment = "comment";

    // when ids_properties.homogeneous_time is set to IDS_TIME_MODE_HOMOGENEOUS,
    // all time-dependent fields values correspond to <ids>.time vector.
    equilibrium.time.resize(3);
    for(int i=0; i<3; i++){
        equilibrium.time(i) = i+1;
    }

    // fill fields with some data
    equilibrium.vacuum_toroidal_field.r0 = 2.5;
    equilibrium.vacuum_toroidal_field.b0.resize(3);

    for(int i=0; i<3; i++){
        equilibrium.vacuum_toroidal_field.b0(i) = 10+10*i;
    }
    
    equilibrium.setPulseCtx(ids.getPulseCtx());

    // put IDS into occurrence 1
    equilibrium.put(1);

    // modify data, so differences between occurrences can be spotted
    equilibrium.vacuum_toroidal_field.r0 = 25.5;
    equilibrium.vacuum_toroidal_field.b0.resize(3);
    for(int i=0; i<3; i++){
    equilibrium.vacuum_toroidal_field.b0(i) = 11+11*i;
    }

    // put IDS into occurrence 2
    equilibrium.put(2);

    // NOTE: there is ids_properties/occurrence_type structure
    // it stores additional information about specific occurrence

    //IDSs can be printed using std::cout
    std::cout << "Pritnting equilibrium:                         " << std::endl;
    std::cout << "equilibrium.ids_properties.homogeneous_time: \n" << equilibrium.ids_properties.homogeneous_time  << std::endl;
 	std::cout << "equilibrium.time:                            \n" << equilibrium.time  << std::endl;
    std::cout << "equilibrium.vacuum_toroidal_field.b0:        \n" << equilibrium.vacuum_toroidal_field.b0  << std::endl;
    std::cout << "equilibrium.vacuum_toroidal_field.r0:        \n" << equilibrium.vacuum_toroidal_field.r0  << std::endl;
    std::cout << "equilibrium.ids_properties.comment           \n" << equilibrium.ids_properties.comment << std::endl;

    std::vector<string> node_content_list;
    std::vector<int> occurrence_list;

    status = IdsNs::IDS::list_all_occurrences(ids.getPulseCtx(), "equilibrium", "ids_properties/comment", node_content_list, occurrence_list);
    
    // occurrences can be listed with list_all_occurrences() function
    // list_all_occurrences also returns content of IDS pointed by node_path argument
    // node_path should be a path to a String type node
     if (status==0){
        for (int i = 0; i < node_content_list.size(); i ++){
            std::cout << i << " " << occurrence_list[i] << " " << node_content_list[i] << std::endl;
        }
     }

}