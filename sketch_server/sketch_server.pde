//server //<>// //<>// //<>//


import processing.serial.*;
import websockets.*;

WebsocketServer ws;

Serial myPort;  // The serial port
boolean arduinoEnabled = false; // For debugging purposes with only 1 arduino

String inString; //input we give
String outString; //output we write

void setup() {

  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  if (arduinoEnabled) {
    myPort = new Serial(this, Serial.list()[1], 9600);
    myPort.bufferUntil('\n'); //buffer untill carriage return is found
  }
  size(500, 500);
  // Starts a myServer on port 5204
  ws= new WebsocketServer(this, 8025, "/itech");
}

void draw() {
background(255);
fill(250,153,153);
circle(width/2, height/2, 300);
fill(255);
textSize(80);
text("START", 125, 280);
}

void serialEvent(Serial myPort) {

  //put the incoming data into a String - the '\n' is our end delimiter indicating the end of a complete packet
  inString = myPort.readStringUntil('\n');
  //make sure our data isn't empty before continuing
  if (inString != null) { 
    //trim whitespace and formatting characters (like carriage return)
    inString = trim(inString);
    //write to client(s)
    ws.sendMessage(inString);
   // println(inString);
  }
}

void webSocketServerEvent(String whatClientSaid) {
  if (whatClientSaid != null && whatClientSaid != outString) { // do not store null, handshake or exactly the data we have

    outString = whatClientSaid;
    println("Client: "+outString);
    if (arduinoEnabled) {
      myPort.write(outString);
    }
  }
}

void mouseClicked() {
  if (arduinoEnabled) {
    println("Game started!");
    myPort.write("0");
  }
  ws.sendMessage("0");
}

void keyPressed() {
  println("key: "+key);
  if (key=='r') {
    ws.sendMessage("1");
    println("Sending message");
  } else if (key=='p') {
    ws.sendMessage("2");
  } else if (key=='s') {
    ws.sendMessage("3");
  }
}
