//server //<>//


import processing.serial.*;
import websockets.*;

WebsocketServer ws;


Serial myPort;  // The serial port


boolean firstContact = false;
boolean clientContact = false;

String inString; //input we give
String outString = "0,0,0"; //output we write

void setup() {

  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.bufferUntil('\n'); //buffer untill carriage return is found
  size(200, 200);
  // Starts a myServer on port 5204
  ws= new WebsocketServer(this, 8025, "/itech");

}

void draw() {



   

}

void serialEvent( Serial myPort) {
  println(firstContact);
  //put the incoming data into a String - 
  //the '\n' is our end delimiter indicating the end of a complete packet
  inString = myPort.readStringUntil('\n');
  //make sure our data isn't empty before continuing
  if (inString != null) { 
    //trim whitespace and formatting characters (like carriage return)
    inString = trim(inString);

    //look for our 'A' string to start the handshake
    //if it's there, clear the buffer, and send a request for data
    if (firstContact == false) {
      if (inString.equals("A")) {
        myPort.clear();
        firstContact = true;
        myPort.write("A");
        println("contact");
      }
    } else { //if we've already established contact, keep getting and parsing data

      //write to client(s)
      ws.sendMessage(inString);

      if (clientContact ==true) {
        myPort.write(outString);
        println("Client" + outString);
      }
    }
  }
}

void webSocketServerEvent(String whatClientSaid) {
  if (whatClientSaid != null && whatClientSaid != "A" && whatClientSaid != outString) { // do not store null, handshake or exactly the data we have

    outString = whatClientSaid;

    //if first contact with client set to true
    if (clientContact == false) {
      clientContact = true;
    }
  }
}
