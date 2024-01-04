const int outPin = 2;
int prev_val = 0;
int LEDPin = 4;
char rcv;
int command;
#define THRESHOLD .15

int thresh = 280;//(int)(THRESHOLD / (3.3 / 4095.0));

uint8_t state = 0;
uint32_t pause = 200000;
uint32_t pause_time = 0;

uint32_t loop_time = 0;
uint32_t count = 0;


void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  loop_time = millis();

  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(2, OUTPUT);
  pinMode(5, OUTPUT);

  loop_time = millis();

  digitalWrite(5, HIGH);
}

void loop() {
   if(Serial.available()>0)
   {
    rcv=Serial.read();
    //Serial.println(rcv);
    //command=atoi(rcv);
    command=rcv - '0';
    if(command==0)
    {
      Serial.println("sending trigger");
      digitalWrite(outPin, HIGH); // switch on
      delay(500);
      digitalWrite(outPin, LOW); // switch off
      delay(500);
    }

   }
  

}
