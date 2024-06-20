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
}

void loop() {

Serial.println("1");
delay(1000);
digitalWrite(outPin, LOW);
delay(1000);

} 
