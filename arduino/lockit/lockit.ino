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
  locked = isDoorLocked();
  updateLEDs();
  // TODO: tell server door status

  Serial.begin(9600); // USB
  Serial1.begin(115200); // BLUETOOTH

  // Register callbacks from Android
  /**
  meetAndroid.registerFunction(android_lockDoor, 'l');  
  meetAndroid.registerFunction(android_unlockDoor, 'u');  
  */
  
  Serial.println("Startup!");
  
  // TOOD: Anyway to read the servo value to see if the doors locked or unlocked?
  // TODO: Bluetooth
  // TODO: WiFi
  // TODO: Piezo sensor for knock detection
  // TODO: Hardware button to lock/unlock
  // TODO: Detect physical key usage
}

void loop(){
  /**
  meetAndroid.receive(); // you need to keep this in your loop() to receive events
  */
  // Check if the server sent us any data over bluetooth
  if(Serial1.available() > 0){
    incomingByte = Serial1.read();
    Serial.print("You sent: ");
    Serial.println(incomingByte);
  }

  delay(2000);
}

// Begin deadbolt code (servo)

boolean isDoorLocked(){
  // TODO: hack servo to get internal pot value
  // TODO: get value of servo pot and calculate the position of the servo to determine if the door is locked
  return false;
}

void lockDoor(){
  if(locked) return;
  
  moveServo(90);
  locked = true;
  updateLEDs();
}

void unlockDoor(){
  if(!locked) return;
  moveServo(0);
  locked = false;
  updateLEDs();
}

void moveServo(int deg){
  // TODO: Should we attach, write and then detach to save battery? Tried this but had issues.
  servo.write(deg);
}

// End deadbolt code (servo)

// Begin physical box stuff (LEDs, sounds, etc)

double getPowerSupplyVoltage(){
  return 1.0;
}

void updateLEDs(){
  if(locked){
    digitalWrite(ledLockedPin, HIGH);
    digitalWrite(ledUnlockedPin, LOW);
  }
  else{
    digitalWrite(ledLockedPin, LOW);
    digitalWrite(ledUnlockedPin, HIGH);
  }
}

// End physical box stuff (LEDs, sounds, etc)

// Begin server functions

// End server functions

// Begin Android functions
void android_lockDoor(byte flag, byte numOfValues){
  lockDoor();
}

void android_unlockDoor(byte flag, byte numOfValues){
  unlockDoor();
}
// End Android functions
