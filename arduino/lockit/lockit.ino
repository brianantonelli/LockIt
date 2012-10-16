#include <Servo.h>

// Bluetooth MAC: 00:06:66:08:E7:60
Servo servo;

boolean lastStateLocked = false;
boolean batteryLow      = false;

const int servoSignalPin = A0;
const int ledUnlockedPin = A2;
const int ledLockedPin   = A3;
const int ledLowBattery  = A5;
const int ledOnboardPin  = 13;
const int pushButtonPin  = A6;

const double lowVoltageThreshold = 4.0;

// Bluetooth output command strings
const String BT_KEY_LOCKED   = "key_locked";
const String BT_KEY_UNLOCKED = "key_unlocked";
const String BT_KNOCK        = "knocking";
const String BT_LOW_BATT     = "low_batt";
const String BT_STATE_LOCK   = "state_locked";
const String BT_STATE_UNLOCK = "state_unlocked";

// Bluetooth input command bytes
const char BT_IN_LOCK       = 'l';
const char BT_IN_UNLOCK     = 'u';
const char BT_IN_SEND_STATE = 's';

void setup(){
  // LEDs
  pinMode(ledUnlockedPin, OUTPUT);
  pinMode(ledLockedPin, OUTPUT);
  pinMode(servoSignalPin, OUTPUT);
  
  // Buttons
  pinMode(pushButtonPin, INPUT);
  
  // Servos
  servo.attach(servoSignalPin);

  // Serials
  Serial.begin(9600); // USB
  Serial1.begin(115200); // BLUETOOTH
  
  Serial.println("Startup!");
}

void loop(){
  boolean currentStateLocked = isDoorLocked(); // Get current lock state
  if(lastStateLocked != currentStateLocked){ // If the physical lock state changed then most likely someone used a key
    if(currentStateLocked){
      Serial1.print(BT_KEY_LOCKED);
    }
    else{
      Serial1.print(BT_KEY_UNLOCKED);
    }
    lastStateLocked = currentStateLocked;
  }
  
  if(isKnocking()){
    Serial1.print(BT_KNOCK);
  }
  
  if(isHardwareButtonPressed()){ // Check if the phyiscal button was pushed
    if(lastStateLocked){ // If so then toggle the door lock state
      lockDoor();
    }
    else{
      unlockDoor();
    }
  }
  
  char btByte = readBTCommand(); // Check for incoming Bluetooth messages
  if(btByte != NULL){
    Serial.println("Got BT Data!");

    if(btByte == BT_IN_LOCK){
      lockDoor();
    }
    else if(btByte == BT_IN_UNLOCK){
      unlockDoor();
    }
    else if(btByte == BT_IN_SEND_STATE){}
    
    if(lastStateLocked){
      Serial1.print(BT_STATE_LOCK);
    }
    else{
      Serial1.print(BT_STATE_UNLOCK);
    }
  }
  
  if(isLowBattery()){ // Check for a low battery
    Serial1.print(BT_LOW_BATT); // FIXME: We should only send battery warnings once a day or something. This would blow up the APN..
  }

  updateLEDs(); // Finally update the LEDs and sleep
  delay(1000);
}

// Begin Bluetooth code

char readBTCommand(){
  // Check if the server sent us any data over bluetooth
  if(Serial1.available() > 0){
    return Serial1.read();
  }
  return NULL;
}

// End Bluetooth code

// Begin deadbolt code (servo)

boolean isDoorLocked(){
  // TODO: hack servo to get internal pot value
  // TODO: get value of servo pot and calculate the position of the servo to determine if the door is locked
  return false;
}

void lockDoor(){
  if(lastStateLocked) return;
  
  moveServo(90);
  lastStateLocked = true;
}

void unlockDoor(){
  if(!lastStateLocked) return;
  moveServo(0);
  lastStateLocked = false;
}

void moveServo(int deg){
  // TODO: Should we attach, write and then detach to save battery? Tried this but had issues.
  servo.write(deg);
}

// End deadbolt code (servo)

// Begin physical box stuff (sensors, buttons, LEDs, sounds, etc)

boolean isKnocking(){
  // TODO: talk to the piezo to see if theres knocking
  // TODO: can this run in a different thread so its polling more?
  return false;
}

boolean isHardwareButtonPressed(){
  int buttonState = digitalRead(pushButtonPin);
  
  return buttonState == HIGH;
}

double getPSUVoltage(){
  // TODO: return the voltage!
  return 1.0;
}

void updateLEDs(){
  if(lastStateLocked){
    digitalWrite(ledLockedPin, HIGH);
    digitalWrite(ledUnlockedPin, LOW);
  }
  else{
    digitalWrite(ledLockedPin, LOW);
    digitalWrite(ledUnlockedPin, HIGH);
  }
  
  if(batteryLow){
    digitalWrite(ledLowBattery, HIGH);
  }
  else{
    digitalWrite(ledLowBattery, LOW);
  }
}

boolean isLowBattery(){
  int voltage = getPSUVoltage();
  batteryLow = (voltage <= lowVoltageThreshold);
  
  return batteryLow;
}

// End physical box stuff
