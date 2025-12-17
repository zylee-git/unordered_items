#include "SevSeg.h"
#include "TimerOne.h"

const int Rx = 0, Ry = 1, SW = 2;
SevSeg sevseg;
byte numDigits = 4;
byte digitPins[] = { 1, 5, 6, 13 };
byte segmentPins[] = { 3, 7, 11, 10, 8, 4, 12, 9 };
byte hardwareConfig = COMMON_CATHODE;
int numToShow = 0;
int x, y, sw;

const long interval = 10000;
void setup() {
  Serial.begin(9600);
  sevseg.begin(hardwareConfig, numDigits, digitPins, segmentPins);
  Timer1.initialize(interval);
  Timer1.attachInterrupt(timer_Isr);
  pinMode(SW, INPUT_PULLUP);
  attachInterrupt(0, outer_Isr, FALLING);
}
void timer_Isr()
{
  numToShow++;
  if(numToShow > 9999)
  {
    numToShow = 0;
  }
  sevseg.setNumber(numToShow, 2);
}
void outer_Isr()
{
  numToShow = 0;
  sevseg.setNumber(numToShow, 2);
}
void blank()
{
}
void loop() {
  x = analogRead(Rx);
  y = analogRead(Ry);
  sw = digitalRead(SW);
  sevseg.refreshDisplay();
  if(x > 900)
  {
    Timer1.attachInterrupt(blank);
  }
  if(y > 900)
  {
    Timer1.attachInterrupt(timer_Isr);
  }
}
