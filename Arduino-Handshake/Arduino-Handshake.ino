//////////////////////////////////////////////////////////////////////
//
// Based on code by Edwin Dertien
//
// A2: threshold      -> buzzer/speakr on 10
// A1: analog mapping -> servo on 9
// A0: toggle         -> neopixel on 11
//
///////////////////////////////////////////////////////////////////////

unsigned long looptime;
boolean state;
boolean released;

int pinA2ToD10;
int pinA1ToD09;
int pinA0ToD11;

void setup() {
  Serial.begin(9600);          // data to serial monitor/plotter
  //inputs:
  pinMode(A0,INPUT_PULLUP);  // when used with the bend-sensor
  pinMode(A1, INPUT_PULLUP);   // when used with the bend-sensor
  pinMode(A2, INPUT_PULLUP); // when used with the bend-sensor
  //
  //outputs:
  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
  pinMode(13, OUTPUT);        // for the internal LED

  establishContact(); //contact with processing via serial port
}

void loop() {

  if (millis() > looptime + 49) {
    looptime = millis();
    // toggle the on-board LED, 10Hz
    if (digitalRead(13)) digitalWrite(13, LOW);
    else digitalWrite(13, HIGH);

    if (Serial.available() > 0) {

      splitDataIn();

      delay(100);

    } else {
      //send
      Serial.print(analogRead(A2));
      Serial.print(',');
      Serial.print(analogRead(A1));
      Serial.print(',');
      Serial.print(analogRead(A0));
      Serial.println();

      delay(10);

    }

    //threshold
    if (pinA2ToD10 < 500) digitalWrite(10, HIGH);
    else digitalWrite(10, LOW);

    //map
    analogWrite(9, (map(pinA1ToD09, 0, 1023, 0, 255)));
  }

  //toggle
  if (pinA0ToD11 > 300 && state == 0 && released) {
    digitalWrite(11, HIGH);
    state = 1;
    released = 0;
  }
  if (state == 1 && pinA0ToD11 > 300 && released ) {
    digitalWrite(11, LOW);
    state = 0;
    released = 0;
  }
  if (pinA0ToD11 < 100) released = 1;
}


void establishContact() {
  while (Serial.available() <= 0) {
    Serial.println("A");   // send a capital A
    delay(300);
  }
}

void splitDataIn() {

  pinA2ToD10 = Serial.readStringUntil(',').toInt(); // writes in the string all the inputs till a comma
  pinA1ToD09 = Serial.readStringUntil(',').toInt();
  pinA0ToD11 = Serial.readStringUntil('\n').toInt(); // writes in the string all the inputs till the end of line character

}
