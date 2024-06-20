int Relay = 7;
int command;
char rcv;
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(Relay, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:

  if(Serial.available()>0)
  {
    rcv=Serial.read();
    command=atoi(rcv);
    
    if(command==0)
    {
      digitalWrite (Relay, LOW);
      Serial.println("UP");
      delay(500);
      digitalWrite (Relay, HIGH);
      Serial.println("Down");
      
    }
    else if (command==1)
    {
      Serial.println("Idle.");
      
    }

  //Serial.println(command); 
  //Serial.write('\r');
 
  delay(1000);
  while (Serial.available()>0)   
      {
        Serial.read();
      } 

  }

  
}
