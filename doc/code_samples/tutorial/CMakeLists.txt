project( TestCpp LANGUAGES CXX ) 

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

find_package( PkgConfig REQUIRED )
pkg_check_modules( al-cpp REQUIRED IMPORTED_TARGET al-cpp)
pkg_check_modules( al-core REQUIRED IMPORTED_TARGET al-core )

add_executable( main example_001_open_database.cpp example_002_fill_data_in_ids.cpp example_003_write_data_into_entry.cpp example_004_read_data_from_entry.cpp test_new_examples.cpp )
target_link_libraries( main PkgConfig::al-cpp PkgConfig::al-core pthread)
target_link_libraries( main PRIVATE Threads::Threads)
