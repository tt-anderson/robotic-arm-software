## About
This program is intended to demonstrate the capabilities of AGbotic's PROTO1 3D printed robot but can be adapted for a variety of purposes.
This program gathers the user's right shoulder, elbow, and wrist's X,Y,Z position from the Microsoft Kinect V2 and calculates the angle between two vectors created from the X,Y,Z position data.

More information about AGbotic's PROTO1 robot can be found at: https://agbotics.tech/

## Setup
To utilize this software, you must have:
  * Microsoft Kinect V2 Sensor
  * Microsoft Kinect Adapter for Windows
  * [Kinect for Windows SDK 2.0](https://www.microsoft.com/en-us/download/details.aspx?id=44561)
  * Windows 10, 8.1, 8
  * 64bit computer with a dedicated USB 3.0
  * Latest video card driver and DirectX 11
  * [Processing IDE](https://processing.org/download/)
  * [KinectPV2 Libray for Processing](https://github.com/ThomasLengeling/KinectPV2)
  * [Arduino Board](https://www.arduino.cc/en/Main/Products)
  * [Arduino IDE](https://www.arduino.cc/en/Main/Software)

Basic overview of the setup process:
1. Install the Processing Development Environment (PDE); install the KinectPV2 and Arduino libraries in the PDE.
   
     https://playground.arduino.cc/Interfacing/Processing - Guide for installing Arduino libraries to the PDE

2. Install Arduino IDE and upload the example sketch "StandardFirmata" located in Examples > Firmata to the Arduino Board

3. Run the robotic-arm-software, "elbow-mimic.pde".


## Notes
Configure this number to your pin number on the Arduino: 
```java
//Elbow Servo
int elbowServo = 1;
```
Configure the [0] within this line to the serial port that matches your Arduino. You can use the line below it to figure out which port is correlated to the Arduino:
```java
arduino = new Arduino(this, Arduino.list()[0], 57600);
println(Arduino.list()[0]);
```


## Acknowledgements
  * [Thomas Lengeling](https://github.com/ThomasLengeling) - Special thanks to Thomas Lengeling for his library [KinectPV2](https://github.com/ThomasLengeling/KinectPV2) which allowed us to receieve data from the Kinect, visualize the data, and made debugging simpler by using his example code [SkeletonColor.pde](https://github.com/ThomasLengeling/KinectPV2/blob/master/KinectPV2/examples/SkeletonColor/SkeletonColor.pde)

## Contact
thomasanderson@agbotics.tech

## License
Copyright (c) 2019 Thomas Anderson

Licensed Under [MIT](https://github.com/tt-anderson/robotic-arm-software/blob/master/LICENSE).
