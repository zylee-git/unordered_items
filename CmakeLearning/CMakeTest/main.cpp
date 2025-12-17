#include "calculate.hpp"
#include "hello.hpp"
#include <iostream>

int main()
{
    HELLO hello;
    hello.say_hello();

    CALCULATE<int> calc;
    int a = 10, b = 5;
    std::cout << "Addition: " << calc.add(a, b) << std::endl;
    std::cout << "Subtraction: " << calc.subtract(a, b) << std::endl;
    std::cout << "Multiplication: " << calc.multiply(a, b) << std::endl;

    return 0;
}