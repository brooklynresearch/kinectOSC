
import SimpleOpenNI.*;
import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;

SimpleOpenNI  context;
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };
PVector com = new PVector();                                   
PVector com2d = new PVector();                                   

void setup()
{
  size(640,480);
  oscP5 = new OscP5(this,12000); 
  myRemoteLocation = new NetAddress("192.168.0.200",12345);
  
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  // enable depthMap generation 
  context.enableDepth();
   
  // enable skeleton generation for all joints
  context.enableUser();
 
  background(200,0,0);

  stroke(0,0,255);
  strokeWeight(3);
  smooth();
  
  // pitch is base joint
  OscMessage myMessage = new OscMessage("/sPitch");
  
  myMessage.add(int(random(2047))); /* add an int to the osc message */
  myMessage.add(200);

  /* send the message */
  oscP5.send(myMessage, myRemoteLocation);
  
  // roll is extender
  OscMessage myMessage2 = new OscMessage("/sRoll");
  
  myMessage2.add(int(random(2047))); /* add an int to the osc message */
  myMessage2.add(200);
  oscP5.send(myMessage2, myRemoteLocation);
}

void draw()
{
  // update the cam
  context.update();
  
  // draw depthImageMap
  //image(context.depthImage(),0,0);
  image(context.userImage(),0,0);
  
  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    if(context.isTrackingSkeleton(userList[i]))
    {
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);
    }      
      
    // draw the center of mass
    if(context.getCoM(userList[i],com))
    {
      context.convertRealWorldToProjective(com,com2d);
      stroke(100,255,0);
      strokeWeight(1);
      beginShape(LINES);
        vertex(com2d.x,com2d.y - 5);
        vertex(com2d.x,com2d.y + 5);

        vertex(com2d.x - 5,com2d.y);
        vertex(com2d.x + 5,com2d.y);
      endShape();
      
      fill(0,255,100);
      text(Integer.toString(userList[i]),com2d.x,com2d.y);
    }
  }    
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
//  PVector jointPos = new PVector();
//  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
//  println(jointPos);
  
  PVector rightShoulder = new PVector();
  float confidenceShoulder = context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER,rightShoulder);
  println(rightShoulder);
  
  PVector rightElbow = new PVector();
  float confidenceElbow = context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,rightElbow);
  println(rightElbow);
  
  PVector rightHip = new PVector();
  float confidenceHip = context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HIP,rightHip);
  println(rightHip);
  
  PVector rightShoulderXZ = new PVector(rightShoulder.x, rightShoulder.z);
  PVector rightElbowXZ = new PVector(rightElbow.x, rightElbow.z);
  PVector rightHipXZ = new PVector(rightHip.x, rightHip.z);
  
  PVector torsoOrientationXZ = PVector.sub(rightShoulderXZ, rightHipXZ);
  
  float shoulderAngleXZ = angleOf(rightElbowXZ, rightShoulderXZ, torsoOrientationXZ);
  
  PVector rightShoulderXY = new PVector(rightShoulder.x, rightShoulder.y);
  PVector rightElbowXY = new PVector(rightElbow.x, rightElbow.y);
  PVector rightHipXY = new PVector(rightHip.x, rightHip.y);
  
  PVector torsoOrientationXY = PVector.sub(rightShoulderXY, rightHipXY);
  
  float shoulderAngleXY = angleOf(rightElbowXY, rightShoulderXY, torsoOrientationXY);
  
  PVector rightShoulderYZ = new PVector(rightShoulder.y, rightShoulder.z);
  PVector rightElbowYZ = new PVector(rightElbow.y, rightElbow.z);
  PVector rightHipYZ = new PVector(rightHip.y, rightHip.z);
  
  PVector torsoOrientationYZ = PVector.sub(rightShoulderYZ, rightHipYZ);
  
  float shoulderAngleYZ = angleOf(rightElbowYZ, rightShoulderYZ, torsoOrientationYZ);
  
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  

  fill(255,0,0);
  scale(3);
  text("shoulderXZ: " + int(shoulderAngleXZ), 20, 20);
  text("shoulderXY: " + int(shoulderAngleXY), 20, 60);
  text("shoulderYZ: " + int(shoulderAngleYZ), 20, 100);
  
  if (confidenceShoulder > 0.5 && confidenceElbow > 0.5 && confidenceHip > 0.5){
    OscMessage myMessage = new OscMessage("/sPitch");
    
    int pitch = int(map(shoulderAngleXZ, 0, 180, 0, 2047));
    println("pitch: " + pitch);
    
    myMessage.add(pitch); /* add an int to the osc message */
    myMessage.add(20);
//  
//    /* send the message */
    oscP5.send(myMessage, myRemoteLocation);
    
    // roll is extender
    OscMessage myMessage2 = new OscMessage("/sRoll");
    
    int roll = int(map(shoulderAngleXY, 0, 180, 0, 2047));
    println("pitch: " + roll);
    
    myMessage2.add(roll); /* add an int to the osc message */
    myMessage2.add(20);
    oscP5.send(myMessage2, myRemoteLocation);  
  }
}

float angleOf(PVector one, PVector two, PVector axis) {
  PVector limb = PVector.sub(two, one);
  
  return degrees(PVector.angleBetween(limb, axis));
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }
}  

