#include "ALClasses.h"
using namespace IdsNs;

int main(int argc, char *argv[])
{
    float time = 0.2;
    int dynamicsize = 10;

    IdsNs::distributions_IDSBase dis;

    std::cout << "### validate distributions empty ids\n";
    try
    {
        dis.validate();
        std::cout << "Error. Test failed. Expected validation error not raised." << std::endl;

    }
    catch (IdsNs::ValidationException ve)
    {
            std::cout << "Test passed." << std::endl;
    }
    std::cout << std::endl;

    dis.ids_properties.homogeneous_time = 1;
    dis.time.resize(dynamicsize);
    for (int i = 0; i < dynamicsize; i++)
        dis.time(i) = 0.1 * i;
    dis.distribution.resize(1);
    dis.distribution(0).profiles_2d.resize(dynamicsize);
    for (int i = 0; i < dynamicsize; i++)
    {
        dis.distribution(0).profiles_2d(i).grid.r.resize(3);
        dis.distribution(0).profiles_2d(i).grid.z.resize(3);
        dis.distribution(0).profiles_2d(i).grid.theta_straight.resize(3);
        dis.distribution(0).profiles_2d(i).density.resize(3, 2);
    }

    std::cout << "### validate distributions alternatives coordinates issues\n";
    try
    {
        dis.validate();
        std::cout << "Error. Test failed. Expected validation error not raised." << std::endl;
    }
    catch (IdsNs::ValidationException ve)
    {
            std::cout << "Test passed." << std::endl;
    }
    std::cout << std::endl;

    for (int i = 0; i < dynamicsize; i++)
    {
        dis.distribution(0).profiles_2d(i).grid.theta_straight.resize(0);
    }
    std::cout << "### validate distributions alternatives coordinates issues\n";
    try
    {
        dis.validate();
        std::cout << "Error. Test failed. Expected validation error not raised." << std::endl;
    }
    catch (IdsNs::ValidationException ve)
    {
            std::cout << "Test passed." << std::endl;
    }
    std::cout << std::endl;

    for (int i = 0; i < dynamicsize; i++)
    {
        dis.distribution(0).profiles_2d(i).density.resize(3, 3);
    }
    std::cout << "### validate distributions alternatives coordinates issues fixed\n";
    try
    {
        dis.validate();
        std::cout << "Test passed." << std::endl;
    }
    catch (IdsNs::ValidationException ve)
    {
        std::cout << ve.what() << std::endl;
    }
    std::cout << std::endl;

    dis.distribution(0).ggd.resize(dynamicsize);
    for (int i = 0; i < dynamicsize; i++)
    {
        dis.distribution(0).ggd(i).grid.grid_subset.resize(3);
        for (int j = 0; j < 3; j++)
        {
            dis.distribution(0).ggd(i).grid.grid_subset(j).element.resize(3);
            dis.distribution(0).ggd(i).grid.grid_subset(j).base.resize(1);
            dis.distribution(0).ggd(i).grid.grid_subset(j).base(0).tensor_covariant.resize(3, 3, 5);
            dis.distribution(0).ggd(i).grid.grid_subset(j).base(0).tensor_contravariant.resize(3, 3, 3);
        }
    }

    std::cout << "### validate distributions multiple alternative coordinates same_as\n";
    try
    {
        dis.validate();
        std::cout << "Error. Test failed. Expected validation error not raised." << std::endl;
    }
    catch (IdsNs::ValidationException ve)
    {
            std::cout << "Test passed." << std::endl;
    }
    std::cout << std::endl;

    for (int i = 0; i < dynamicsize; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            dis.distribution(0).ggd(i).grid.grid_subset(j).base(0).tensor_contravariant.resize(3, 3, 5);
        }
    }

    std::cout << "### validate distributions multiple alternative coordinates same_as fixed\n";
    try
    {
        dis.validate();
        std::cout << "Test passed." << std::endl;
    }
    catch (IdsNs::ValidationException ve)
    {
        std::cout << ve.what() << std::endl;
    }
    std::cout << std::endl;

    dis.ids_properties.homogeneous_time = 0;
    dis.time.resize(0);
    dis.distribution(0).global_quantities.resize(dynamicsize);
    std::cout << "### validate distributions heterogeneous scalar time coordinate issue\n";
    try
    {
        dis.validate();
        std::cout << "Error. Test failed. Expected validation error not raised." << std::endl;
    }
    catch (IdsNs::ValidationException ve)
    {
        std::cout << "Test passed." << std::endl;
    }
    std::cout << std::endl;

    for (int i = 0; i < dynamicsize; i++)
    {
        dis.distribution(0).global_quantities(i).time = i*0.1;
        dis.distribution(0).profiles_2d(i).time = i*0.1;
        dis.distribution(0).ggd(i).time = i*0.1;
    }
    std::cout << "### validate distributions heterogeneous scalar time coordinate issue fixed\n";
    try
    {
        dis.validate();
        std::cout << "Test passed." << std::endl;
    }
    catch (IdsNs::ValidationException ve)
    {
        std::cout << ve.what() << std::endl;
    }
    std::cout << std::endl;

    return 0;
}
