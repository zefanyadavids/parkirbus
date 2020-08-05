#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <LiquidCrystal_I2C.h>

#define pinButton D5

LiquidCrystal_I2C lcd(0x27, 16, 2);

int buttonState;
int counter = 0;

const char ssid[] = "Davidzsan";
const char pass[] = "87654312";
String host = "http://3.227.56.82:1337";
String api;

int cek = 1;

void setup() {
  Serial.begin(9600);
  pinMode(pinButton, INPUT_PULLUP);

  lcd.begin(16,2);
  lcd.init();
  lcd.backlight();
 
  lcd.setCursor(0, 0);

  WiFi.begin(ssid, pass);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi..");
  }
  Serial.println("Connected to the WiFi network");

}

void loop() {
  HTTPClient http;
  String capacity = "0";
  
  buttonState = digitalRead(pinButton);
  if(buttonState==1){
    delay(500);
    counter+=1;
    cek = 1;
  }

  if(counter==3){
    counter=0;
  }

  if(counter==0 && cek==1) {
    if (WiFi.status() == WL_CONNECTED) {
      api = host;
      api.concat("/api/v1/projectprototype/switchPrototype?newPrototype=abubakarali");
      http.begin(api); 
      int httpCode = http.GET();
      if (httpCode > 0) {
        String payload = http.getString();
        Serial.println(payload);
      }

      api = host;
      api.concat("/api/v1/parkingareas/getCapacity?parking_code=ABA");
      http.begin(api); 
      httpCode = http.GET();
      if (httpCode > 0) {
        capacity = http.getString();
        Serial.println(capacity);
      }
      
      http.end();
    }

    Serial.println("ABU BAKAR ALI");
    lcd.clear();
    lcd.print("ABU BAKAR ALI");
    lcd.setCursor(0, 1);
    lcd.print("KAPASITAS " + capacity);

    cek = 0;
  } else if(counter==1 && cek==1) {
    if (WiFi.status() == WL_CONNECTED) {
      api = host;
      api.concat("/api/v1/projectprototype/switchPrototype?newPrototype=ngabean");
      http.begin(api); 

      int httpCode = http.GET();
      if (httpCode > 0) {
        String payload = http.getString();
        Serial.println(payload);
      }

      api = host;
      api.concat("/api/v1/parkingareas/getCapacity?parking_code=NGB");
      http.begin(api); 
      httpCode = http.GET();
      if (httpCode > 0) {
        capacity = http.getString();
        Serial.println(capacity);
      }
      
      http.end();
    }
    
    Serial.println("NGABEAN");
    lcd.clear();
    lcd.print("NGABEAN");
    lcd.setCursor(0, 1);
    lcd.print("KAPASITAS " + capacity);

    cek = 0;
  } else if(counter==2 && cek==1) {
    if (WiFi.status() == WL_CONNECTED) {
      api = host;
      api.concat("/api/v1/projectprototype/switchPrototype?newPrototype=senopati");
      http.begin(api); 
      int httpCode = http.GET();
      if (httpCode > 0) {
        String payload = http.getString();
        Serial.println(payload);
      }
      api = host;
      api.concat("/api/v1/parkingareas/getCapacity?parking_code=SEN");
      http.begin(api); 
      httpCode = http.GET();
      if (httpCode > 0) {
        capacity = http.getString();
        Serial.println(capacity);
      }
      
      Serial.println("SENOPATI");
      lcd.clear();
      lcd.print("SENOPATI");
      lcd.setCursor(0, 1);
      lcd.print("KAPASITAS " + capacity);
      
      http.end();
    }

    cek = 0;
  }
}
