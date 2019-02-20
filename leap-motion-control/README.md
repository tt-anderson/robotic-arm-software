# About 
I started developing this software, Fall of 2016, to provide a method to control my friend's robotic arm/hand. Our project, the development of an intelligent and dextrous robotic arm, is a year into development, with many iterations througout the models and code. This project started as a simple open and close function and has developed into a precise method to mimic the user's finger movements (angle of bend) and wrist orientation.

## Robotic/Prosthetic Hand Models
The robotic/prosthetic hand 3-D modeled and designed from scratch by, my friend, Ryan Gross:
* [Prosthetic Hand](https://www.thingiverse.com/thing:1691704)

* [Humanoid Robotic Hand](https://www.thingiverse.com/thing:2269115)

## Videos
[![Leap Motion Controlling Robotic Hand](https://i.ytimg.com/vi/3RT4VxzfR7o/hqdefault.jpg?custom=true&w=336&h=188&stc=true&jpg444=true&jpgq=90&sp=68&sigh=jSdQUH0LPmkBmA_l1RSWCEq4K1U)](https://www.youtube.com/watch?v=3RT4VxzfR7o) 
[![Assembly of 3D Printed Prosthetic Hand](https://i.ytimg.com/vi/RJNDjnWV8Eo/hqdefault.jpg?custom=true&w=336&h=188&stc=true&jpg444=true&jpgq=90&sp=68&sigh=NoO1IPwUvkwjopU-Ku0u-TDZpQE)](https://www.youtube.com/watch?v=RJNDjnWV8Eo)

## Setup
To utilize this software, you must have:
   * [Leap Motion Controller](https://store-us.leapmotion.com/products/leap-motion-controller)
   * [Leap Motion Controller Software v2 SDK](https://developer.leapmotion.com/sdk/v2)
   * [Leap Motion Java SDK](https://developer.leapmotion.com/documentation/java/devguide/Leap_Processing.html)
   * [Arduino Board](https://www.arduino.cc/en/Main/Products)
   * [Arduino IDE](https://www.arduino.cc/en/Main/Software)
   * [Processing Development Environment (PDE)](https://processing.org/download/)
   
1. Install the Processing Development Environment (PDE); install the Leap Motion Java SDK and Arduino libraries in the PDE.
   
     https://developer.leapmotion.com/documentation/v2/java/devguide/Leap_Processing.html - Guide for installing Leap Motion Java SDK to Processing
   
     https://playground.arduino.cc/Interfacing/Processing - Guide for installing Arduino libraries to the PDE

2. Install Arduino IDE and upload the example sketch "StandardFirmata" located in Examples > Firmata to the Arduino Board

3. Run the robotic-arm-software, "hand-mimic.pde".

## Notes
Configure the servo pin numbers to match your pins
```java
//Opposable Thumb
int opposableServo = 0;
//Thumb
int thumbServo = 7;
//Index
int indexServo = 4;
//Middle
int middleServo = 5;
//Ring and Pinky
int ringpinkyServo = 6;
//Wrist
int wristServo = 13;
```
Depending on the orientation of the servos in the forearm of the prosthetic/robotic arm, you may have to configure the values for the servos; 0 - 180 or 180 - 0

Example of the Index Finger:
```java
//Metacarpal Bone; Get the direction
Vector indexMetacarpalVector  =  finger.bone(Bone.Type.TYPE_METACARPAL).basis().getZBasis();

//Distal Bone; Get the direction
Vector indexDistalVector  =  finger.bone(Bone.Type.TYPE_DISTAL).basis().getZBasis();

//Calculate the angle bewteen the metacarpal and distal bone; convert to degrees.
float indexAngle  =  indexMetacarpalVector.angleTo(indexDistalVector) * 180/PI;

/* This snippet reverses the values from 0 - 180, to 180 - 0
//Set float to value 180
float indexRatio = 180;

//Subract 180 from raw angle value to get value 180 to 0
indexRatio -= indexAngle;
*/

//arduino.servoWrite doesn't support float, so convert and round to integer
int indexAngleFinal = (int) indexAngle;

//Print to console, the index final angle value
println("INDEX: ", indexAngleFinal);

//Write to the servo, the index final angle value
arduino.servoWrite(indexServo, indexAngleFinal);  
```
Use ``` printArray(Serial.list()); ``` to list all available serial ports.

Configure the serial port, if needed:
```java
arduino = new Arduino(this, Arduino.list()[0], 57600);
```

### Contact
thomasanderson@agbotics.tech

### License
Copyright (c) 2017 Thomas Anderson

Licensed Under [MIT](https://github.com/tt-anderson/robotic-arm-software/blob/master/LICENSE).
