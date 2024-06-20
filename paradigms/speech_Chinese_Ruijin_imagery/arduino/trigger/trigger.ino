// Define the pin connected to the wire
const int wirePin = 7;
// Define the pin connected to the LED (optional)
const int ledPin = 13;

void setup() {
  // Initialize the serial communication
  Serial.begin(9600);
  
  // Set the wire pin as input with internal pull-up resistor
  pinMode(wirePin, INPUT_PULLUP);
  
  // Set the LED pin as output (optional)
  pinMode(ledPin, OUTPUT);
}

void loop() {
  // Read the state of the wire pin
  int wireState = digitalRead(wirePin);
  
  // Check if the wire is connected or disconnected
  if (wireState == LOW) {
    // Wire is connected (pulls pin to GND)
    Serial.println("Wire is connected");
    // Turn on the LED (optional)
    digitalWrite(ledPin, HIGH);
    delay(1000);
  } else {
    // Wire is disconnected (pin is HIGH due to pull-up resistor)
    Serial.println("Wire is disconnected");
    // Turn off the LED (optional)
    digitalWrite(ledPin, LOW);
  }
  
  // Wait for a short period before checking again
  delay(50);
}
