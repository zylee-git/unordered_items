#include <iostream>
#include "process.hpp"
#include "show_result.hpp"

int main()
{
    std::cout << "planning start" << std::endl;
    Process pro;
    pro.planProcess();
    std::cout << "planning end" << std::endl;

    std::cout << "show result: " << std::endl;
    ShowResult show;
    show.drawResult();

    return 0;
}