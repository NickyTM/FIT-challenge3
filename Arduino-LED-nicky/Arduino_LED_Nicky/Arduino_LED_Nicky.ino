int red = 11; // the pin the LED is connected to
int green = 12; //
void setup() {
  pinMode(red, OUTPUT); // Declare the LED as an output
  pinMode(green, OUTPUT); 
}

void loop() {
  digitalWrite(red, HIGH); // Turn the LED on
  digitalWrite(green, HIGH);
}
