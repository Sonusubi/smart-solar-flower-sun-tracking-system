#include <WiFi.h>
#include <FirebaseESP32.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>
#include <DFRobot_DHT11.h>
#include <Wire.h>
#include <Adafruit_INA219.h>
#define API_KEY "AIzaSyDak62TA2lTZzlJwrjYaF2Pli1gflj7kxU"
#define DATABASE_URL "https://smart-solar-4eeaf-default-rtdb.firebaseio.com"
#define USER_EMAIL "smartsolar@gmail.com"
#define USER_PASSWORD "123456"
#define DHT11_PIN 4 
#define WIFI_SSID "Autobonics_4G"
#define WIFI_PASSWORD "autobonics@27"
const int analogPin = 36;  // ADC pin on the ESP32
const float R1 = 30000.0; // Resistance of R1 in ohms
const float R2 = 7400.0;  // Resistance of R2 in ohms
const float ADC_MAX = 4095.0; // Maximum value for 12-bit ADC
const float Vref = 3.3;       // Reference voltage for ESP32 ADC
const int potPin = 33;
const int potPin2 = 32;
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
DFRobot_DHT11 DHT;
Adafruit_INA219 ina219;
void setup(){
  Serial.begin(115200);
WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
int timeout = 10; // 10 seconds
while (WiFi.status() != WL_CONNECTED && timeout-- > 0) {
  delay(1000);
  Serial.print(".");
}
if (WiFi.status() == WL_CONNECTED) {
  Serial.println("\nConnected to Wi-Fi");
} else {
  Serial.println("\nFailed to connect to Wi-Fi");
  return;
}
  config.api_key = API_KEY;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  config.database_url = DATABASE_URL;
  config.token_status_callback = tokenStatusCallback;
  analogReadResolution(12); // Set ADC resolution to 12 bits
  Firebase.begin(&config, &auth);
  Firebase.reconnectNetwork(true);
    if (!ina219.begin()) {
    Serial.println("Failed to find INA219 chip");
    while (1) { delay(10); }
  }
  Serial.println("INA219 initialized successfully");
}


void loop(){
dht();
float Voltage = voltage();
float Current = current();
power(Voltage,Current);
tiltAngle();
  delay(1000);
}
void dht(){
  DHT.read(DHT11_PIN);
  Serial.print("temp:");
  Serial.print(DHT.temperature);
  Serial.print("  humi:");
  Serial.println(DHT.humidity);
    if (Firebase.setInt(fbdo, F("Solar/weather/temperature"), DHT.temperature)) {
    Serial.println("temperature pushed successfully!");
  } else {
    Serial.println("Failed to push temperature value: " + fbdo.errorReason());
   }
    if (Firebase.setInt(fbdo, F("Solar/weather/humidity"), DHT.humidity)) {
    Serial.println("humidity pushed successfully!");
  } else {
    Serial.println("Failed to push humidity value: " + fbdo.errorReason());
   }
}
float voltage()
{
  int rawADC = analogRead(analogPin); // Read raw ADC value
  float Vout = (rawADC / ADC_MAX) * Vref; // Convert ADC to voltage
  float Vin = Vout * ((R1 + R2) / R2);    // Calculate input voltage

  // Handle cases where Vin is too low due to the voltage divider
  if (Vin < 0.1) {
    Vin = 0.0; // To avoid negative or small incorrect readings
  }
      if (Firebase.setInt(fbdo, F("Solar/otherdata/voltage"), Vin)) {
    Serial.println("voltage pushed successfully!");
  } else {
    Serial.println("Failed to push voltage value: " + fbdo.errorReason());
   }
   return Vin;
}
float current()
{
  float current_mA = ina219.getCurrent_mA();
  if(current_mA<0.2)
  {
    current_mA=0;
  }
      if (Firebase.setInt(fbdo, F("Solar/otherdata/current"), current_mA)) {
    Serial.println("current pushed successfully!");
  } else {
    Serial.println("Failed to push current value: " + fbdo.errorReason());
   }
return current_mA;
}
void power(float voltage,float current)
{

  float power = voltage*current;
    if (Firebase.setInt(fbdo, F("Solar/otherdata/power"), power)) {
    Serial.println("power pushed successfully!");
  } else {
    Serial.println("Failed to push power value: " + fbdo.errorReason());
   }
}
void tiltAngle()
{
  int value = analogRead(potPin);
  float tiltAngle = map(value,0,4095,0,120);
      if (Firebase.setInt(fbdo, F("Solar/otherdata/tiltangle"), tiltAngle)) {
    Serial.println("tilt angle pushed successfully!");
  } else {
    Serial.println("Failed to push tilt angle value: " + fbdo.errorReason());
   }

}
