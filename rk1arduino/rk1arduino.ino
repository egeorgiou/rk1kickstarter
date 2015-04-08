#include <SoftwareSerial.h>
SoftwareSerial wifiSerial(2,4);

#define leftMotorPinOne 3
#define leftMotorPinTwo 5
#define rightMotorPinOne 6
#define rightMotorPinTwo 9

void motorController(int leftMotorDirection, int leftMotorSpeed, int rightMotorDirection, int rightMotorSpeed)
{
  if (leftMotorDirection == 0)
  {
    analogWrite(leftMotorPinOne, leftMotorSpeed);
    analogWrite(leftMotorPinTwo, HIGH);
  }
  else if (leftMotorDirection == 1)
  {
    analogWrite(leftMotorPinOne, HIGH);
    analogWrite(leftMotorPinTwo, leftMotorSpeed);
  }
  
  if (rightMotorDirection == 0)
  {
    analogWrite(rightMotorPinOne, HIGH);
    analogWrite(rightMotorPinTwo, rightMotorSpeed);
  }
  else if (rightMotorDirection == 1)
  {
    analogWrite(rightMotorPinOne, rightMotorSpeed);
    analogWrite(rightMotorPinTwo, HIGH);
  }  
}

void sendAnalogData()
{
  Serial.println("Sending Analog Data");
  byte sendData[21];
  sendData[0] = 0x04;
  
  for (int i = 1; i < 9; i++)
  {
    int analogPinValue = analogRead(i - 1);
    
    sendData[(i * 2) - 1] = analogPinValue & 0xFF;
    sendData[(i * 2)] = (analogPinValue >> 8) & 0xFF;
  }
  
  for (int j = 10; j < 14; j++)
  {
    pinMode(j, INPUT);
    sendData[17 + (j - 9)] = digitalRead(j);
  }
  
  wifiSerial.write(sendData, 21);
}

void sendBatteryData()
{
  Serial.println("Sending Battery Data");
  byte sendData[3];
  sendData[0] = 0x04;
  
  for (int i = 1; i < 2; i++)
  {
    int analogPinValue = analogRead(i - 1);
    
    sendData[(i * 2) - 1] = analogPinValue & 0xFF;
    sendData[(i * 2)] = (analogPinValue >> 8) & 0xFF;
  }
  
  wifiSerial.write(sendData, 3);
}

void setDigitalState(int pin10state, int pin11state, int pin12state, int pin13state)
{
  pinMode(10, OUTPUT);
  if (pin10state == 1)
    { digitalWrite(10, HIGH); }
  else
    { digitalWrite(10, LOW); }
  
  pinMode(11, OUTPUT);
  if (pin11state == 1)
    { digitalWrite(11, HIGH); }
  else
    { digitalWrite(11, LOW); }
  
  pinMode(12, OUTPUT);
  if (pin12state == 1)
    { digitalWrite(12, HIGH); }
  else
    { digitalWrite(12, LOW); }
  
  pinMode(13, OUTPUT);
  if (pin13state == 1)
    { digitalWrite(13, HIGH); }
  else
    { digitalWrite(13, LOW); }
}

void setup()
{
  Serial.begin(9600);
  wifiSerial.begin(9600);
}

void loop()
{
  int bytesAvailable = wifiSerial.available();
  
  if(bytesAvailable > 4)
  {
    Serial.print("bytes available: ");
    Serial.println(bytesAvailable, DEC);
  
    int firstByte = (int)wifiSerial.read();
  
    Serial.print("byte 0: ");
    Serial.println(firstByte);
  
    if (firstByte == 1)
    {
      byte data[4];
      
      for (int i = 0; i < 4; i++)
      {
        data[i] = wifiSerial.read();
        Serial.print("control byte ");
        Serial.print(i, DEC);
        Serial.print(": ");
        Serial.println((int)data[i], DEC);
      }
      
      motorController((int)data[0], (int)data[1], (int)data[2], (int)data[3]);
      sendBatteryData();
    }
    else if(firstByte == 2)
    {
      sendAnalogData();
    }
    else if(firstByte == 3)
    {
      byte data[4];
      
      for (int i = 0; i < 4; i++)
      {
        data[i] = wifiSerial.read();
        Serial.print("digital byte ");
        Serial.print(i, DEC);
        Serial.print(": ");
        Serial.println((int)data[i], DEC);
      }
      
      setDigitalState((int)data[0], (int)data[1], (int)data[2], (int)data[3]);
      sendBatteryData();
    }
  }

  if (Serial.available()) 
  {
    wifiSerial.write(Serial.read());
  }
}
