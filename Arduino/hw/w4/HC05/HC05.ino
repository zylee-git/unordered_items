#include"Arduino.h"
#include"SoftwareSerial.h"
#include"String.h"
SoftwareSerial softserial(7, 6);  // 设置软串口
String password("0628");  // 设定密码

void setup() {
  softserial.begin(9600);
}

void loop() {
  if(softserial.available())
  {
    String input = softserial.readString();
    if(input == password) softserial.print("pass\n");
    else softserial.print("fail\n");
  }
  delay(1000);
}
