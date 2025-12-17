const int Rx = 0, Ry = 1, SW = A2;
void setup() {
  Serial.begin(9600);
  pinMode(SW, INPUT_PULLUP);
}

void loop() {
  int x = analogRead(Rx);
  int y = analogRead(Ry);
  int sw = digitalRead(SW);
  Serial.print("x:");
  Serial.println(x);
  Serial.print("y:");
  Serial.println(y);
  Serial.print("sw:");
  Serial.println(sw);
  delay(1000);
}
