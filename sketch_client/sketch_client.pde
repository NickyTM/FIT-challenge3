//client //<>// //<>//
import websockets.*;

WebsocketClient wsc;
import processing.serial.*;

boolean arduinoEnabled = true; // For debugging purposes with only 1 arduino
Serial myPort;

String inString;
String outString;

void setup() { 
  size(300, 600); 

  // List all the available serial ports
  printArray(Serial.list());

  // Open the port you are using at the rate you want:
  if (arduinoEnabled) {
    myPort = new Serial(this, Serial.list()[1], 9600);
    myPort.bufferUntil('\n'); //buffer untill carriage return is found
  }

  // Connect to the local machine at port 5204.

  wsc= new WebsocketClient(this, "ws://77.173.59.203:8025/itech"); //fill in correct IP adres when connecting your client to a server, this one is local
} 

void draw() {
} 

void serialEvent( Serial myPort) {
  //put the incoming data into a String - the '\n' is our end delimiter indicating the end of a complete packet
  inString = myPort.readStringUntil('\n');
  //make sure our data isn't empty before continuing
  if (inString != null) { 
    //trim whitespace and formatting characters (like carriage return)
    inString = trim(inString);
    //write to server
    wsc.sendMessage(inString);
  }
}


void webSocketEvent(String whatServerSaid) {
  if (whatServerSaid != null && whatServerSaid != outString) {

    outString = whatServerSaid;
    println("Server: " + outString);
    if (arduinoEnabled) {
      myPort.write(outString);
    }
  }
}

//click to start the game!

void mouseClicked() {
  if (arduinoEnabled) {
    myPort.write("0");
  }
  wsc.sendMessage("0");
}
//this is here for debugging!

void keyPressed() {
  println("key: "+key);
  if (key=='r') {
    wsc.sendMessage("1");
    println("Sending message");
  } else if (key=='p') {
    wsc.sendMessage("2");
  } else if (key=='s') {
    wsc.sendMessage("3");
  }
}
