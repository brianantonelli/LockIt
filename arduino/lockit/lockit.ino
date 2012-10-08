#include <Servo.h>
//#include <MeetAndroid.h>

// Bluetooth MAC: 00:06:66:08:E7:60
//MeetAndroid meetAndroid;
Servo servo;

boolean locked = false;

const int servoSignalPin = A0;
const int ledUnlockedPin = A2;
const int ledLockedPin   = A3;
const int ledOnboardPin  = 13;

char incomingByte;

void setup(){
  pinMode(ledUnlockedPin, OUTPUT);
  pinMode(ledLockedPin, OUTPUT);
  pinMode(servoSignalPin, OUTPUT);
  
  servo.attach(servoSignalPin);

  Serial.begin(9600); // USB
  Serial1.begin(115200); // BLUETOOTH

  // Register callbacks from Android
//  meetAndroid.registerFunction(android_lockDoor, 'l');  
//  meetAndroid.registerFunction(android_unlockDoor, 'u');  

  Serial.println("Startup!");
  
  // TOOD: Anyway to read the servo value to see if the doors locked or unlocked?
  // TODO: Bluetooth
  // TODO: WiFi
  // TODO: Piezo sensor for knock detection
  // TODO: Hardware button to lock/unlock
  // TODO: Detect physical key usage
}

void loop(){
//  meetAndroid.receive(); // you need to keep this in your loop() to receive events
  if(Serial1.available() > 0){
    incomingByte = Serial1.read();
    Serial.println(incomingByte);
    if(incomingByte == 'H') {
      Serial1.print("You sent me the H letter");
    }
  }

  Serial1.print("b");
  delay(500);
//  if(!locked){
//    Serial.println("Locking!");
//    lockDoor();
//  }
//  else{
//    Serial.println("Unlocking!");
//    unlockDoor();
//  }
//  delay(5000);
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
//  servo.attach(servoSignalPin);
  servo.write(deg);
//  servo.detach();
}

// Begin Android functions
void android_lockDoor(byte flag, byte numOfValues){
  lockDoor();
}

void android_unlockDoor(byte flag, byte numOfValues){
  unlockDoor();
}
// End Android functions
