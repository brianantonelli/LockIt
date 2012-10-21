#include <Servo.h>

// Bluetooth MAC: 00:06:66:08:E7:60

// Variables
Servo servo;
boolean lastStateLocked = false;
boolean batteryLow      = false;
int sensorReading = 0; // value read from the knock sensor pin

// Tones configs
byte names[] = {'c', 'd', 'e', 'f', 'g', 'a', 'b', 'C'};  
int tones[] = {1915, 1700, 1519, 1432, 1275, 1136, 1014, 956};
byte melody[] = "1f2C2c2d";//1f";//2c2da2a2d2c2f2d2a2c2d2a1f2c2d2a2a2g2p8p8p8p";
// count length: 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0
//                                10                  20                  30
int count = 0;
int count2 = 0;
int count3 = 0;
int MAX_COUNT = 24;

// Pins
const int servoSignalPin = A8;
const int ledUnlockedPin = A2;
const int ledLockedPin   = A3;
const int ledLowBattery  = A5;
const int ledOnboardPin  = 13;
const int pushButtonPin  = A15;
const int servoPotPin    = A14;
const int knockSensorPin = A13;
const int speakerPin     = A12;

// Constants
const int servoPositionUnlocked = 100; // FIXME: Testing
const int servoPositionLocked = 400; // FIXME: Testing
const double lowVoltageThreshold = 4.0; // FIXME: Testing
const int threshold = 100;  // threshold value to decide when the detected sound is a knock or not

// Bluetooth output command strings -- SINGLE CHARACTERS ONLY otherwise the OSX app gets them chunked
const String BT_KEY_LOCKED   = "1";
const String BT_KEY_UNLOCKED = "2";
const String BT_KNOCK        = "3";
const String BT_LOW_BATT     = "4";
const String BT_STATE_LOCK   = "5";
const String BT_STATE_UNLOCK = "6";

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
  pinMode(servoPotPin, INPUT);
  
  // Others
  pinMode(knockSensorPin, INPUT);
  pinMode(speakerPin, OUTPUT);  

  // Serials
  Serial.begin(9600); // USB
  Serial1.begin(115200); // BLUETOOTH
  
  Serial.println("Startup!");
}

void loop(){
  boolean currentStateLocked = isDoorLocked(); // Get current lock state
  if(lastStateLocked != currentStateLocked){ // If the physical lock state changed then most likely someone used a key
    playTone();
    if(currentStateLocked){
      Serial1.print(BT_KEY_LOCKED);
    }
    else{
      Serial1.print(BT_KEY_UNLOCKED);
    }
    lastStateLocked = currentStateLocked;
  }
  
  if(isKnocking()){
//    Serial1.print(BT_KNOCK);
//    Serial.println("Kncoking");
//    playTone();
  }
  
  if(isHardwareButtonPressed()){ // Check if the phyiscal button was pushed
    if(lastStateLocked){ // If so then toggle the door lock state
      unlockDoor();
    }
    else{
      lockDoor();
    }
    playTone();
  }
  
  char btByte = readBTCommand(); // Check for incoming Bluetooth messages
  if(btByte != NULL){
    Serial.println("Got BT Data!");
    Serial.println(btByte);
    if(btByte == BT_IN_LOCK){
      lockDoor();
      playTone();
    }
    else if(btByte == BT_IN_UNLOCK){
      unlockDoor();
      playTone();
    }
    else if(btByte == BT_IN_SEND_STATE){
      if(lastStateLocked){
        Serial1.print(BT_STATE_LOCK);
      }
      else{
        Serial1.print(BT_STATE_UNLOCK);
      }
    }
  }
  
  if(isLowBattery()){ // Check for a low battery
//    Serial1.print(BT_LOW_BATT); // FIXME: We should only send battery warnings once a day or something. This would blow up the APN..
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
  int servoVal = analogRead(servoPotPin);

  if(servoVal <= servoPositionUnlocked){
    return false;
  }
  else if(servoVal >= servoPositionLocked){
    return true;
  }  

  return lastStateLocked; // Servo is between lock and unlocked, probably being manually moved

}

void lockDoor(){
  if(lastStateLocked) return;
  
  moveServo(180);
  lastStateLocked = true;
}

void unlockDoor(){
  if(!lastStateLocked) return;
  moveServo(0);
  lastStateLocked = false;
}

void moveServo(int deg){
  servo.attach(servoSignalPin);
  servo.write(deg);
  // delay needed because we have to wait for the servo movement to complete before 
  //  detaching otherwise it will cancel the servo movement. 600ms seems to be about the 
  //  max time it takes to do a 180deg rotation.
  delay(600); 
  servo.detach();
}

// End deadbolt code (servo)

// Begin physical box stuff (sensors, buttons, LEDs, sounds, etc)

boolean isKnocking(){
  sensorReading = analogRead(knockSensorPin);
  Serial.print("Knocking reading: ");
  Serial.println(sensorReading);
  if(sensorReading >= threshold){
    return true;
    Serial.println("Knock!");         
  }
  
  return false;

}

boolean isHardwareButtonPressed(){
  int buttonState = digitalRead(pushButtonPin);
  
  return buttonState == HIGH;
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
  int voltage = readVcc();
//  Serial.println(voltage);
  batteryLow = (voltage <= lowVoltageThreshold);
  
  return batteryLow;
}

long readVcc(){
  // http://provideyourown.com/2012/secret-arduino-voltmeter-measure-battery-voltage/
  // Read 1.1V reference against AVcc
  // set the reference to Vcc and the measurement to the internal 1.1V reference
#if defined(__AVR_ATmega32U4__) || defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
  ADMUX = _BV(REFS0) | _BV(MUX4) | _BV(MUX3) | _BV(MUX2) | _BV(MUX1);
#elif defined (__AVR_ATtiny24__) || defined(__AVR_ATtiny44__) || defined(__AVR_ATtiny84__)
  ADMUX = _BV(MUX5) | _BV(MUX0);
#elif defined (__AVR_ATtiny25__) || defined(__AVR_ATtiny45__) || defined(__AVR_ATtiny85__)
  ADMUX = _BV(MUX3) | _BV(MUX2);
#else
  ADMUX = _BV(REFS0) | _BV(MUX3) | _BV(MUX2) | _BV(MUX1);
#endif  
 
  delay(2); // Wait for Vref to settle
  ADCSRA |= _BV(ADSC); // Start conversion
  while (bit_is_set(ADCSRA,ADSC)); // measuring
 
  uint8_t low  = ADCL; // must read ADCL first - it then locks ADCH  
  uint8_t high = ADCH; // unlocks both
 
  long result = (high<<8) | low;
 
  result = 1125300L / result; // Calculate Vcc (in mV); 1125300 = 1.1*1023*1000
  return result; // Vcc in millivolts
}

void playTone(){
  Serial.println("playTone()");
  analogWrite(speakerPin, 0);
  for(count = 0; count < MAX_COUNT; count++){
    for (count3 = 0; count3 <= (melody[count*2] - 48) * 30; count3++) {
      for (count2=0;count2<8;count2++) {
        if (names[count2] == melody[count*2 + 1]) {       
          analogWrite(speakerPin,500);
          delayMicroseconds(tones[count2]);
          analogWrite(speakerPin, 0);
          delayMicroseconds(tones[count2]);
        } 
        if (melody[count*2 + 1] == 'p') {
          // make a pause of a certain size
          analogWrite(speakerPin, 0);
          delayMicroseconds(500);
        }
      }
    }
  }
}

// End physical box stuff
