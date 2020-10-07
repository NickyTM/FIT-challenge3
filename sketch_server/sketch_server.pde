//server //<>// //<>// //<>//


import processing.serial.*;
import websockets.*;

WebsocketServer ws;


Serial myPort;  // The serial port


boolean firstContact = false;
boolean clientContact = false;
boolean serverWin = false;
boolean clientWin = false;
int FLEX_UPPER_LIMIT = 900;
int FLEX_LOWER_LIMIT  = 200;
int CAP_UPPER_LIMIT = 900;
int CAP_LOWER_LIMIT = 200;

String inString; //input we give
String outString = "0,0,0"; //output we write

void setup() {

  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  //myPort = new Serial(this, Serial.list()[1], 9600);
  // myPort.bufferUntil('\n'); //buffer untill carriage return is found
  size(200, 200);
  // Starts a myServer on port 5204
  ws= new WebsocketServer(this, 8025, "/itech");
}

void draw() {

  // calculateWinner();
  sendClient();
  //sendArduino();
}

String calculateSign(int flexSensor, int capSense) {
  boolean flexed = (flexSensor <= FLEX_UPPER_LIMIT && flexSensor >= FLEX_LOWER_LIMIT);
  boolean pressed = (capSense <= CAP_UPPER_LIMIT && capSense >= CAP_LOWER_LIMIT);
  if (flexed && pressed) {
    return "rock" ;
  } else if (!flexed && !pressed) {
    return "paper";
  } else if (!flexed && pressed) {
    return "scissors";
  } else {
    return "error";
  }
}

void calculateWinner(String clientInput, String serverInput) {

  if (clientInput == "rock" && serverInput == "paper") {
    serverWin=true;
    clientWin=false;
  } else if (clientInput == "paper" && serverInput == "rock" ) {
    serverWin=false;
    clientWin=true;
  } else if (clientInput == "paper" && serverInput == "scissors" ) {
    serverWin=true;
    clientWin=false;
  } else if (clientInput == "scissors" && serverInput == "paper" ) {
    serverWin=false;
    clientWin=true;
  } else if (clientInput == "scissors" && serverInput == "rock" ) {
    serverWin=true;
    clientWin=false;
  } else if (clientInput == "rock" && serverInput == "scissors" ) {
    serverWin=false;
    clientWin=true;
  } else { 
    serverWin=false;
    clientWin=false;
  }
}

void sendArduino() {
  if (serverWin==true) {
    myPort.write("win");
  } else {
    myPort.write("lose");
  }
}


void sendClient() {
  if (clientWin==true) {
    ws.sendMessage("win");
  } else {
    ws.sendMessage("lose");
  }
}


void serialEvent(Serial myPort) {
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
