final int SIZE=300;
final int AMOUNT=300;
float r=20;
float e=1;
float maxSpeed=10;
float totalSpeed;
float saveColor;

PVector[] position=new PVector[AMOUNT];
PVector[] velocity=new PVector[AMOUNT];
float[] mass=new float[AMOUNT];

void setup(){
  size(600,600,P3D);
  for(int i=0;i<AMOUNT;i++){
    position[i]=new PVector(random((-SIZE+r)/2.0,(SIZE-r)/2.0),random((-SIZE+r)/2.0,(SIZE-r)/2.0),random((-SIZE+r)/2.0,(SIZE-r)/2.0));
    //velocity[i]=PVector.random3D().mult(maxSpeed/2.0);
    velocity[i]=PVector.random3D().mult(random(0,maxSpeed));
    mass[i]=1;
  }
}

void draw(){
  frameRate(60);
  colorMode(RGB,256,256,256);
  background(0);
  ambientLight(60,60,60);
  translate(width/2.0,height/2.0,0);
  //rotateY(frameCount/300.0);
  noFill();
  stroke(255);
  strokeWeight(2);
  box(SIZE);
  //lightSpecular(5,30,80);
  lightSpecular(80,80,80);
  directionalLight(255,255,255,-1,1,-1);
  specular(255,255,255);
  fill(255,255,255);
  noStroke();
  //totalSpeed=0;
  for(int i=0;i<AMOUNT-1;i++){
    for(int j=i+1;j<AMOUNT;j++){
      float d;
      d=dist(position[i].x,position[i].y,position[i].z,position[j].x,position[j].y,position[j].z);
      if(d<=r){collision(i,j,d);}
    }
  }
  for(int i=0;i<AMOUNT;i++){
    if(position[i].x+r/2.0>=SIZE/2.0){position[i].x=(SIZE-r)/2.0;velocity[i].x*=-1;}
    else if(position[i].x-r/2.0<=-SIZE/2.0){position[i].x=(-SIZE+r)/2.0;velocity[i].x*=-1;}
    if(position[i].y+r/2.0>=SIZE/2.0){position[i].y=(SIZE-r)/2.0;velocity[i].y*=-1;}
    else if(position[i].y-r/2.0<=-SIZE/2.0){position[i].y=(-SIZE+r)/2.0;velocity[i].y*=-1;}
    if(position[i].z+r/2.0>=SIZE/2.0){position[i].z=(SIZE-r)/2.0;velocity[i].z*=-1;}
    else if(position[i].z-r/2.0<=-SIZE/2.0){position[i].z=(-SIZE+r)/2.0;velocity[i].z*=-1;}
    position[i].add(velocity[i]);
  }
  for(int i=0;i<AMOUNT;i++){
    ///*
    colorMode(HSB,360,100,100);
    saveColor=velocity[i].mag()*(240/maxSpeed);
    if(saveColor>239){saveColor=239;}
    saveColor=239-saveColor;
    fill(saveColor,70,99);
    //*/
    //if(i>=AMOUNT-1){fill(240,128,36);}
    pushMatrix();
    translate(position[i].x,position[i].y,position[i].z);
    sphere(r/2.0);
    popMatrix();
    //totalSpeed+=velocity[i].mag();
  }
  //println(totalSpeed);
  camera(mouseX,mouseY,400, width/2,height/2,0, 0,1,0);
}

void collision(int particle,int other,float distance){
  PVector impulse;
  PVector difference;
  impulse=PVector.sub(velocity[particle],velocity[other]).mult(-e-1).div(1/mass[particle]+1/mass[other]);
  velocity[particle]=PVector.add(velocity[particle],impulse.div(mass[particle]));
  velocity[other]=PVector.add(velocity[other],impulse.mult(-1).div(mass[other]));
  difference=PVector.sub(position[particle],position[other]);
  difference.normalize();
  difference.mult((r-distance)/2.0);
  position[particle].add(difference);
  position[other].add(difference.mult(-1));
}
