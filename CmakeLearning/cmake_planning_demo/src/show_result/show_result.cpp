#include <iostream>
#include "show_result.hpp"
#include <graphics.h>

void ShowResult::drawResult()
{
    initgraph(800, 600); // Initialize graphics window
    setbkcolor(WHITE);     // Set background color to white
    cleardevice();         // Clear the graphics window

    std::cout << "draw circles: " << std::endl;
    setlinecolor(BLACK);
    setlinestyle(PS_SOLID, 3);

    circle(400, 300, 150);
    circle(400, 300, 300);

    system("pause");
    closegraph(); // Close the graphics window
}