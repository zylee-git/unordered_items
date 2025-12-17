#include "Arduino.h"
#include "HardwareSerial.h"
#include "SoftwareSerial.h"
#include "U8glib.h"
#include "String.h"
U8GLIB_SSD1306_128X32 u8g(U8G_I2C_OPT_NONE);
SoftwareSerial softserial(7, 6);  // 设置软串口
String password("0000");          // 设定密码
String reset_password("9999");    // 设定重置密码

void setup() {
  softserial.begin(9600);
  Serial.begin(9600);
}

void loop() {
  if (Serial.available() && softserial.available()) {
    String input = softserial.readString();
    if (input == password) {
      Serial.print("pass\n");
      u8g.firstPage();
      do {
        u8g.setFont(u8g_font_unifont);
        u8g.drawStr(0, 32, "unlocked");
      } while (u8g.nextPage());
    } else if (input == reset_password) {
      u8g.firstPage();
      do {
        u8g.setFont(u8g_font_unifont);
        u8g.drawStr(0, 16, "locked");
      } while (u8g.nextPage());
    } else {
      Serial.print("fail\n");
      u8g.firstPage();
      do {
        u8g.setFont(u8g_font_unifont);
        u8g.drawStr(0, 16, "locked");
      } while (u8g.nextPage());
    }
  }
  delay(1000);
}
void draw(void) {
  // graphic commands to redraw the complete screen should be placed here
  u8g.setFont(u8g_font_unifont);
  //u8g.setFont(u8g_font_osb21);
  u8g.drawStr(0, 22, "Hello World!");
}
