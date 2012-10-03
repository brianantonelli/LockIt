#include <Servo.h>

Servo servo;

boolean locked = false;

const int servoSignalPin = A0;
const int ledUnlockedPin = A2;
const int ledLockedPin   = A3;

void setup(){
  pinMode(ledUnlockedPin, OUTPUT);
  pinMode(ledLockedPin, OUTPUT);
  pinMode(servoSignalPin, OUTPUT);
  
  Serial.begin(19200);
  Serial.println("Startup!");
  
  // TOOD: Anyway to read the servo value to see if the doors locked or unlocked?
  // TODO: Bluetooth
  // TODO: WiFi
  // TODO: Piezo sensor for knock detection
  // TODO: Hardware button to lock/unlock
  // TODO: Detect physical key usage
}

void loop(){
  if(!locked){
    Serial.println("Locking!");
    lockDoor();
  }
  else{
    Serial.println("Unlocking!");
    unlockDoor();
  }
  delay(5000);
}

void lockDoor(){
  moveServo(90);
  digitalWrite(ledLockedPin, HIGH);
  digitalWrite(ledUnlockedPin, LOW);
  locked = true;
}

void unlockDoor(){
  moveServo(0);
  digitalWrite(ledLockedPin, LOW);
  digitalWrite(ledUnlockedPin, HIGH);
  locked = false;
}

void moveServo(int deg){
  servo.attach(servoSignalPin);
  servo.write(deg);
  servo.detach();
}
