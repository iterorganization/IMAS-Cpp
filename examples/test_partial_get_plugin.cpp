#include <stdlib.h>
#include "ALClasses.h"

#include <blitz/array.h>
using namespace blitz;

#define ASSERTIONS_MAX 100

#define PARTIAL_GET "partial_get"
using namespace IdsNs;

void save_data(const char* uri);
void execute(char** argv);
void exitIfError(al_status_t &status);
void runTest(IdsNs::IDS &data_entry, IDS::core_profiles &ids, const std::string &includes_request, const std::string &excludes_request);
int checkAssertions(int test_number, const std::string &request, bool (&assertion)[ASSERTIONS_MAX], int count);


void execute(char** argv) {
  char uri[]="imas:hdf5?path=./test_db_test_core_profiles";
  save_data(uri);
  IdsNs::IDS data_entry;

  data_entry.open(uri, OPEN_PULSE);
  IDS::core_profiles ids = data_entry._core_profiles;

  bool assertion[ASSERTIONS_MAX];
  double epsilon = std::numeric_limits<double>::epsilon();
  int successfull = 1;
  int test_index = 0;

  std::string request = "ids_properties";


  runTest(data_entry, ids, request, "");

  
  //TEST1
  assertion[0] = ids.ids_properties.comment.length() != 0;
  assertion[1] = ids.profiles_1d.size() == 0;

  successfull *= checkAssertions(++test_index, request, assertion, 2); 
  printf("Partial plugin test %d completed with %d assertions.\n", test_index, 5);

  //TEST2
  request = "profiles_1d(:)";
  runTest(data_entry, ids, request, "");
  assertion[0] = ids.ids_properties.comment.length() == 0;
  assertion[1] = ids.profiles_1d.size() == 10;
  for (int i = 0; i < 10; i++)
     assertion[i + 2] = false;
  if (assertion[1]) {
  for (int i = 0; i < ids.profiles_1d.size(); i++)
     assertion[i + 2] = ids.profiles_1d(i).time == (double) i + 1.0;
  }

  successfull *= checkAssertions(++test_index, request, assertion, 12); 
  printf("Partial plugin test %d completed with %d assertions.\n", test_index, 12);

  //TEST3
  request = "profiles_1d(1:5:1)";
  runTest(data_entry, ids, request, "");
  assertion[0] = ids.ids_properties.comment.length() == 0;
  assertion[1] = ids.profiles_1d.size() == 10;

  for (int i = 0; i < 10; i++)
     assertion[i + 2] = false;
  if (assertion[1]) {
    for (int i = 0; i < ids.profiles_1d.size() - 5; i++)
      assertion[i + 2] = ids.profiles_1d(i).time == (double) (i) + 1.0;
    for (int i = 0; i < ids.profiles_1d.size() - 5; i++)
      assertion[i + 7] = std::abs(ids.profiles_1d(i+5).time + 9e40) < epsilon;
  }

  successfull *= checkAssertions(++test_index, request, assertion, 12); 
  printf("Partial plugin test %d completed with %d assertions.\n", test_index, 12);

  //TEST4
  request = "profiles_1d(1:5:1)";
  runTest(data_entry, ids, request, "profiles_1d(2)");
  assertion[0] = ids.ids_properties.comment.length() == 0;
  assertion[1] = ids.profiles_1d.size() == 10;
  for (int i = 0; i < 10; i++)
     assertion[i + 2] = false;
  if (assertion[1]) {
    assertion[2] = ids.profiles_1d(0).time == (double) 0 + 1.0;
    assertion[3] = std::abs(ids.profiles_1d(1).time + 9e40) < epsilon;
    assertion[4] = ids.profiles_1d(2).time == (double) 2 + 1.0;
    assertion[5] = ids.profiles_1d(3).time == (double) 3 + 1.0;
    assertion[6] = ids.profiles_1d(4).time == (double) 4 + 1.0;
    for (int i = 0; i < 5; i++)
      assertion[i + 7] = std::abs(ids.profiles_1d(i+5).time + 9e40) < epsilon;
  }

  successfull *= checkAssertions(++test_index, request, assertion, 12); 
  printf("Partial plugin test %d completed with %d assertions.\n", test_index, 12);

  //TEST5
  request = "profiles_1d(:)";
  runTest(data_entry, ids, request, "profiles_1d(2)");
  assertion[0] = ids.ids_properties.comment.length() == 0;
  assertion[1] = ids.profiles_1d.size() == 10;
  for (int i = 0; i < 10; i++)
     assertion[i + 2] = false;
  if (assertion[1]) {
    assertion[2] = ids.profiles_1d(0).time == (double) 0 + 1.0;
    assertion[3] = std::abs(ids.profiles_1d(1).time + 9e40) < epsilon;
    for (int i = 0; i < ids.profiles_1d.size() - 2; i++)
      assertion[i + 4] = ids.profiles_1d(i + 2).time == (double) (i + 2) + 1.0;
  }

  successfull *= checkAssertions(++test_index, request, assertion, 12); 
  printf("Partial plugin test %d completed with %d assertions.\n", test_index, 12);

  //TEST6
  request = "ids_properties;profiles_1d(1:5:2)";
  runTest(data_entry, ids, request, "profiles_1d(2)");
  assertion[0] = ids.ids_properties.comment.length() != 0;
  assertion[1] = ids.profiles_1d.size() == 10;
  for (int i = 0; i < 10; i++)
     assertion[i + 2] = false;
  if (assertion[1]) {
    assertion[2] = ids.profiles_1d(0).time == (double) 0 + 1.0;
    assertion[3] = std::abs(ids.profiles_1d(1).time + 9e40) < epsilon;
    assertion[4] = ids.profiles_1d(2).time == (double) 2 + 1.0;
    assertion[5] = std::abs(ids.profiles_1d(3).time + 9e40) < epsilon;
    assertion[6] = ids.profiles_1d(4).time == (double) 4 + 1.0;
    for (int i = 0; i < 5; i++)
      assertion[i + 7] = std::abs(ids.profiles_1d(i+5).time + 9e40) < epsilon;
  }

  successfull *= checkAssertions(++test_index, request, assertion, 12); 
  printf("Partial plugin test %d completed with %d assertions.\n", test_index, 12);

  //TEST7
  request = "profiles_1d(1:5:2)/ion(3)";
  runTest(data_entry, ids, request, "");
  assertion[0] = ids.ids_properties.comment.length() == 0;
  assertion[1] = ids.profiles_1d.size() == 10;

  if (assertion[1]) {
    assertion[2] = ids.profiles_1d(0).ion.size() == 1;
    assertion[3] = ids.profiles_1d(1).ion.size() == 0;
    assertion[4] = ids.profiles_1d(2).ion.size() == 3;
    assertion[5] = ids.profiles_1d(3).ion.size() == 0;
    assertion[6] = ids.profiles_1d(4).ion.size() == 5;
  }

  assertion[7] = ids.profiles_1d(0).ion(0).state.size() == 0;
  assertion[8] = ids.profiles_1d(2).ion(0).state.size() == 0;
  assertion[9] = ids.profiles_1d(2).ion(0).state.size() == 0;
  assertion[10] = ids.profiles_1d(2).ion(1).state.size() == 0;
  assertion[11] = ids.profiles_1d(2).ion(1).state.size() == 0;

  assertion[12] = ids.profiles_1d(2).ion(2).state.size() == 10;

  assertion[13] = false;
  assertion[14] = false;

  if (assertion[12]) {
    assertion[13] = ids.profiles_1d(2).ion(2).state(5).z_min == 5;
    assertion[14] = ids.profiles_1d(2).ion(2).state(6).z_min == 6;
  }

  assertion[15] = ids.profiles_1d(4).ion(0).state.size() == 0;
  assertion[16] = ids.profiles_1d(4).ion(0).state.size() == 0;
  assertion[17] = ids.profiles_1d(4).ion(1).state.size() == 0;
  assertion[18] = ids.profiles_1d(4).ion(1).state.size() == 0;

  assertion[19] = false;
  assertion[20] = false;

  if (ids.profiles_1d(4).ion(2).state.size() == 10) {
    assertion[19] = ids.profiles_1d(4).ion(2).state(5).z_min == 5;
    assertion[20] = ids.profiles_1d(4).ion(2).state(6).z_min == 6;
  }

  assertion[21] = ids.profiles_1d(4).ion(3).state.size() == 0;
  assertion[22] = ids.profiles_1d(4).ion(3).state.size() == 0;
  assertion[23] = ids.profiles_1d(4).ion(4).state.size() == 0;
  assertion[24] = ids.profiles_1d(4).ion(4).state.size() == 0;

  for (int i = 0; i < ids.profiles_1d.size(); i++) 
     assertion[i + 25] = std::abs(ids.profiles_1d(i).time + 9e40) < epsilon;

  successfull *= checkAssertions(++test_index, request, assertion, 34); 
  printf("Partial plugin test %d completed with %d assertions.\n", test_index, 34);

  //TEST8
  request = "profiles_1d(1:5:2)/ion(3);profiles_1d(1:5:2)/ion(1)";
  runTest(data_entry, ids, request, "");
  assertion[0] = ids.ids_properties.comment.length() == 0;
  assertion[1] = ids.profiles_1d.size() == 10;

  if (assertion[1]) {
    assertion[2] = ids.profiles_1d(0).ion.size() == 1;
    assertion[3] = ids.profiles_1d(1).ion.size() == 0;
    assertion[4] = ids.profiles_1d(2).ion.size() == 3;
    assertion[5] = ids.profiles_1d(3).ion.size() == 0;
    assertion[6] = ids.profiles_1d(4).ion.size() == 5;
  }

  assertion[7] = ids.profiles_1d(0).ion(0).state.size() == 10;
  assertion[8] = ids.profiles_1d(2).ion(0).state.size() == 10;
  assertion[9] = ids.profiles_1d(2).ion(0).state.size() == 10;

  assertion[10] = ids.profiles_1d(2).ion(1).state.size() == 0;
  assertion[11] = ids.profiles_1d(2).ion(1).state.size() == 0;
  assertion[12] = ids.profiles_1d(2).ion(2).state.size() == 10;

  assertion[13] = false;
  assertion[14] = false;

  if (assertion[12]) {
    assertion[13] = ids.profiles_1d(2).ion(2).state(5).z_min == 5;
    assertion[14] = ids.profiles_1d(2).ion(2).state(6).z_min == 6;
  }

  assertion[15] = ids.profiles_1d(4).ion(0).state.size() == 10;
  assertion[16] = ids.profiles_1d(4).ion(0).state.size() == 10;
  assertion[17] = ids.profiles_1d(4).ion(1).state.size() == 0;
  assertion[18] = ids.profiles_1d(4).ion(1).state.size() == 0;

  assertion[19] = false;
  assertion[20] = false;

  if (ids.profiles_1d(4).ion(2).state.size() == 10) {
    assertion[19] = ids.profiles_1d(4).ion(2).state(5).z_min == 5;
    assertion[20] = ids.profiles_1d(4).ion(2).state(6).z_min == 6;
  }

  assertion[21] = ids.profiles_1d(4).ion(3).state.size() == 0;
  assertion[22] = ids.profiles_1d(4).ion(3).state.size() == 0;
  assertion[23] = ids.profiles_1d(4).ion(4).state.size() == 0;
  assertion[24] = ids.profiles_1d(4).ion(4).state.size() == 0;

  for (int i = 0; i < ids.profiles_1d.size(); i++) 
     assertion[i + 25] = std::abs(ids.profiles_1d(i).time + 9e40) < epsilon;

  successfull *= checkAssertions(++test_index, request, assertion, 34); 
  printf("Partial plugin test %d completed with %d assertions.\n", test_index, 34);

  //TEST9
  request = "profiles_1d(1:5:2)/ion(3);profiles_1d(1:5:2)/time";
  runTest(data_entry, ids, request, "");
  assertion[0] = ids.ids_properties.comment.length() == 0;
  assertion[1] = ids.profiles_1d.size() == 10;

  if (assertion[1]) {
    assertion[2] = ids.profiles_1d(0).ion.size() == 1;
    assertion[3] = ids.profiles_1d(1).ion.size() == 0;
    assertion[4] = ids.profiles_1d(2).ion.size() == 3;
    assertion[5] = ids.profiles_1d(3).ion.size() == 0;
    assertion[6] = ids.profiles_1d(4).ion.size() == 5;
  }

  assertion[7] = ids.profiles_1d(0).ion(0).state.size() == 0;
  assertion[8] = ids.profiles_1d(2).ion(0).state.size() == 0;
  assertion[9] = ids.profiles_1d(2).ion(0).state.size() == 0;
  assertion[10] = ids.profiles_1d(2).ion(1).state.size() == 0;
  assertion[11] = ids.profiles_1d(2).ion(1).state.size() == 0;

  assertion[12] = ids.profiles_1d(2).ion(2).state.size() == 10;

  assertion[13] = false;
  assertion[14] = false;

  if (assertion[12]) {
    assertion[13] = ids.profiles_1d(2).ion(2).state(5).z_min == 5;
    assertion[14] = ids.profiles_1d(2).ion(2).state(6).z_min == 6;
  }

  assertion[15] = ids.profiles_1d(4).ion(0).state.size() == 0;
  assertion[16] = ids.profiles_1d(4).ion(0).state.size() == 0;
  assertion[17] = ids.profiles_1d(4).ion(1).state.size() == 0;
  assertion[18] = ids.profiles_1d(4).ion(1).state.size() == 0;

  assertion[19] = false;
  assertion[20] = false;

  if (ids.profiles_1d(4).ion(2).state.size() == 10) {
    assertion[19] = ids.profiles_1d(4).ion(2).state(5).z_min == 5;
    assertion[20] = ids.profiles_1d(4).ion(2).state(6).z_min == 6;
  }

  assertion[21] = ids.profiles_1d(4).ion(3).state.size() == 0;
  assertion[22] = ids.profiles_1d(4).ion(3).state.size() == 0;
  assertion[23] = ids.profiles_1d(4).ion(4).state.size() == 0;
  assertion[24] = ids.profiles_1d(4).ion(4).state.size() == 0;

  assertion[25] = ids.profiles_1d(0).time == (double) (0) + 1.0;
  assertion[26] = ids.profiles_1d(2).time == (double) (2) + 1.0;
  assertion[27] = ids.profiles_1d(4).time == (double) (4) + 1.0;
  assertion[28] = std::abs(ids.profiles_1d(1).time + 9e40) < epsilon;
  assertion[29] = std::abs(ids.profiles_1d(3).time + 9e40) < epsilon;
  assertion[30] = std::abs(ids.profiles_1d(5).time + 9e40) < epsilon;
  assertion[31] = std::abs(ids.profiles_1d(6).time + 9e40) < epsilon;

  successfull *= checkAssertions(++test_index, request, assertion, 32); 
  printf("Partial plugin test %d completed with %d assertions.\n", test_index, 32);

   //TEST10
  request = "ids_properties;profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time";
  runTest(data_entry, ids, request, "");
  assertion[0] = ids.ids_properties.comment.length() != 0;
  assertion[1] = ids.profiles_1d.size() == 10;

  assertion[2] = ids.profiles_1d(0).ion.size() == 1;
  assertion[3] = ids.profiles_1d(1).ion.size() == 2;
  assertion[4] = ids.profiles_1d(2).ion.size() == 3;
  assertion[5] = ids.profiles_1d(3).ion.size() == 4;
  assertion[6] = ids.profiles_1d(4).ion.size() == 5;

  for (int i = 0; i < 5; i++) 
     assertion[i + 7] = ids.profiles_1d(i+5).ion.size() == 0;

  for (int i = 0; i < ids.profiles_1d.size(); i++) 
      assertion[i + 12] = ids.profiles_1d(i).time == double (i) + 1.0;
  
  successfull *= checkAssertions(++test_index, request, assertion, 21); 
  printf("Partial plugin test %d completed with %d assertions.\n", test_index, 21);

  //TEST11
  request = "ids_properties;profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time";
  runTest(data_entry, ids, request, "profiles_1d(2:3:1);profiles_1d(5)/ion(1)");

  assertion[0] = ids.ids_properties.comment.length() != 0;
  assertion[1] = ids.profiles_1d.size() == 10;

  assertion[2] = ids.profiles_1d(0).ion.size() == 1;
  assertion[3] = ids.profiles_1d(1).ion.size() == 0;
  assertion[4] = ids.profiles_1d(2).ion.size() == 0;
  assertion[5] = ids.profiles_1d(3).ion.size() == 4;
  assertion[6] = ids.profiles_1d(4).ion.size() == 5;

  assertion[7] = std::abs(ids.profiles_1d(1).time + 9e40) < epsilon;
  assertion[8] = std::abs(ids.profiles_1d(2).time + 9e40) < epsilon;

  assertion[9] = ids.profiles_1d(0).time ==  1.0;
  assertion[11] = ids.profiles_1d(3).time == 4.0;
  assertion[12] = ids.profiles_1d(4).time == 5.0;
  assertion[13] = ids.profiles_1d(5).time == 6.0;
  assertion[14] = ids.profiles_1d(6).time == 7.0;

  assertion[15] = ids.profiles_1d(3).ion(0).state(5).z_min == 5;
  assertion[16] = ids.profiles_1d(3).ion(0).state(6).z_min == 6;
  assertion[17] = ids.profiles_1d(4).ion(0).state.size() == 0;

  successfull *= checkAssertions(++test_index, request, assertion, 17); 

  printf("Partial plugin test %d completed with %d assertions.\n", test_index, 17);

  request = "";
  runTest(data_entry, ids, request, "");

  //TEST12
  assertion[0] = ids.ids_properties.comment.length() != 0;
  assertion[1] = ids.profiles_1d.size() == 10;
  for (int i = 0; i < 10; i++)
     assertion[i + 2] = false;
  if (assertion[1]) {
  for (int i = 0; i < ids.profiles_1d.size(); i++)
     assertion[i + 2] = ids.profiles_1d(i).time == (double) i + 1.0;
  }

  successfull *= checkAssertions(++test_index, request, assertion, 12); 
  printf("Partial plugin test %d completed with %d assertions.\n", test_index, 12);
  
  
  //TEST13
  request = "profiles_1d(1:5:2)/ion(:);profiles_1d(1:5:2)/time";
  runTest(data_entry, ids, request, "");
  assertion[0] = ids.ids_properties.comment.length() == 0;
  assertion[1] = ids.profiles_1d.size() == 10;

  if (assertion[1]) {
    assertion[2] = ids.profiles_1d(0).ion.size() == 1;
    assertion[3] = ids.profiles_1d(1).ion.size() == 0;
    assertion[4] = ids.profiles_1d(2).ion.size() == 3;
    assertion[5] = ids.profiles_1d(3).ion.size() == 0;
    assertion[6] = ids.profiles_1d(4).ion.size() == 5;
  }

  assertion[7] = ids.profiles_1d(0).ion(0).state.size() == 10;
  assertion[8] = ids.profiles_1d(2).ion(0).state.size() == 10;
  assertion[9] = ids.profiles_1d(4).ion(0).state.size() == 10;
  assertion[10] = ids.profiles_1d(2).ion(1).state.size() == 10;
  assertion[11] = ids.profiles_1d(4).ion(1).state.size() == 10;
  assertion[12] = ids.profiles_1d(2).ion(2).state.size() == 10;

  assertion[13] = false;
  assertion[14] = false;

  if (assertion[12]) {
    assertion[13] = ids.profiles_1d(4).ion(2).state(5).z_min == 5;
    assertion[14] = ids.profiles_1d(4).ion(2).state(6).z_min == 6;
  }

  assertion[15] = ids.profiles_1d(4).ion(2).state.size() == 10;
  assertion[16] = ids.profiles_1d(4).ion(3).state.size() == 10;
  assertion[17] = ids.profiles_1d(4).ion(4).state.size() == 10;

  assertion[18] = false;
  assertion[19] = false;

  if (ids.profiles_1d(4).ion(3).state.size() == 10) {
    assertion[18] = ids.profiles_1d(4).ion(3).state(5).z_min == 5;
    assertion[19] = ids.profiles_1d(4).ion(3).state(6).z_min == 6;
  }

  assertion[20] = ids.profiles_1d(0).time == (double) (0) + 1.0;
  assertion[21] = ids.profiles_1d(2).time == (double) (2) + 1.0;
  assertion[22] = ids.profiles_1d(4).time == (double) (4) + 1.0;
  assertion[23] = std::abs(ids.profiles_1d(3).time + 9e40) < epsilon;
  assertion[25] = std::abs(ids.profiles_1d(5).time + 9e40) < epsilon;
  assertion[26] = std::abs(ids.profiles_1d(6).time + 9e40) < epsilon;

  successfull *= checkAssertions(++test_index, request, assertion, 27); 
  printf("Partial plugin test %d completed with %d assertions.\n", test_index, 27);

  request = "profiles_1d(:)";
  runTest(data_entry, ids, request, "profiles_1d(:)");

  //TEST14
  assertion[0] = ids.ids_properties.comment.length() == 0;
  assertion[1] = ids.profiles_1d.size() == 0;

  successfull *= checkAssertions(++test_index, request, assertion, 2); 
  printf("Partial plugin test %d completed with %d assertions.\n", test_index, 12);

    //TEST15
  request = "profiles_1d(1:5)";
  runTest(data_entry, ids, request, "");
  assertion[0] = ids.ids_properties.comment.length() == 0;
  assertion[1] = ids.profiles_1d.size() == 10;

  for (int i = 0; i < 10; i++)
     assertion[i + 2] = false;
  if (assertion[1]) {
    for (int i = 0; i < ids.profiles_1d.size() - 5; i++)
      assertion[i + 2] = ids.profiles_1d(i).time == (double) (i) + 1.0;
    for (int i = 0; i < ids.profiles_1d.size() - 5; i++)
      assertion[i + 7] = std::abs(ids.profiles_1d(i+5).time + 9e40) < epsilon;
  }

  successfull *= checkAssertions(++test_index, request, assertion, 12); 
  printf("Partial plugin test %d completed with %d assertions.\n", test_index, 12);


  //TEST16
  request = "profiles_1d(1:5)";
  runTest(data_entry, ids, request, "profiles_1d(1:2)");
  assertion[0] = ids.ids_properties.comment.length() == 0;
  assertion[1] = ids.profiles_1d.size() == 10;

  for (int i = 0; i < 10; i++)
     assertion[i + 2] = false;
  if (assertion[1]) {
    for (int i = 2; i < ids.profiles_1d.size() - 5; i++)
      assertion[i] = ids.profiles_1d(i).time == (double) (i) + 1.0;

     for (int i = 0; i < 2; i++)
      assertion[i + 5] = std::abs(ids.profiles_1d(i).time + 9e40) < epsilon;
    
    for (int i = 0; i < ids.profiles_1d.size() - 5; i++)
      assertion[i + 7] = std::abs(ids.profiles_1d(i+5).time + 9e40) < epsilon;
  }

  successfull *= checkAssertions(++test_index, request, assertion, 12); 
  printf("Partial plugin test %d completed with %d assertions.\n", test_index, 12);

  printf("----------------------------------------\n\n");


  if (successfull == 1) {
    printf("Partial get plugin tests successfull.\n");
  }
  else {
    printf("ERROR: Partial get plugin tests have failed.\n");
  }

  data_entry.close();
}

