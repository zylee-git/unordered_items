const int R=5;
const int G=6;
const int B=7;

void setup() {
  pinMode(R,INPUT);
  pinMode(G,INPUT);
  pinMode(B,INPUT);
  digitalWrite(R,LOW);
  digitalWrite(G,LOW);
  digitalWrite(B,LOW);
}

void loop() {
  digitalWrite(R,HIGH);
  digitalWrite(G,LOW);
  digitalWrite(B,LOW);
  delay(1000);
  digitalWrite(G,HIGH);
  digitalWrite(R,LOW);
  digitalWrite(B,LOW);
  delay(1000);
  digitalWrite(B,HIGH);
  digitalWrite(R,LOW);
  digitalWrite(G,LOW);
  delay(1000);
}
