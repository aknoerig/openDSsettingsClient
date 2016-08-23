
import processing.net.*;

int serverPort = 5678;
String serverIp = "127.0.0.1";
Client c;
String buffer;
boolean firstTime = true;

float speed, actualRpm, consumption;
static float MAX_SPEED = 250;
static float MAX_RPM = 6000;
static float MAX_CONSUMPTION = 40;

void setup()
{
  size(800, 400);
  background(0);
  
  connect();
  rectMode(CORNER);
}  

void draw()
{
  background(0);
  textSize(14);
  fill(255, 255, 255);
  
  text(round(actualRpm), 100, 30);
  float rpmHeight = actualRpm/MAX_RPM * height;
  rect(0, height, 200, -rpmHeight);
  
  text(round(speed), 400, 30);
  float speedHeight = speed/MAX_SPEED * height;
  rect(200, height, 400, -speedHeight);
  
  text(consumption, 700, 30); 
  float consumptionHeight = consumption/MAX_CONSUMPTION * height;
  rect(600, height, 200, -consumptionHeight);
}

void connect() {
  println("Connecting to openDS at " + serverIp + ":" + serverPort);
  c = new Client(this, serverIp, serverPort);

  println("Sending configuration messages");
  String[] config = loadStrings("configDS.xml");
  for (String line : config) {
    c.write(line);
    c.write("\n"); // required by openDS
  }
}


void mousePressed() {
}

void keyPressed() {
}

void clientEvent(Client _c) {
  String dataIn = _c.readStringUntil('>');
  if (dataIn != null) {
    buffer += dataIn;
    if (buffer.endsWith("</Message>")) {
      if (!firstTime) { // ignore first message since it will be incomplete
        buffer = buffer.substring(1); // remove beginning whitespace
        XML message = parseXML(buffer).getChild("Event/root/thisVehicle");
        if (message != null) {
          //println(message.toString());
          speed = message.getChild("physicalAttributes/Properties/speed").getFloatContent();
          actualRpm = message.getChild("exterior/engineCompartment/engine/Properties/actualRpm").getFloatContent();
          consumption = message.getChild("exterior/fueling/fuelType/Properties/currentConsumption").getFloatContent();
        }
      } else {
        firstTime = false;
      }
      buffer = "";
    }
  }
}