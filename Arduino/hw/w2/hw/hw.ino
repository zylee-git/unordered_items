#include<Servo.h>
Servo MyServo;
int R = A0;
int G = A1;
int B = A2;
int TrgPin = 3;
int EcoPin = 2;
float dist;
const int theta = 30;

void setup() {
  Serial.begin(9600);
  pinMode(R, OUTPUT);
  pinMode(G, OUTPUT);
  pinMode(B, OUTPUT);
  pinMode(TrgPin, OUTPUT);
  pinMode(EcoPin, INPUT);
  MyServo.attach(7);
}

void loop() {
  digitalWrite(TrgPin, LOW);
  delayMicroseconds(2);
  digitalWrite(TrgPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(TrgPin, LOW);
  dist = pulseIn(EcoPin, HIGH) / 58.00;  // 测量距离dist(cm)
  if(dist > 10)  // 大于10cm，亮绿灯，舵机转动指定角度
  {
    digitalWrite(R, LOW);
    digitalWrite(G, HIGH);
    MyServo.write(theta);
    delay(100);
  }
  else  // 小于10cm，红灯闪烁，舵机转动90度
  {
    MyServo.write(90);
    digitalWrite(G, LOW);
    digitalWrite(R, HIGH);
    delay(500);
    digitalWrite(R, LOW);
    delay(100);
  }
}