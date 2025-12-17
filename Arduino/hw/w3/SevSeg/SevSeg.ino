#include "SevSeg.h"
#include "TimerOne.h"

SevSeg sevseg;
byte numDigits = 4;
byte digitPins[] = { 1, 3, 12, 13 };
byte segmentPins[] = { 7, 6, 5, 10, 11, 8, 9, 4 };
byte hardwareConfig = COMMON_CATHODE;
int numToShow = 0;

const long interval = 100000;
void setup() {
  sevseg.begin(hardwareConfig, numDigits, digitPins, segmentPins);
  Timer1.initialize(interval);
  Timer1.attachInterrupt(Isr);
}
void Isr()
{
  numToShow++;
  if(numToShow > 9999)
  {
    numToShow = 0;
    sevseg.setNumber(numToShow, 1);
  }
}
void loop() {
  sevseg.refreshDisplay();
}
