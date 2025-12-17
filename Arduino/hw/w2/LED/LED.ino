#include <Arduino.h>

int R = 5;
int G = 6;
int B = 7;

void setup() {
  Serial.begin(9600);
  pinMode(R, OUTPUT);
  pinMode(G, OUTPUT);
  pinMode(B, OUTPUT);
}

void loop() {
  digitalWrite(R, HIGH);
  delay(300);
  digitalWrite(R, LOW);
  digitalWrite(G, HIGH);
  delay(300);
  digitalWrite(G, LOW);
  digitalWrite(B, HIGH);
  delay(300);
  digitalWrite(B, LOW);
}
