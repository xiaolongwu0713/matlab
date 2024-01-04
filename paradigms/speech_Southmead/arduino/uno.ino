const int pin = A2;
const int outPin = 2;
int prev_val = 0;
int thresh = 1400; //280;

uint8_t state = 0;
uint32_t paus = 500000;//0.5s
uint32_t pause_time = 0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  pinMode(pin,INPUT);
  pinMode(2, OUTPUT);

  pinMode(5, OUTPUT); 
  delay(1000);

  digitalWrite(5, HIGH);
}

void loop() {
  // put your main code here, to run repeatedly:
  uint16_t val = analogRead(pin);
  if (state == 0) {
    if (val > thresh) {
      digitalWrite(outPin, HIGH);
      pause_time = micros();
      state = 1;
    }
  } 
  else {
    if (micros() - pause_time >= paus) {
      digitalWrite(outPin, LOW);
      state = 0;
      //delay(500);
    }
  }
  prev_val = val;
  Serial.println(prev_val);
}
