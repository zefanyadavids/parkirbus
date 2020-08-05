#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <Servo.h>

#define pinButton D5
int buttonState = 0;

Servo motorServo;

int Detector = D0;
int Detector2 = D1;
int Detector3 = D2;

const char ssid[] = "Davidzsan";
const char pass[] = "87654312";
String host = "http://3.227.56.82:1337";
String url;

bool cek = true;

String currentPrototype;

void setup() { 

  Serial.begin (9600);

  pinMode(Detector, INPUT);
  pinMode(Detector2, INPUT);
  pinMode(Detector3, INPUT);

  motorServo.attach(2); //D4
  motorServo.write(90);

  pinMode(pinButton, INPUT_PULLUP);
  
  WiFi.begin(ssid, pass);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi..");
  }
  Serial.println("Connected to the WiFi network");

}

void loop() {
  HTTPClient http;  //Declare an object of class HTTPClient
  
  boolean val = digitalRead(Detector);
  boolean val2 = digitalRead(Detector2);
  boolean val3 = digitalRead(Detector3);
  
  Serial.print(val);
  Serial.print(val2);
  Serial.print(val3);
  Serial.println(" ");

  buttonState = digitalRead(pinButton);
  Serial.println(buttonState);
  Serial.println(" ");
  if(buttonState==1){
    motorServo.write(180);  // Turn Servo ke kiri 90 degrees
  }
  
  if(val==false && val2==true && val3==true && cek==true) {
    Serial.println("laser 1 blocked! small bus detected.");
    motorServo.write(90);  // Turn Servo to right 180 degrees

    if (WiFi.status() == WL_CONNECTED) { //Check WiFi connection status

      url = host;
      url.concat("/api/v1/projectprototypes/getCurrentPrototype");
      http.begin(url);  //Specify request destination
      int httpCode = http.GET();                                                                  //Send the request
      if (httpCode > 0) { //Check the returning code
        String payload = http.getString();   //Get the request response payload
        Serial.println(payload);                     //Print the response payload
        if (payload=="abubakarali") {
          currentPrototype = "ABA";
        } if (payload=="senopati") {
          currentPrototype = "SEN";
        } if (payload=="ngabean") {
          currentPrototype = "NGB";
        }
      }

      url = host;
      url.concat("/api/v1/parkingrecords/laserRecorded?parking_code=");
      url.concat(currentPrototype);
      url.concat("&bus_type=1&parking_exit=true");
      http.begin(url);  //Specify request destination
      httpCode = http.GET(); //Send the request
      if (httpCode > 0) { //Check the returning code
        String payload = http.getString();   //Get the request response payload
        Serial.println(payload);                     //Print the response payload
      }

      url = host;
      url.concat("/api/v1/parkingareas/updateParkingCapacity?bus_value=0.4&parking_exit=true&parking_code=");
      url.concat(currentPrototype);
      http.begin(url);  //Specify request destination
      httpCode = http.GET(); //Send the request
      if (httpCode > 0) { //Check the returning code
        String payload = http.getString();   //Get the request response payload
        Serial.println(payload); //Print the response payload
      }
      
      http.end();   //Close connection  
    }
    cek = false;
  } else if(val==false && val2==false && val3==true && cek==true) {
    motorServo.write(90);  // Turn Servo to right 90 degrees
    Serial.println("laser 1, laser 2 blocked! medium bus detected.");

    if (WiFi.status() == WL_CONNECTED) { //Check WiFi connection status
            
      url = host;
      url.concat("/api/v1/projectprototypes/getCurrentPrototype");
      http.begin(url);  //Specify request destination
      int httpCode = http.GET();                                                                  //Send the request
      if (httpCode > 0) { //Check the returning code
        String payload = http.getString();   //Get the request response payload
        Serial.println(payload);                     //Print the response payload
        if (payload=="abubakarali") {
          currentPrototype = "ABA";
        } if (payload=="senopati") {
          currentPrototype = "SEN";
        } if (payload=="ngabean") {
          currentPrototype = "NGB";
        }
      }

      url = host;
      url.concat("/api/v1/parkingrecords/laserRecorded?parking_code=");
      url.concat(currentPrototype);
      url.concat("&bus_type=2&parking_exit=true"); 
      http.begin(url);  //Specify request destination
      httpCode = http.GET(); //Send the request
      if (httpCode > 0) { //Check the returning code
        String payload = http.getString();   //Get the request response payload
        Serial.println(payload);                     //Print the response payload
      }

      url = host;
      url.concat("/api/v1/parkingareas/updateParkingCapacity?bus_value=0.6&parking_exit=true&parking_code=");
      url.concat(currentPrototype);
      http.begin(url);  //Specify request destination
      httpCode = http.GET(); //Send the request
      if (httpCode > 0) { //Check the returning code
        String payload = http.getString();   //Get the request response payload
        Serial.println(payload); //Print the response payload
      }
      
      http.end();   //Close connection
    }
    cek = false;
  } else if(val==false && val2==false && val3==false && cek==true) {
    motorServo.write(90);  // Turn Servo to right 90 degrees
    Serial.println("laser 1, laser 2, laser 3 blocked! long bus detected.");

    if (WiFi.status() == WL_CONNECTED) { //Check WiFi connection status
            
      url = host;
      url.concat("/api/v1/projectprototypes/getCurrentPrototype");
      http.begin(url);  //Specify request destination
      int httpCode = http.GET();                                                                  //Send the request
      if (httpCode > 0) { //Check the returning code
        String payload = http.getString();   //Get the request response payload
        Serial.println(payload);                     //Print the response payload
        if (payload=="abubakarali") {
          currentPrototype = "ABA";
        } if (payload=="senopati") {
          currentPrototype = "SEN";
        } if (payload=="ngabean") {
          currentPrototype = "NGB";
        }
      }

      url = host;
      url.concat("/api/v1/parkingrecords/laserRecorded?parking_code=");
      url.concat(currentPrototype);
      url.concat("&bus_type=3&parking_exit=true");
      http.begin(url);  //Specify request destination
      httpCode = http.GET(); //Send the request
      if (httpCode > 0) { //Check the returning code
        String payload = http.getString();   //Get the request response payload
        Serial.println(payload);                     //Print the response payload
      }

      url = host;
      url.concat("/api/v1/parkingareas/updateParkingCapacity?bus_value=1&parking_exit=true&parking_code=");
      url.concat(currentPrototype);
      http.begin(url);  //Specify request destination
      httpCode = http.GET(); //Send the request
      if (httpCode > 0) { //Check the returning code
        String payload = http.getString();   //Get the request response payload
        Serial.println(payload); //Print the response payload
      }
      
      http.end();   //Close connection
    }
    cek = false;
  }
  
  delay(100);
  
  if (val==true && val2 == true && val3==true) {
    cek = true; 
  }
}
