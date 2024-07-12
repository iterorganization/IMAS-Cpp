#include "example_001_open_database.cpp"
#include "example_002_fill_data_in_ids.cpp"

#include "example_004_read_data_from_entry.cpp"
int main(int argc, char *argv[])
{
    //example001
    create_db_entry_legacy();
    open_db_entry_uri();
    create_db_entry_uri_with_path();

    //example002
    creating_completly_new_ids();
    default_values_and_aos_operations();
    copying_and_validating_ids();

    //example003
    //example004
    read_entire_ids();
    read_slice();

    return 0;
}