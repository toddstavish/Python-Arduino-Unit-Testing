/*
Continuous Streaming Code
*/

//=======================
// VARIABLES OF TASK
//=======================
const int reads = 100;
unsigned long start;
unsigned long finish;
unsigned long analog0[reads];
unsigned long analog1[reads];
unsigned long analog2[reads];
unsigned long analog3[reads];

//==========================================================================================================================
// SETUP LOOP
//==========================================================================================================================
void setup() {

  analogReference(DEFAULT);
  Serial.begin(115200);  
      
}


//==========================================================================================================================
// MAIN EXECUTION LOOP
//==========================================================================================================================
void loop() {

  if (Serial.available() > 0)
  {  
    
    start = millis();
    for (int i=0 ; i<reads; i++)
    {
      analog0[i] = analogRead(0);
      analog1[i] = analogRead(1);
      analog2[i] = analogRead(2);
      analog3[i] = analogRead(3);
    }
    finish = millis();    

    Serial.print(start);
    Serial.print(",");     
    Serial.print(finish);
    
    Serial.flush();
  }

}
