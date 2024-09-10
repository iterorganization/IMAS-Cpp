// Definition of the class structures in file ALClasses.h
// This program gets data from the DB entry, just for practicing the AL GET command
// It servers also as a nested of 3 level nested AoS (type 3 at the top, type 2 below)
//
#include "ALClasses.h"
#include <vector>

using namespace IdsNs;

int execute_tests(BACKEND backend);

int main(int argc, char *argv[])
{
  int status = execute_tests(HDF5_BACKEND);
  if (status < 0) return status;
  //status = execute_tests(MDSPLUS_BACKEND);
  return status;
}

int execute_tests(BACKEND backend)
{
  printf("Running test for backend=%d\n", backend);
  int status, i, j, k;

  int pulse = 12;
  int run = 2;
  int interp = 2;

  char *userName = getenv("USER");

  if (userName == NULL)
  {
    printf("PANIC: $USER not found! Exiting...");
    exit(1);
  }

  const int N_time = 10;

  double time_1[] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0};

  IdsNs::IDS ids(pulse, run, 0, 0);
  ids.setBackend(backend);

  ids.createEnv(userName, "test", "3");
  ids._magnetics.ids_properties.homogeneous_time = 1;
  ids._magnetics.time.resize(N_time);
   for (i = 0; i < N_time; i++)
  {
    ids._magnetics.time(i) = time_1[i];
  }

  ids._magnetics.flux_loop.resize(1);
  ids._magnetics.flux_loop(0).flux.data.resize(10);

  std::vector<double> magnetics_flux_data;

  for (i = 0; i < N_time; i++)
  {
     ids._magnetics.flux_loop(0).flux.data(i) = 5. + (double) i;
     magnetics_flux_data.push_back( 5. + (double) i);
  }


  ids._core_profiles.ids_properties.homogeneous_time = 1;
  ids._core_profiles.time.resize(N_time);

  ids._core_profiles.profiles_1d.resize(N_time);

  for (i = 0; i < N_time; i++)
  {
    ids._core_profiles.time(i) = time_1[i];
  }
  
  int N = 2;

  std::vector<std::vector<double>> core_profiles_rho_tor_norm_data;
  std::vector<std::vector<double>> core_profiles_t_i_average_data;

  for (i = 0; i < N_time; i++) {
    ids._core_profiles.profiles_1d(i).grid.rho_tor_norm.resize(N);
    ids._core_profiles.profiles_1d(i).t_i_average.resize(N);
    core_profiles_rho_tor_norm_data.push_back(std::vector<double>());
    core_profiles_t_i_average_data.push_back(std::vector<double>());
    for (j = 0; j < N; j++) {
      ids._core_profiles.profiles_1d(i).grid.rho_tor_norm(j) = 3. + (double) j;
      core_profiles_rho_tor_norm_data.back().push_back(3. + (double) j);
      ids._core_profiles.profiles_1d(i).t_i_average(j) = 8. + (double) j;
      core_profiles_t_i_average_data.back().push_back(8. + (double) j);

    }
  }

  ids._magnetics.put();
  ids._core_profiles.put();

  ids.close();
  ids.openEnv(userName, "test", "3"); //Open the database
  ids.setBackend(backend);
  std::vector<double> dtime;

  double tmin = 3.;
  double tmax = 6.;

  int expected_start_index = 2;
  int expected_stop_index = 5;

  //Testing getSample() on a magnetics IDS with limited time range
  status = ids._magnetics.getSample(0, tmin, tmax, dtime, 0);

  if (ids._magnetics.flux_loop(0).flux.data.size() != (tmax - tmin + 1)) {
    printf("Test 1 has failed, unexpected number of dynamic 1D values (from static AOS) in the limited time range.\n");
    return -1;
  }

  for (i = expected_start_index; i < expected_stop_index + 1; i++) {
    if (ids._magnetics.flux_loop(0).flux.data(i - expected_start_index) != magnetics_flux_data[i]) {
      printf("Test 2 has failed, unexpected dynamic 1D values (from static AOS) in the limited time range.\n");
      return -1;
    }
  }

  //Testing getSample() on a core_profiles IDS with limited time range
  status = ids._core_profiles.getSample(0, tmin, tmax, dtime, 0);

  if (ids._core_profiles.profiles_1d.size() != (tmax - tmin + 1)) {
    printf("Test 3 has failed, unexpected number of dynamic 1D values (from dynamic AOS) in the limited time range.\n");
    return -1;
  }

  for (i = expected_start_index; i < expected_stop_index + 1; i++) {
    std::vector<double> &v = core_profiles_rho_tor_norm_data[i];
    for (j = 0; j < N; j++) {
      if (ids._core_profiles.profiles_1d(i - expected_start_index).grid.rho_tor_norm(j) != v[j]) {
        printf("Test 4 has failed, unexpected dynamic 1D values (from dynamic AOS) in the limited time range.\n");
        return -1;
      }
    }
  }

  //Resampling
  double step = 0.2;
  double first_expected_value = 7.;
  int inerpolation_method = 1;
  int occurrence = 0;
  dtime.push_back(step);

  //Testing getSample() on a magnetics IDS with limited time range and resampling
  status = ids._magnetics.getSample(occurrence, tmin, tmax, dtime, inerpolation_method);

  if (ids._magnetics.flux_loop(0).flux.data.size() != ( (tmax - tmin)/step) ) {
      printf("Test 5 has failed, unexpected number of dynamic 1D values (from static AOS) in a limited time range with resampling.\n");
      return -1;
  }

  for (i = 0; i < (tmax - tmin)/step; i++) {
    if (i < 3) {
      if (ids._magnetics.flux_loop(0).flux.data(i) != first_expected_value) {
        printf("Test 6 has failed, unexpected dynamic 1D values (from static AOS) in a limited time range with resampling.\n");
        return -1;
      }
    }
    else if (i >= 3 && i < 8) {
      if (ids._magnetics.flux_loop(0).flux.data(i) != first_expected_value + 1) {
        printf("Test 7 has failed, unexpected dynamic 1D values (from static AOS) in a limited time range with resampling.\n");
        return -1;
      }
    }
    else if (i >= 8 && i < 13) {
      if (ids._magnetics.flux_loop(0).flux.data(i) != first_expected_value + 2) {
        printf("Test 8 has failed, unexpected dynamic 1D values (from static AOS) in a limited time range with resampling.\n");
        return -1;
      }
    }
    else if (i >= 13 && i < 15) {
      if (ids._magnetics.flux_loop(0).flux.data(i) != first_expected_value + 3) {
        printf("Test 9 has failed, unexpected dynamic 1D values (from static AOS) in a limited time range with resampling.\n");
        return -1;
      }
    }
  }

  dtime.clear();
  dtime.push_back(0.5);
  dtime.push_back(1.);
  dtime.push_back(1.5);
  dtime.push_back(1.7);
  dtime.push_back(11);

  status = ids._magnetics.getSample(0, tmin, tmax, dtime, 3);
  if (ids._magnetics.time.size() != 5) {
    printf("Test 10 has failed, unexpected number of time basis points using resampling with dtime.size() > 1.\n");
    return -1;
  }
  for (int i = 0; i < ids._magnetics.flux_loop.size(); i++) {
    //printf("ids._magnetics.flux_loop(%d).flux.data.size()=%d", i, ids._magnetics.flux_loop(i).flux.data.size())
    if (ids._magnetics.flux_loop(i).flux.data.size() != 5) {
      printf("Test 11 has failed, unexpected number of data points using resampling with dtime.size() > 1.\n");
      return -1;
    }
    for (int j = 0; j < ids._magnetics.flux_loop(i).flux.data.size(); j++) 
    {
      //printf("ids._magnetics.flux_loop(%d).flux.data(%d)=%f\n", i, j, ids._magnetics.flux_loop(i).flux.data(j));
      if ((j == 0 || j == 1) && ids._magnetics.flux_loop(i).flux.data(j) != 5.0) {
        printf("Test 12 has failed, unexpected number of data points using resampling with dtime.size() > 1.\n");
        return -1;
      }
      if (j == 2 && ids._magnetics.flux_loop(i).flux.data(j) != 5.5) {
        printf("Test 12 has failed, unexpected number of data points using resampling with dtime.size() > 1.\n");
        return -1;
      }
      if (j == 3 && ids._magnetics.flux_loop(i).flux.data(j) != 5.7) {
        printf("Test 12 has failed, unexpected number of data points using resampling with dtime.size() > 1.\n");
        return -1;
      }
      if (j == 4 && ids._magnetics.flux_loop(i).flux.data(j) != 14) {
        printf("Test 12 has failed, unexpected number of data points using resampling with dtime.size() > 1.\n");
        return -1;
      }
    }
  }

  printf("Time range feature (IMAS-3885) tests successfull from C++ HLI.\n");

  ids.close();
  return 0;
}