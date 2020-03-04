//Libraries
import com.leapmotion.leap.*;
import processing.serial.*;
import org.firmata.*;
import cc.arduino.*;

Arduino arduino;
Serial port;

//Opposable Thumb
int opposableServo = 7;
//Thumb
int thumbServo = 5;
//Index
int indexServo = 2;
//Middle
int middleServo = 3;
//Ring and Pinky
int ringpinkyServo = 4;
//Wrist
int wristServo = 6;

//Setup LeapMotion Controller
Controller controller  =  new Controller();

//Setup
void setup()
{
  //Size of data/image
  size(500, 500);

  //Background color
  background(255);

  //Setup the servos and serial communication
  printArray(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  arduino.pinMode(opposableServo, Arduino.SERVO);
  arduino.pinMode(thumbServo, Arduino.SERVO);
  arduino.pinMode(indexServo, Arduino.SERVO);
  arduino.pinMode(middleServo, Arduino.SERVO);
  arduino.pinMode(ringpinkyServo, Arduino.SERVO);
  arduino.pinMode(wristServo, Arduino.SERVO);

  if(controller.isConnected()) {
    DeviceList connectedLeaps = controller.devices();
    println("Connected Leap(s): " + connectedLeaps.toString());
  }
}

void draw() {
    //background color
    background(255);

    //Setup to capture frames
    Frame frame  =  controller.frame();

    /* ||||||||||||||||||||| WRIST ||||||||||||||||||||||| */
    //loop through each hand
    for (Hand hand : frame.hands()) {
      //Get roll (z axis) of palm and convert to degrees
      float palmOrientation = hand.palmNormal().roll() * 180/PI;

      //arduino.servoWrite doesn't support float, so convert to integer and round to whole number
      int palmResults = (int) palmOrientation;
      

      //Print to console, the palm results
      println("WRIST: ", Math.abs(180 - palmResults));

      //Only include positive integers
      if(palmResults >= 0)
      {
        //Write to the servo, the palm results
        arduino.servoWrite(wristServo, Math.abs(180 - palmResults));
      }

      break;
    }

    /* |||||||||||||||||||||||||| FINGERS |||||||||||||||||||||||||||| */
    //Loop through all the fingers
    for (Finger finger : frame.fingers()) {
      
         //Get finger type
         Finger.Type fingerType  =  finger.type();
        
         /* 0 - Thumb, 1 - Index, 2 - Middle, 3 - Ring, 4 - Pinky */
         //Get index finger
         Finger pinky = controller.frame().hands().get(0).fingers().get(4);
         
         //Warning is due to TYPE_RING being not included in the code (commented out); ignore
         switch (fingerType)
         {
           case TYPE_THUMB:

              //Thumb Distal Bone; Get the vector
              Vector thumbDistal = finger.bone(Bone.Type.TYPE_DISTAL).basis().getZBasis();

              //Thumb Metacarpal Bone; Get the vector
              Vector thumbMetacarpal = finger.bone(Bone.Type.TYPE_METACARPAL).basis().getZBasis();
              
              Vector thumbProximal = finger.bone(Bone.Type.TYPE_PROXIMAL).basis().getZBasis();
              
              Vector pinkyMetacarpal = pinky.bone(Bone.Type.TYPE_METACARPAL).basis().getZBasis();
              
              // Angle between two vectors
              float oppAngle = acos(((pinkyMetacarpal.dot(thumbProximal) / (thumbProximal.magnitude() * pinkyMetacarpal.magnitude())))) * (180/PI);          
              
              float thumbAngle = acos(((thumbMetacarpal.dot(thumbDistal) / (thumbMetacarpal.magnitude() * thumbDistal.magnitude())))) * (180/PI);
              
              // Normalize the angle value (subtract by 180 to get 90 - 180)
              int oppAngleFinal = (int) (oppAngle * norm(oppAngle, 0, 45)) - 180;
              
              int thumbAngleFinal = (int) (thumbAngle * norm(thumbAngle, 0, 60));

              println("Thumb Angle: " + thumbAngleFinal);

              //Check if the angle of the opposable thumb is between 90 and 175 for safety reasons
              if(Math.abs(oppAngleFinal) >= 90 && Math.abs(oppAngleFinal) <= 175)
              {
                
                //Print absolute value angle of thumb to console
                println("Opposable Thumb Angle: " + Math.abs(oppAngleFinal));
                
                //Write to the servo, the position of the opposable thumb angle; use absolute value (convert negative to positive value)
                arduino.servoWrite(opposableServo, Math.abs(oppAngleFinal));
              }

              //Write to the servo, the position of the thumb angle; use absolute value (convert negative to positive value)
              arduino.servoWrite(thumbServo, Math.abs(thumbAngleFinal));

              break;

           case TYPE_INDEX:

              //Metacarpal Bone; Get the direction
              Vector indexMetacarpalVector  =  finger.bone(Bone.Type.TYPE_METACARPAL).basis().getZBasis();

              //Distal Bone; Get the direction
              Vector indexDistalVector  =  finger.bone(Bone.Type.TYPE_DISTAL).basis().getZBasis();

              //Calculate the angle bewteen the metacarpal and distal bone; convert to degrees.
              float indexAngle  =  indexMetacarpalVector.angleTo(indexDistalVector) * 180/PI;

              //Set float to value 180
              float indexRatio = 180;

              //Subract 180 from raw angle value to get value 180 to 0
              indexRatio -= indexAngle;

              //arduino.servoWrite doesn't support float, so convert and round to integer
              int indexAngleFinal = (int) (indexRatio * norm(indexRatio, 0, 165));
              
              //Print to console, the index final angle value
              println("INDEX: ", indexAngleFinal);

              //Write to the servo, the index final angle value
              arduino.servoWrite(indexServo, indexAngleFinal);

              break;

           case TYPE_MIDDLE:

              //Metacarpal Bone; Get the direction
              Vector middleMetacarpalVector  =  finger.bone(Bone.Type.TYPE_METACARPAL).basis().getZBasis();

              //Distal Bone; Get the direction
              Vector middleDistalVector  =  finger.bone(Bone.Type.TYPE_DISTAL).basis().getZBasis();

              //Calculate the angle bewteen the metacarpal and distal bone; convert to degrees
              double middleAngle  =  middleMetacarpalVector.angleTo((middleDistalVector)) * 180/PI;

              //arduino.servoWrite doesn't support float, so convert and round to integer
              int middleAngleFinal = (int) middleAngle; //(middleRatio - middleAngle);

              //Print to console, the middle final angle value
              println("MIDDLE: ", middleAngleFinal);

              //Write to the servo, the middle final angle vlue
              arduino.servoWrite(middleServo, middleAngleFinal);

              break;

           /* Don't need ring because ring and pinky are connected to one servo
           case TYPE_RING:

             |||| old and possibly defunct code |||
             //Metacarpal Bone; Get the direction
              Vector ringMetacarpalVector  =  finger.bone(Bone.Type.TYPE_METACARPAL).basis().getZBasis();

              //Distal Bone; Get the direction
              Vector ringDistalVector  =  finger.bone(Bone.Type.TYPE_DISTAL).basis().getZBasis();

              //Calculate the angle bewteen the metacarpal and distal bone; convert to degrees
              float ringAngle  =  ringMetacarpalVector.angleTo(ringDistalVector) * 180/PI;

              //arduino.servoWrite doesn't support float, so convert and round to integer
              int result4 = (int) angle4;

              println("RING: ", result4);

              arduino.servoWrite(ringpinkyServo, result4);
              delay(5);

              break;
           */

           //Use the pinky to move the ring and pinky in sync (easier to manipulate pinky)
           case TYPE_PINKY:

             //Metacarpal Bone; Get the direction
              Vector pinkyMetacarpalVector  =  finger.bone(Bone.Type.TYPE_METACARPAL).basis().getZBasis();

              //Distal Bone; Get the direction
              Vector pinkyDistalVector  =  finger.bone(Bone.Type.TYPE_DISTAL).basis().getZBasis();

              //Calculate the angle bewteen the metacarpal and distal bone; convert to degrees
              float pinkyAngle  =  pinkyMetacarpalVector.angleTo(pinkyDistalVector) * 180/PI;

              //Ratio for pinky finger
              float pinkyRatio = 180;

              //Subract 180 from raw angle value to convert to 180 to 0
              pinkyRatio -= pinkyAngle;

              //arduino.servoWrite doesn't support float, so convert and round to integer
              int pinkyAngleFinal = (int) (pinkyRatio * norm(pinkyRatio, 0, 145));

              //Print to console, the final pinky angle
              println("PINKY: ", pinkyAngleFinal);

              //Write to the servo, the final pinky angle
              arduino.servoWrite(ringpinkyServo, pinkyAngleFinal);

              break;
        }
    }
}
