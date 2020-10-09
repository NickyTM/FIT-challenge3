#include <CapacitiveSensor.h>

CapacitiveSensor   cs_4_2 = CapacitiveSensor(4, 2);

boolean game_started = false;
float flexMean;
float touchMean;
float flexThreshold = 500; //if flex is bent
float touchThreshold = 30; //if cap is touch
int pose = 0;
int vibrationPins[] = {8, 9, 10};
int outputPins[] = {8, 9, 10, 11, 12};
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600); //data to serial monitor
  //input
  pinMode(A2, INPUT_PULLUP);

  //output
  pinMode(8, OUTPUT); //vibration motor
  pinMode(9, OUTPUT); //vibration motor
  pinMode(10, OUTPUT); //vibration motor
  pinMode(11, OUTPUT); //led red
  pinMode(12, OUTPUT); //led green

  cs_4_2.set_CS_AutocaL_Millis(0xFFFFFFFF);

}

void loop() {
  // put your main code here, to run repeatedly:

  //debugValues();
  
  if (Serial.available() != 0) {
    byte data = Serial.read();
    Serial.println(data);
    if (data == '0') {
      gameTurn();
    }
    else if (data < 52 && data > 48 && pose > 0) { //data comes in as ASCII code
      calculateWinner(pose, data - 48); //in ASCII 48 = 0
    }
  }


}

void gameTurn() {
  digitalWrite(8, HIGH);
  delay(1000);
  digitalWrite(9, HIGH);
  delay(1000);
  digitalWrite(10, HIGH);
  delay (1000);
  digitalWrite(8, LOW);
  digitalWrite(9, LOW);
  digitalWrite(10, LOW);
  delay(500);
  while (pose < 1) {
    collectData();
    pose = computeSign();
    Serial.println(pose);
  }
  delay(500);
  //}
}

void collectData() {
  float flexTotal = 0;
  float touchTotal = 0;
  for (int i = 0; i < 100; i++) {
    flexTotal += analogRead(A2);
    touchTotal += cs_4_2.capacitiveSensor(30);
    delay(10);
  }
  flexMean = flexTotal / 100;
  touchMean = touchTotal / 100;
}

int computeSign() {
  boolean flexActive = flexMean < flexThreshold;
  boolean touchActive = touchMean < touchThreshold;

  if (flexActive && touchActive) {
    return 1; //rock
  } else if (!flexActive && !touchActive) {
    return 2; //paper
  } else if (!flexActive && touchActive) {
    return 3; //scissors
  } else {
    // return 0;
  }
}

void calculateWinner(int myPose, byte opponentInput) {
  if (myPose == 1 && opponentInput == 2) {
    // rock lost from paper
    digitalWrite(8, HIGH);
    digitalWrite(9, HIGH);
    digitalWrite(11, HIGH);
    digitalWrite(10, LOW);
    digitalWrite(12, LOW);
  } else if (myPose == 2 && opponentInput == 1 ) {
    // Paper won from rock
    winnerAction();
  } else if (myPose == 2 && opponentInput == 3 ) {
    // Paper lost from scissors
    digitalWrite(8, HIGH);
    digitalWrite(9, LOW);
    digitalWrite(10, HIGH);
    digitalWrite(11, HIGH);
    digitalWrite(12, LOW);

  } else if (myPose == 3 && opponentInput == 2 ) {
    //Scissors won from paper
    winnerAction();
  } else if (pose == 3 && opponentInput == 1 ) {
    // Scissors lost from rock
    digitalWrite(8, LOW);
    digitalWrite(9, HIGH);
    digitalWrite(10, LOW);
    digitalWrite(11, HIGH);
    digitalWrite(12, LOW);
  } else if (myPose == 1 && opponentInput == 3 ) {
    // Rock won from scissors
    winnerAction();
  } else {
    tieAction();
  }
  delay(1000);
  digitalWrite(8, LOW);
  digitalWrite(9, LOW);
  digitalWrite(10, LOW);
  digitalWrite(11, LOW);
  digitalWrite(12, LOW);
  pose = 0;
}

void winnerAction() {
  digitalWrite(12, HIGH);
  for (int i = 0; i <= sizeof(vibrationPins); i++) {
    digitalWrite(vibrationPins[i], LOW);
  }
  delay (1000);
  digitalWrite(12, LOW);
  delay (2000);
}

void tieAction() {
  for (int j = 0; j < 3; j++) {
    for (int i = 8; i <= 12; i++) {
      digitalWrite(i, HIGH);
    }
    delay (1000);
    for (int i = 8; i <= 12; i++) {
      digitalWrite(i, LOW);
    }
    delay(1000);
  }
}

void debugValues() {
  Serial.print("cap ");
  Serial.println(cs_4_2.capacitiveSensor(30));
  Serial.print("flex ");
  Serial.println(analogRead(A2));
  delay(100);
}
