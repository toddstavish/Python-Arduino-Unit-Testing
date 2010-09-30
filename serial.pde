/*
General functions for the control of code based serial communication with the Arduino board
*/

//=======================
void RunSerialCom(int code) {
       
  switch (code) {
    
    case 87: // data has been requested
      // Current settings allow for 4 10-bit analog lines ("AO")
      delay(10);
      for (int i=0 ; i<iterations; i++) {
        times[i]=millis();
        analog0[i]=analogRead(0);
        analog1[i]=analogRead(1);
        analog2[i]=analogRead(2);
        analog3[i]=analogRead(3);
      }
      for (int i=0; i<iterations; i++) {
        Serial.print(iteration);
        Serial.print(",");     
        Serial.print(times[i]);
        Serial.print(",");
        Serial.print(analog0[i]);
        Serial.print(",");
        Serial.print(analog1[i]);
        Serial.print(",");
        Serial.print(analog1[i]);
        Serial.print(",");
        Serial.print(analog3[i]);
        Serial.print(",");    
        Serial.print("*");
        iteration++;
      }
      break;
      
    case 88: // trail ended and the trial details were requested              
      // tell the monitor about the trial details
      Serial.print(4);
      Serial.print(",");
      Serial.print(count);      
      Serial.print(",");
      Serial.print(trialStart);      
      Serial.print(",");
      Serial.print(crossTime);      
      Serial.print(",");
      Serial.print(trialEnd);      
      Serial.print(",");
      Serial.print(firstLickTime);      
      Serial.print(",");
      Serial.print("*");
      break;

    case 90: // start trial (i.e. need to read from the serial port)
      delay(10);
      interTrialInterval = readULongFromBytes();
      delay(10);
      stimDelay = readULongFromBytes();
      delay(10);
      stimDuration = readULongFromBytes();
      delay(10);
      xCenter = readIntFromBytes();
      delay(10);
      xWidth = readIntFromBytes();
      delay(10);
      yCenter = readIntFromBytes();
      delay(10);
      yWidth = readIntFromBytes();
      delay(10);
      valveOpenTime = readULongFromBytes();
      delay(10);
      valveDelayTime = readULongFromBytes();
      delay(10);
      responseMode = readIntFromBytes();
      delay(10);

      Serial.print(interTrialInterval, DEC);
	
      digitalWrite(digitalPins[0], LOW); // trial cue light
      digitalWrite(digitalPins[1], LOW); // success event
      digitalWrite(digitalPins[2], LOW); // performance cue light
      digitalWrite(digitalPins[3], LOW); // valve
      digitalWrite(digitalPins[4], LOW); // reset the lick indicator 

      // set the ParadigmMode to move into a trial
      ParadigmMode = 1;
      trialStart = time;
      
      break;
      
    case 91:
      Serial.print(6);
      Serial.print(",");
      Serial.print(protocolName);      
      Serial.print(",");
      Serial.print("*");
      break;
      
    case 92: // directly control the arduino pin settings
      // format is: read the code and if 92 read the next few values for updating of parameters from the BehaviorMonitor
      testMode=1;
      
      delay(10);
      assertPinNum = Serial.read();
      delay(10);
      assertPinState = Serial.read();
      delay(10);
      
      forcePin(assertPinNum,assertPinState);
      
      break;

  }
  
}
//=======================

//=======================
void forcePin(int assertPinNum, int assertPinState) {
  
  if (ParadigmMode==0) {
    if (assertPinState==0) {
      digitalWrite(assertPinNum, LOW);
    } else {
      digitalWrite(assertPinNum, HIGH);
    }
  }
}
//=======================

//=======================
int readIntFromBytes() {
  
  union u_tag {
    byte b[2];
    int ival;
  } u;

  u.b[0] = Serial.read();
  u.b[1] = Serial.read();
  
  return u.ival;
}
//=======================

//=======================
unsigned long readULongFromBytes() {
  
  union u_tag {
    byte b[4];
    unsigned long ulval;
  } u;

  u.b[0] = Serial.read();
  u.b[1] = Serial.read();
  u.b[2] = Serial.read();
  u.b[3] = Serial.read();

  return u.ulval;
}
//=======================
