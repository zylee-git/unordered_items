#include<Servo.h>
Servo MyServo;

void setup() {
  Serial.begin(9600);
  MyServo.attach(7);
}

void loop() {
  MyServo.write(0);
  delay(1000);
  MyServo.write(90);
  delay(1000);
  MyServo.write(180);
  delay(1000);
  MyServo.write(90);
  delay(1000);
}
