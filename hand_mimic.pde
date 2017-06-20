//Libraries
import com.leapmotion.leap.*;
import processing.serial.*;
import org.firmata.*;
import cc.arduino.*;

Arduino arduino;
Serial port;

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

//Setup LeapMotion Controller
Controller controller  =  new Controller();

//Setup
void setup()
{
  //Size of data/image
  size(800, 500);
  
  //Background color
  background(255);
  
  //Setup the servos and serial communication
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  arduino.pinMode(opposableServo, Arduino.SERVO);
  arduino.pinMode(thumbServo, Arduino.SERVO);
  arduino.pinMode(indexServo, Arduino.SERVO);
  arduino.pinMode(middleServo, Arduino.SERVO);
  arduino.pinMode(ringpinkyServo, Arduino.SERVO);
  arduino.pinMode(wristServo, Arduino.SERVO);
  
  //check which serial port
  //printArray(Serial.list());
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
      println("WRIST: ", palmResults);
      
      //Only include positive integers
      if(palmResults >= 0)
      {
        //Write to the servo, the palm results
        arduino.servoWrite(wristServo, palmResults);
      }
      
      break;
    }
    
    /* |||||||||||||||||||||||||| FINGERS |||||||||||||||||||||||||||| */
    //Loop through all the fingers
    for (Finger finger : frame.fingers()) {
        //Get finger type
         Finger.Type fingerType  =  finger.type();
         
         //Get ring finger
         Finger index = controller.frame().hands().get(0).fingers().get(1);
         
         //Get thumb
         Finger thumb = controller.frame().hands().get(0).fingers().get(0);
         
         //Warning is due to TYPE_RING being not included in the code (commented out); ignore
         switch (fingerType)
         {
           case TYPE_THUMB:
              
              //Distal Bone; Get the vector
              Vector distalVector = thumb.bone(Bone.Type.TYPE_DISTAL).basis().getZBasis();
              
              //Metacarpal Bone; Get the vector
              Vector metacarpalVector = finger.bone(Bone.Type.TYPE_METACARPAL).basis().getZBasis();
            
              //Ring Finger Metacarpal Bone; Get the vector
              Vector index_metacarpalVector  =  index.bone(Bone.Type.TYPE_DISTAL).basis().getZBasis();
                
              //Calculate the angle bewteen the thumb proximal bone, to the ring's metacarpal bone; convert to degrees
              float opposableAngle  =  distalVector.angleTo(index_metacarpalVector) * 180/PI;
              
              //Calculate the angle between the thumb proximal bone, to the thumb's metacarpal bone; convert to degrees
              float thumbAngle = distalVector.angleTo(metacarpalVector) * 180/PI;
              
              //Ratio for oppossable thumb angle
              float opposableRatio = 1.8;
            
              //Multiply the opposable thumb raw angle by the ratio and add 90 to the value
              opposableRatio *= opposableAngle + 90;
              
              //Ratio for thumb angle
              float thumbRatio = 1.8;
              
              //Multiply the thumb raw angle by the ratio
              thumbRatio *= thumbAngle;
              
              //arduino.servoWrite doesn't support float, so convert and round to integer; subract 180 to have it start from 0
              int opposableAngleFinal = (int) opposableRatio - 180;
              int thumbAngleFinal = (int) thumbRatio - 180;
              
              //Print absolute value angle of opposable thumb to console
              println("OPPOSABLE: ", Math.abs(opposableAngleFinal));
              
              //Print absolute value angle of thumb to console
              println("THUMB: ", Math.abs(thumbAngleFinal));
              
              //Check if the angle of the opposable thumb is between 90 and 175 for safety reasons
              if(Math.abs(opposableAngleFinal) >= 90 && Math.abs(opposableAngleFinal) <= 175)
              {
                //Write to the servo, the position of the opposable thumb angle; use absolute value (convert negative to positive value)
                arduino.servoWrite(opposableServo, Math.abs(opposableAngleFinal));
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
              //float indexRatio = 180;
              
              //Subract 180 from raw angle value to get value 180 to 0
              //indexRatio -= indexAngle;
              
              //arduino.servoWrite doesn't support float, so convert and round to integer
              int indexAngleFinal = (int) indexAngle;
              
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
              
              //Ratio for middle finger
              float middleRatio = 1.2;
               
              //Mutliply the raw angle value by the ratio
              middleRatio *= middleAngle;
              
              //arduino.servoWrite doesn't support float, so convert and round to integer
              int middleAngleFinal = (int) middleRatio;
              
              //Print to console, the middle final angle value
              println("MIDDLE: ", middleAngleFinal);
              
              //Write to the servo, the middle final angle vlue
              arduino.servoWrite(middleServo, middleAngleFinal);  
              
              break;
           
           /* Don't need ring because ring and pinky are connected to one servo
           case TYPE_RING:
           
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
              int pinkyAngleFinal = (int) pinkyRatio;
              
              //Print to console, the final pinky angle
              println("PINKY: ", pinkyAngleFinal);
              
              //Write to the servo, the final pinky angle
              arduino.servoWrite(ringpinkyServo, pinkyAngleFinal);  

              break;
        } 
    }
}