int checkAssertions(int test_number, const std::string &request, bool (&assertion)[ASSERTIONS_MAX], int count) {
  int successfull = 1;
  for (int i = 0; i < count; i++) {
    if (!assertion[i]) {
      printf("Assertion #%d failed for test %d (request=%s)\n", i, test_number, request.c_str());
      successfull = 0;
    }
  }
  return successfull;
}

void runTest(IdsNs::IDS &data_entry, IDS::core_profiles &ids, const std::string &includes_request, const std::string &excludes_request) {
  al_status_t status = al_register_plugin(PARTIAL_GET);
  exitIfError(status);
  int size = includes_request.length();
  status = al_setvalue_parameter_plugin("includes", CHAR_DATA, 1, &size, (void *) includes_request.data(), PARTIAL_GET);
  exitIfError(status);

  size = excludes_request.length();
  status = al_setvalue_parameter_plugin("excludes", CHAR_DATA, 1, &size, (void *) excludes_request.data(), PARTIAL_GET);
  exitIfError(status);

   //Use for debugging purposes only
  status = al_setvalue_int_scalar_parameter_plugin("debug", 1, PARTIAL_GET);
  exitIfError(status);
  status = al_setvalue_int_scalar_parameter_plugin("debug_read_requests_only", 1, PARTIAL_GET);
  exitIfError(status);

  status = al_bind_plugin("core_profiles:0/*", PARTIAL_GET);
  ids.get(0);
  status = al_unregister_plugin(PARTIAL_GET);
  exitIfError(status);
}


void exitIfError(al_status_t &status) {
  if (status.code != 0) {
       printf("%s\n", status.message);
       exit(-1);
  }
}

int main(int argc, char** argv){
    execute(argv);
}

