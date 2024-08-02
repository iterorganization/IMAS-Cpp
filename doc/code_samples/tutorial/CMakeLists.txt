project( docExamples LANGUAGES CXX ) 

set(THREADS_PREFER_PTHREAD_FLAG ON)

# Build Documentation Examples 
################################################################################
add_executable( main example_001_open_database.cpp example_002_fill_data_in_ids.cpp example_003_write_data_into_entry.cpp example_004_read_data_from_entry.cpp test_new_examples.cpp )
target_link_libraries( main PUBLIC al-cpp )
target_link_libraries( main PUBLIC -pthread )