#include <TimerOne.h>

int ENC_A = 2;  //电机的编码器A端
int ENC_B = 3;  //电机的编码器B端
int count = 0;  //上升沿（脉冲）数量
int PWM = 6;
int IN1 = 10;
int IN2 = 11;

float err = 0, derr = 0, dderr = 0;
float Kp = 0.3, Ki = 0.6, Kd = 0.7;
float rpm;
float goal = 150;
int pwm;

void setup() {
  Serial.begin(9600);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(PWM, OUTPUT);
  pinMode(ENC_A, INPUT);
  pinMode(ENC_B, INPUT);
  attachInterrupt(0, Count0, CHANGE);
  attachInterrupt(1, Count1, CHANGE);
  Timer1.initialize(50000);
  Timer1.attachInterrupt(TimerIsr);
}

void loop() {
}

int PID(float goal, float now) {
  dderr = goal - now - err - derr;
  derr = goal - now - err;
  err = goal - now;
  float dPWM = Ki * (err) + Kp * (derr) + Kd * (dderr);
  return (int)dPWM;
}

void Count0() {
  if (digitalRead(ENC_A) == LOW)  // A为下降沿
  {
    if (digitalRead(ENC_B) == LOW)  // 正转
    {
      count += 1;
    }
    if (digitalRead(ENC_B) == HIGH)  // 反转
    {
      count -= 1;
    }
  } else  // A为上升沿
  {
    if (digitalRead(ENC_B) == HIGH)  // 正转
    {
      count += 1;
    }
    if (digitalRead(ENC_B) == LOW)  // 反转
    {
      count -= 1;
    }
  }
}

void Count1() {
  if (digitalRead(ENC_B) == LOW)  // B为下降沿
  {
    if (digitalRead(ENC_A) == HIGH)  // 正转
    {
      count += 1;
    }
    if (digitalRead(ENC_A) == LOW)  // 反转
    {
      count -= 1;
    }
  } else  // B为上升沿
  {
    if (digitalRead(ENC_A) == LOW)  // 正转
    {
      count += 1;
    }
    if (digitalRead(ENC_A) == HIGH)  // 反转
    {
      count -= 1;
    }
  }
}

void TimerIsr() {
  rpm = count / 4 * 60.0 / 13.0;
  count = 0;
  pwm += PID(goal, rpm);
  if (abs(pwm) > 255)  //防止pwm超过0-255范围
  {
    if (pwm < 0) {
      pwm = -255;
    } else {
      pwm = 255;
    }
  }
  if (pwm < 0)  //处理目标转速为负数时情况
  {
    digitalWrite(IN1, LOW);  //反转
    digitalWrite(IN2, HIGH);
    pwm = -pwm;
  } else {
    digitalWrite(IN1, HIGH);  //正转
    digitalWrite(IN2, LOW);
  }
  analogWrite(PWM, pwm);
  Serial.print("goal:");
  Serial.print(goal);
  Serial.print(" rpm:");
  Serial.println(rpm);
}