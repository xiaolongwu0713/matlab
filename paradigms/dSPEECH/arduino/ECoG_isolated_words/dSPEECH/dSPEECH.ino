const int outPin = 2;
int LEDPin = 5; 
uint8_t switchPin = A2; 

uint8_t state = 0;
uint32_t pause_period = 200000; // this impacts how often the button can be read, in microseconds
uint32_t pause_time = 0;

uint32_t loop_time = 0;
uint32_t count = 0;


void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  while(!Serial);
  loop_time = millis();

  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(outPin, OUTPUT);
  pinMode(LEDPin, OUTPUT);
  pinMode(switchPin, INPUT);

  digitalWrite(LEDPin, HIGH);
  digitalWrite(LED_BUILTIN, HIGH);
  digitalWrite(outPin, LOW);
}




void loop() {
	
  

  if (state == 0) {
    if (digitalRead(switchPin) == 0) {
      digitalWrite(outPin, HIGH);
      pause_time = micros();
      state = 1;
	    Serial.println("1");
    }
  } else if (state == 1) {
    if (micros() - pause_time >= pause_period) {
      digitalWrite(outPin, LOW);
      state = 2;
    }
  } else {
    if (digitalRead(switchPin) == 1) {
      state = 0;
    }
  }

  /*if (millis() - loop_time > 1000) {
    Serial.println(count);
    count = 0;
    loop_time = millis();
  }*/  
}
