
/*
Continuous Streaming Code
*/

//=======================
// Set the protocol name
char protocolName[] = "Continuous"; // should be less than 20 characters
unsigned long beginLoopTime;
unsigned long loopTime;
//=======================

//=======================
// set pin numbers for relevant inputs and outputs:
int analogPins[] = {0,1,2,3};
int digitalPins[] = {4,5,6,7,8,41,43,45,36,38,39,40};
//=======================

//=======================
// Arrays that will hold the current values of the AO and DIO
int CurrAIValue[] = {0,0,0,0};
int aiThresh[] = {512,512,512,512};
int bufferLength = 100;
int bufferEndIndex = bufferLength-1;
int frozen=0;
int first=0;
int bufferAI0[100];
int bufferAI1[100];
int bufferAI2[100];
int bufferAI3[100];
int bufferLoc = 0;
//=======================

//=======================
// PARAMETERS OF TASK
unsigned long interTrialInterval = 15000;
unsigned long stimDelay = 500;
unsigned long stimDuration = 500;
unsigned long valveOpenTime = 30;
unsigned long valveDelayTime = 1000;
unsigned long lastEvent = 0;
unsigned long IPI = 100;
int xCenter = 0;
int xWidth = 20;
int yCenter = 0;
int yWidth = 20;
int responseMode = 0;
//=======================

//=======================
// VARIABLES OF TASK
unsigned long time; // all values that will do math with time need to be unsigned long datatype
unsigned long crossTime = 0;
unsigned long rewardDelivered = 0;
boolean firstLickLogic = false;
unsigned long trialEnd = 0;
unsigned long trialStart = 0;
unsigned long firstLickTime = 0;
int ParadigmMode = 0;
int testMode = 0;
int jsZeroX = 512;
int jsZeroY = 512;
int xDisp = 0;
int yDisp=0;
int count = 0;
long displacement = 0;
unsigned long iteration = 1;
const int iterations = 100;
unsigned long times[5*iterations];
unsigned long analog0[iterations];
unsigned long analog1[iterations];
unsigned long analog2[iterations];
unsigned long analog3[iterations];
//=======================

//=======================
// PARAMETERS OF HARDWARE
int lThresh = 400;
//=======================

//=======================
// VARIABLES FOR SERIAL COM
int code = 0;
int assertPinNum = 0;
int assertPinState = 0;
//=======================

//==========================================================================================================================
// SETUP LOOP
//==========================================================================================================================
void setup() {
    
      //=======================
      // prep DIGITAL outs and ins
        pinMode(digitalPins[0], OUTPUT);
        pinMode(digitalPins[1], OUTPUT);
        pinMode(digitalPins[2], OUTPUT);
        pinMode(digitalPins[3], OUTPUT);
        pinMode(digitalPins[4], OUTPUT);
        pinMode(digitalPins[5], OUTPUT);
        pinMode(digitalPins[6], OUTPUT);
        pinMode(digitalPins[7], OUTPUT);
        digitalWrite(digitalPins[0], LOW);
        digitalWrite(digitalPins[1], LOW);
        digitalWrite(digitalPins[2], LOW);
        digitalWrite(digitalPins[3], LOW);        
        digitalWrite(digitalPins[4], LOW);        
        digitalWrite(digitalPins[5], LOW);        
        digitalWrite(digitalPins[6], LOW);        
        digitalWrite(digitalPins[7], LOW);        
      //=======================

      //=======================
      // prep ANALOG inputs
        analogReference(DEFAULT);
      //=======================
      
      //=======================
      // initialize the SERIAL communication
        Serial.begin(115200);
      //=======================
      
      count = 0; // initialize the trial counter
      
      //=======================
      // initialize analog read buffer
      for (int j=0;j<bufferLength;j++) {
        bufferAI0[j] = 0;
        bufferAI1[j] = 0;
        bufferAI2[j] = 0;
        bufferAI3[j] = 0;        
      }
      bufferLoc = 0;
      //=======================
      
      CurrAIValue[0] = analogRead(analogPins[0]);
      CurrAIValue[1] = analogRead(analogPins[1]);
      CurrAIValue[2] = analogRead(analogPins[2]);
      CurrAIValue[3] = analogRead(analogPins[3]);
      
}


//==========================================================================================================================
// MAIN EXECUTION LOOP
//==========================================================================================================================
void loop() {
  
      beginLoopTime = micros();
      time = millis();         

      if(frozen==0) {
          // Left shift the buffer
          for (int i=1;i<bufferLength;i++) {
            bufferAI0[i-1] = bufferAI0[i];
            bufferAI1[i-1] = bufferAI1[i];
          }
          
          bufferAI0[bufferEndIndex] = analogRead(analogPins[0]); // joystick x ... takes 110us
          bufferAI1[bufferEndIndex] = analogRead(analogPins[1]); // joystick y
      
          // this could be a more complicated function of past values (e.g. to implement a filter)      
          CurrAIValue[0] = bufferAI0[bufferEndIndex]; 
          CurrAIValue[1] = bufferAI1[bufferEndIndex];
      }
      
      switch (ParadigmMode) {
      
        case 0: // just idle in this state waiting for controller to start next trial
            break;
            
        case 1: // if controller tells you to start, then start      

            if (time >= lastEvent+IPI) {
              digitalWrite(digitalPins[0], HIGH); // pulse
              lastEvent = time;
            }

            if (time > trialStart+10000) {
              ParadigmMode = 0;
              // our end of trial code
              Serial.print(5);
              Serial.print(",");
              Serial.print("*");
            }
            
            break;
        
      }      
      
      if (Serial.available() > 0) {
    
        code = Serial.read();

        switch (code) {
        
          case 89: // stop execution
            ParadigmMode=0;
            Serial.print(3);
            Serial.print(",");     
            Serial.print("*");
           
            digitalWrite(digitalPins[0], LOW); // success event
            digitalWrite(digitalPins[1], LOW); // trial cue light
            digitalWrite(digitalPins[2], LOW); // performance cue light
            digitalWrite(digitalPins[3], LOW); // valve
            digitalWrite(digitalPins[4], LOW); // reset the lick indicator
            break;
            
        // all other codes are handshaking codes either requesting data or sending data 
          case 87:
            RunSerialCom(code); 
            break;
    
          case 88:
            RunSerialCom(code); 
            break;

          case 90:
            RunSerialCom(code); 
            break;
    
          case 91:
            RunSerialCom(code);
            break;
    
          case 92:
            RunSerialCom(code);
            break;
            
        }
        
        Serial.flush();
    
      }
    
    digitalWrite(digitalPins[0], LOW); // 
    digitalWrite(digitalPins[3], LOW); //  
    digitalWrite(digitalPins[1], LOW); // 
    digitalWrite(digitalPins[2], LOW); // 
    digitalWrite(digitalPins[4], LOW); // 
    digitalWrite(digitalPins[5], LOW); // 
    digitalWrite(digitalPins[6], LOW); // 
    digitalWrite(digitalPins[7], LOW); // 
    
    // pause until 1ms has elapsed without locking up the processor
      while(loopTime<1000 && loopTime>0) {
        loopTime = micros() - beginLoopTime;
      }
      loopTime = 1;    
}


