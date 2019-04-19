import processing.serial.*;
import KinectPV2.KJoint;
import KinectPV2.*;
import cc.arduino.*;

Arduino arduino;
KinectPV2 kinect;
Serial port;

int elbowServo = 1;

void setup() {
  size(1920, 1080, P3D);

  kinect = new KinectPV2(this);
  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);

  kinect.init();
  
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  println(Arduino.list()[0]);
  
  arduino.pinMode(elbowServo, Arduino.SERVO);
 
  frameRate(60);
}

void draw() {
  image(kinect.getColorImage(), 0, 0, width, height);

  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();

  //individual joints
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      color col  = skeleton.getIndexColor();
      fill(col);
      stroke(col);
      drawBody(joints);

      //draw different color for each hand state
      drawHandStateRight(joints[KinectPV2.JointType_HandRight]);
      drawHandState(joints[KinectPV2.JointType_HandLeft]);
    
      elbowAngle(joints);
    }
  }
  
  fill(255, 0, 0);
}

void elbowAngle(KJoint[] joints) {
  
  // Get the right shoudler's x,y,z position
  float shoulderXPos = joints[KinectPV2.JointType_ShoulderRight].getX();
  float shoulderYPos = joints[KinectPV2.JointType_ShoulderRight].getY();
  float shoulderZPos = joints[KinectPV2.JointType_ShoulderRight].getZ();
  
  // Get the right elbow's x,y,z position
  float elbowXPos = joints[KinectPV2.JointType_ElbowRight].getX();
  float elbowYPos = joints[KinectPV2.JointType_ElbowRight].getY();
  float elbowZPos = joints[KinectPV2.JointType_ElbowRight].getZ();
  
  // Get the right wrist's x,y,z position
  float wristXPos = joints[KinectPV2.JointType_WristRight].getX();
  float wristYPos = joints[KinectPV2.JointType_WristRight].getY();
  float wristZPos = joints[KinectPV2.JointType_WristRight].getZ();
  
  // Create two vectors from the difference of x,y,z between the shoudler and elbow
  PVector vector1 = new PVector((shoulderXPos - elbowXPos), (shoulderYPos - elbowYPos), (shoulderZPos - elbowZPos)); 
  PVector vector2 = new PVector((elbowXPos - wristXPos), (elbowYPos - wristYPos), (elbowZPos - wristZPos));
  
  // Normalize the vectors
  PVector vector1Norm = new PVector((vector1.x / vector1.mag()), (vector1.y / vector1.mag()), (vector1.z / vector1.mag()));
  PVector vector2Norm = new PVector((vector2.x / vector2.mag()), (vector2.y / vector2.mag()), (vector2.z / vector2.mag()));
  
  // Calculate the dot product of the two vectors
  float dotProduct = vector1Norm.dot(vector2Norm);
  
  // Get the inverse cosine of the dotProduct divided by the magnitudeProduct, convert to degrees and cast to an int
  int angle = (int) Math.toDegrees(acos(dotProduct));
  
  println("Elbow Angle: ", angle);
  textSize(75);
  text("Elbow Angle: " + Math.abs(angle), 150, 150);
  
  //Send the angle over serial communication to arduino
  arduino.servoWrite(elbowServo, Math.abs(angle));
}

//DRAW BODY
void drawBody(KJoint[] joints) {
  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  // Right Arm
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  // Right Leg
  drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  // Left Leg
  drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

  drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  drawJoint(joints, KinectPV2.JointType_HandTipRight);
  drawJoint(joints, KinectPV2.JointType_FootLeft);
  drawJoint(joints, KinectPV2.JointType_FootRight);

  drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  drawJoint(joints, KinectPV2.JointType_ThumbRight);

  drawJoint(joints, KinectPV2.JointType_Head);
}

//draw joint
void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
}

//draw bone
void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  pushMatrix();
  translate(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
  line(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}

//draw hand state
void drawHandState(KJoint joint) {
  noStroke();
  handState(joint.getState());
  pushMatrix();
  translate(joint.getX(), joint.getY(), joint.getZ());
  ellipse(0, 0, 70, 70);
  popMatrix();
}

void drawHandStateRight(KJoint joint) {
  noStroke();
  handStateRight(joint.getState());
  pushMatrix();
  translate(joint.getX(), joint.getY(), joint.getZ());
  ellipse(0, 0, 70, 70);
  popMatrix();
}

/*
 Different hand state
 KinectPV2.HandState_Open
 KinectPV2.HandState_Closed
 KinectPV2.HandState_Lasso
 KinectPV2.HandState_NotTracked
 */
void handState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    fill(0, 255, 0);
    break;
    
  case KinectPV2.HandState_Closed:
    fill(255, 0, 0);
    break;
    
  case KinectPV2.HandState_Lasso:
    fill(0, 0, 255);
    break;
  case KinectPV2.HandState_NotTracked:
    fill(255, 255, 255);
    break;
  }
}

void handStateRight(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    fill(0, 255, 0);
    //port.write(100);
    break;
    
  case KinectPV2.HandState_Closed:
    fill(255, 0, 0);
    //port.write(101);
    break;
    
  case KinectPV2.HandState_Lasso:
    fill(0, 0, 255);
    break;
  case KinectPV2.HandState_NotTracked:
    fill(255, 255, 255);
    break;
  }
}
