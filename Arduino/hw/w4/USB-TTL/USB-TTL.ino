#include"Arduino.h"
#include"HardwareSerial.h"

void setup() {
  Serial.begin(9600);
}

void loop() {
  if(Serial.available())
  {
    String ch = Serial.readString();
    Serial.print(ch);
  }
}
