const int outPin = 2;
int prev_val = 0;
int LEDPin = 4;

#define THRESHOLD .15

int thresh = 100;//(int)(THRESHOLD / (3.3 / 4095.0));

uint8_t state = 0;
uint32_t pause = 200000;
uint32_t pause_time = 0;

uint32_t loop_time = 0;
uint32_t count = 0;

static __inline__ void syncADC() __attribute__((always_inline, unused));
static void syncADC() {
  while (ADC->STATUS.bit.SYNCBUSY == 1);
}

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  loop_time = millis();

  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(2, OUTPUT);
  pinMode(5, OUTPUT);
  

  ADC->SAMPCTRL.reg = 0x00; //TODO: change to 0x3F (max sample time) and see if taking longer to sample gives us a cleaner wave
  syncADC();

  ADC->CTRLB.bit.PRESCALER = 0x03;
  syncADC();
  // setup adc
  ADC->INPUTCTRL.bit.MUXPOS = g_APinDescription[A2].ulADCChannelNumber;
  syncADC();
  ADC->CTRLA.bit.ENABLE = 1;
  syncADC();

  ADC->AVGCTRL.reg = ADC_AVGCTRL_ADJRES(4) | ADC_AVGCTRL_SAMPLENUM_128;
  syncADC();

  //convert
  
  ADC->SWTRIG.bit.START = 1;
 
  while(ADC->INTFLAG.bit.RESRDY == 0);

  ADC->INTFLAG.reg = ADC_INTFLAG_RESRDY;

  // we do one coversion as the fiest is always a dud post a mux switch
  loop_time = millis();

  digitalWrite(5, HIGH);
}




void loop() {
  
  ADC->SWTRIG.bit.START = 1;
 
  while(ADC->INTFLAG.bit.RESRDY == 0);

  ADC->INTFLAG.reg = ADC_INTFLAG_RESRDY;

  uint16_t val = ADC->RESULT.reg;
  // if (val > thresh)
  Serial.println(val);
}
