/*
Known Issues/Bugs:
* Improper displaying and trasmiting of angle values when both hands are recognized
* OpposableAngle returns a static angle, presumably not the correct angle.
*/
//Libraries
import com.leapmotion.leap.*;
import processing.serial.*;
import org.firmata.*;
import cc.arduino.*;

PFont font;

Arduino arduino;
Serial port;

int[] servo = new int[7];

//Setup LeapMotion Controller
Controller controller  =  new Controller();

public int wristAngle(Hand hand) {
  //Get roll (z axis) of palm and convert to degrees
  float palmOrientation = hand.palmNormal().roll() * 180/PI;

  //arduino.servoWrite doesn't support float, so convert to integer and round to whole number
  return (int) Math.abs(palmOrientation);
}

//TODO: Fix OpposableAngle ***
public int oppAngle() {
  Finger oppThumb = controller.frame().hands().get(0).fingers().get(0);
  Finger pinky = controller.frame().hands().get(0).fingers().get(4);
  Vector metacarpal = pinky.bone(Bone.Type.TYPE_METACARPAL).basis().getZBasis();
  Vector proximal = oppThumb.bone(Bone.Type.TYPE_METACARPAL).basis().getZBasis();

  int oppAngle = (int) Math.abs(Math.toDegrees(metacarpal.angleTo(proximal)));

  return (int) Math.abs(oppAngle * norm(oppAngle, 0, 45));
}

public int fingerAngle(Finger finger) {
  Vector distal = finger.bone(Bone.Type.TYPE_DISTAL).basis().getZBasis();
  Vector metacarpal = finger.bone(Bone.Type.TYPE_METACARPAL).basis().getZBasis();

  return  (int) Math.abs(Math.toDegrees(metacarpal.angleTo(distal)));
}

//Setup
void setup() {
  //Size of data/image
  size(800, 500);

  font = createFont("Arial", 16);

  //Background color
  background(255);

  //Setup the servos and serial communication
  printArray(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  for(byte i = 2; i < servo.length; i++) {
    servo[i] = i;
    arduino.pinMode(servo[i], Arduino.SERVO);
  }

  println("Controller Status: " + controller.isConnected());
  if(controller.isConnected()) {
    DeviceList connectedLeaps = controller.devices();
    println("Connected Leap(s): " + connectedLeaps.toString());
  }
}

void draw() {
  //background color
  background(255);
  textFont(font, 16);
  textSize(26);
  fill(0);

  //Setup to capture frames
  Frame frame  =  controller.frame();

  //loop through each hand
  for(Hand hand : frame.hands()) {
    if(hand.isRight()) {
      // textAlign(RIGHT);
      // text(wristAngle(hand), width/2,75);
      arduino.servoWrite(180 - wristAngle(hand), servo[7]);
    } else if(hand.isLeft()) {
      // textAlign(LEFT);
      // text(wristAngle(hand), width/2,115);
      arduino.servoWrite(wristAngle(hand), servo[2]);
    }

    for(Finger finger: frame.fingers()) {
      Finger.Type fingerType = finger.type();

      switch(fingerType) {

        /* Ommited writing servo values for opposable thumb; needs to be fixed */
        case TYPE_THUMB: {
          if(hand.isRight()) {
            //textAlign(RIGHT);
            text("Right Op Thumb: " + oppAngle(), width/1.75, height/2.3);
            text("Right Thumb: " + fingerAngle(finger), width/1.75, height/2);
            arduino.servoWrite(servo[8], fingerAngle(finger));
          } else if(hand.isLeft()) {
            //textAlign(LEFT);
            text("Left Op Thumb: " + oppAngle(), width/8, height/2.3);
            text("Left Thumb: " + fingerAngle(finger), width/8, height/2);
            arduino.servoWrite(servo[3], fingerAngle(finger));
          }
          break;
        }

        case TYPE_INDEX: {
          if(hand.isRight()) {
            text(("Right Index: " + fingerAngle(finger)), width/1.75, height/1.75);
            arduino.servoWrite(servo[9], (180 - fingerAngle(finger)));
          } else if(hand.isLeft()) {
            text("Left Index: " + (180 - fingerAngle(finger)), width/8, height/1.75);
            arduino.servoWrite(servo[4], (180 - fingerAngle(finger)));
          }
          break;
        }

        case TYPE_MIDDLE: {
          if(hand.isRight()) {
            text("Right Middle: " + fingerAngle(finger), width/1.75, height/1.55);
            arduino.servoWrite(servo[10], fingerAngle(finger));
          } else if(hand.isLeft()) {
            text("Left Middle: " + (fingerAngle(finger)), width/8, height/1.55);
            arduino.servoWrite(servo[5], fingerAngle(finger));
          }
          break;
        }

        case TYPE_PINKY: {
          if(hand.isRight()) {
            text("Right Ring: " + (180 - fingerAngle(finger)), width/1.75, height/1.4);
            arduino.servoWrite(servo[11], (180 - fingerAngle(finger)));
          } else if(hand.isLeft()) {
            text("Left Ring: " + (180 - fingerAngle(finger)), width/8, height/1.4);
            arduino.servoWrite(servo[6], (180 - fingerAngle(finger)));
          }
          break;
        }
      }
    }
  }
}
