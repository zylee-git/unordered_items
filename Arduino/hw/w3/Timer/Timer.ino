#include<TimerOne.h>
const long interval = 500000;  // 0.5s
int R = 5;
int G = 6;
int B = 7;
int cnt = 0;
void setup()
{
  pinMode(R, OUTPUT);
  pinMode(G, OUTPUT);
  pinMode(B, OUTPUT);
  digitalWrite(R, LOW);
  digitalWrite(G, LOW);
  digitalWrite(B, LOW);
  Timer1.initialize(interval);
  Timer1.attachInterrupt(Isr);
}

void Isr()
{
  if(cnt == 0)
  {
    digitalWrite(R, HIGH);
    digitalWrite(G, LOW);
    digitalWrite(B, LOW);
    cnt = 1;
  }
  else if(cnt == 1)
  {
    digitalWrite(R, HIGH);
    digitalWrite(G, HIGH);
    digitalWrite(B, LOW);
    cnt = 2;
  }
  else if(cnt == 2)
  {
    digitalWrite(R, LOW);
    digitalWrite(G, HIGH);
    digitalWrite(B, LOW);
    cnt = 3;
  }
  else if(cnt == 3)
  {
    digitalWrite(R, LOW);
    digitalWrite(G, HIGH);
    digitalWrite(B, HIGH);
    cnt = 4;
  }
  else if(cnt == 4)
  {
    digitalWrite(R, LOW);
    digitalWrite(G, LOW);
    digitalWrite(B, HIGH);
    cnt = 5;
  }
  else
  {
    digitalWrite(R, HIGH);
    digitalWrite(G, LOW);
    digitalWrite(B, HIGH);
    cnt = 0;
  }
}

void loop()
{
}
