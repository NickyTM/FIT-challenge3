//client //<>// //<>//
import websockets.*;

WebsocketClient wsc;
import processing.serial.*;

int[] array;

Serial myPort;

boolean firstContact = false;
boolean serverContact = false;

String inString;
String outString = "0,0,0";

void setup() { 
  size(300, 600); 

  // List all the available serial ports
  printArray(Serial.list());

  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.bufferUntil('\n'); //buffer untill carriage return is found

  // Connect to the local machine at port 5204.
  // This example will not run if you haven't
  // previously started a server on this port. // ws://127.0.0.1:8025/itech 
  wsc= new WebsocketClient(this, "ws://77.173.59.203:8025/itech"); //fill in correct IP adres when connecting your client to a server, this one is local
} 

void draw() {
} 


String determineGesture(int gesture) {
  if (gesture == 1) {
    return "rock";
  } else if (gesture == 2) {
    return "paper";
  } else if (gesture == 3) {
    return "scissors";
  } else {
    return "";
  }
}

void sendArduino() {
  //if (outString=="win") {
  //  myPort.write("win");
  //} else {
  //  myPort.write("lose");
  //}
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

      //write to server
      wsc.sendMessage(inString);

      //send data

      if (serverContact == true) {

        myPort.write(outString);
        
        println("Server: " + outString);
        println("Client: " + inString);
      }
    }
  }
}

void webSocketEvent(String whatServerSaid) {
  if (whatServerSaid != null && whatServerSaid != "A" && whatServerSaid != outString) {

    outString = whatServerSaid;

    //if first contact with server set to true
    if (serverContact == false) {
      serverContact = true;
    }
  }
}
