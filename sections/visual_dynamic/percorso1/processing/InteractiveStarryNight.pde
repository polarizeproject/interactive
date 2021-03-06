final int STAGE_WIDTH = 1200;
final int STAGE_HEIGHT = 950;
final int NB_PARTICLES = 60000;
final float MAX_PARTICLE_SPEED = 5;

final int MIN_LIFE_TIME = 20;
final int MAX_LIFE_TIME = 80;
final String IMAGE_PATH = "starrynight.jpg";

myVector tabParticles[];
float particleSize = 1.2;
PImage myImage;
int imageW;
int imageH;
color myPixels[];
FlowField ff;
GUI gui;

void setup()
{
  size(1200, 950, P3D);
  background(0);
  initializeImage();
  initializeParticles();
  ff = new FlowField(5);
  gui = new GUI(this);
  gui.setup();
}

void initializeImage()
{
  myImage = loadImage(IMAGE_PATH);
  imageW = myImage.width;
  imageH = myImage.height;
  myPixels = new color[imageW * imageH];
  myImage.loadPixels();
  myPixels = myImage.pixels;
  image(myImage, 0, 0);
}

void setParticle(int i) {
  tabParticles[i] = new myVector((int)random(imageW), (int)random(imageH));
  tabParticles[i].prevX = tabParticles[i].x;
  tabParticles[i].prevY = tabParticles[i].y;
  tabParticles[i].count = (int)random(MIN_LIFE_TIME, MAX_LIFE_TIME);
  tabParticles[i].myColor = myPixels[(int)(tabParticles[i].y)*imageW + (int)(tabParticles[i].x)];
}

void initializeParticles()
{
  tabParticles = new myVector[NB_PARTICLES];
  for (int i = 0; i < NB_PARTICLES; i++)
  {
    setParticle(i);
  }
}

void draw()
{
  ff.setRadius(gui.getR());
  ff.setForce(gui.getF());
  particleSize = gui.getS();
  float vx;
  float vy;
  PVector v;
  for (int i = 0; i < NB_PARTICLES; i++)
  {
    tabParticles[i].prevX = tabParticles[i].x;
    tabParticles[i].prevY = tabParticles[i].y;
    v = ff.lookup(tabParticles[i].x, tabParticles[i].y);
    vx = v.x;
    vy = v.y;
    vx = constrain(vx, -MAX_PARTICLE_SPEED, MAX_PARTICLE_SPEED);
    vy = constrain(vy, -MAX_PARTICLE_SPEED, MAX_PARTICLE_SPEED);
    tabParticles[i].x += vx;
    tabParticles[i].y += vy;
    tabParticles[i].count--;
    if ((tabParticles[i].x < 0) || (tabParticles[i].x > imageW-1) ||
      (tabParticles[i].y < 0) || (tabParticles[i].y > imageH-1) ||
      tabParticles[i].count < 0) {
      setParticle(i);
    }
    strokeWeight(1.5*particleSize);
    stroke(tabParticles[i].myColor, 250);
    line(tabParticles[i].prevX, tabParticles[i].prevY, tabParticles[i].x, tabParticles[i].y);
  }
  ff.updateField();
}

void mouseDragged() {
  if(mouseX>950 && mouseY>830) return;
  ff.onMouseDrag();
}

void keyPressed() {
  //if (key =='s' || key == 'S') {
  //  ff.saveField();
  //}
}

class myVector extends PVector
{
  myVector (float p_x, float p_y) {
    super(p_x, p_y);
  }
  float prevX;
  float prevY;
  int count;
  color myColor;
}



import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

class FlowField {
  PVector[][] field;
  PVector[][] tempField;
  int cols, rows;
  int resolution;
  int affectRadius;
  float force;
  File file = new File(dataPath("field.txt"));

  FlowField(int r) {
    resolution = r;
    cols = 1200 / resolution;
    rows = 950 / resolution;
    field = new PVector[cols][rows];
    tempField = new PVector[cols][rows];
    init();
    affectRadius = 3;
    force = 1;
  }

  void setRadius(int r) {
    affectRadius = r;
  }

  void setForce(float f) {
    force = f;
  }

  void init() {
    try { 
      for (int i=0; i<cols; i++) {
        for (int j=0; j<rows; j++) {
          tempField[i][j] = new PVector(0, 0);
        }
      }
      readField();
    }
    catch(Exception e) {
      for (int i=0; i<cols; i++) {
        for (int j=0; j<rows; j++) {
          field[i][j] = new PVector(0, 0);
        }
      }
    }
  }

  PVector lookup(float x, float y) {
    int column = int(constrain(x/resolution, 0, cols-1));
    int row = int(constrain(y/resolution, 0, rows-1));
    return PVector.add(field[column][row],tempField[column][row]);
  }

  void drawBrush() {
    pushStyle();
    noFill();
    stroke(255, 255, 255);
    ellipse(mouseX, mouseY, affectRadius*10, affectRadius*10);
    popStyle();
  }

  void drawField(float x, float y, PVector v) {
    int column = int(constrain(x/resolution, 0, cols-1));
    int row = int(constrain(y/resolution, 0, rows-1));
    for (int i=-affectRadius; i<=affectRadius; i++) {
      for (int j=-affectRadius; j<=affectRadius; j++) {
        if (i*i+j*j<affectRadius*affectRadius) {
          try { 
            tempField[column+i][row+j].add(v).mult(0.9);
          }
          catch(Exception e) {
          }
        }
      }
    }
  }
  
  void updateField(){
    for (int i=0; i<cols; i++) {
        for (int j=0; j<rows; j++) {
          tempField[i][j].mult(0.992);
        }
      }
  }
  void onMouseDrag() {
    PVector direc = new PVector(mouseX-pmouseX, mouseY-pmouseY).normalize();
    drawField(pmouseX, pmouseY, direc.mult(force));
  }

  void saveField() {
    try {
      FileWriter out = new FileWriter(file);
      for (int i=0; i<cols; i++) {
        for (int j=0; j<rows; j++) {
          out.write(field[i][j].x+","+field[i][j].y+"\t");
        }
        out.write("\r\n");
      }
      out.close();
    }
    catch(Exception e) {
    }
  }

  void readField() throws IOException {
    try {
      BufferedReader example = new BufferedReader(new FileReader(file));
      String line;
      for (int i = 0; (line = example.readLine()) != null; i++) {
        String[] temp = line.split("\t"); 
        for (int j=0; j<temp.length; j++) {
          String[] xy = temp[j].split(",");
          float x = Float.parseFloat(xy[0]);
          float y = Float.parseFloat(xy[1]);
          field[i][j] = new PVector(x, y);
        }
      }
      example.close();
    }
    catch(Exception e) {
      throw new IOException("no field.txt");
    }
  }
}


import controlP5.*;

class GUI {
  ControlP5 cp5;
  Slider sliderR;
  Slider sliderF;
  Slider sliderS;
  GUI(PApplet thePApplet){
    cp5 = new ControlP5(thePApplet);
  }
  
  void setup(){
    cp5.setColorBackground(0x141414);
    sliderR = cp5.addSlider("Radius")
                 .setPosition(980,890)
                 .setRange(1,20)
                 .setValue(12).setSize(150,25);
    sliderF = cp5.addSlider("Force")
                 .setPosition(980,918)
                 .setRange(0.1,0.5)
                 .setValue(0.3).setSize(150,25);
    sliderS = cp5.addSlider("Particle Size")
                 .setPosition(980,862)
                 .setRange(0.8,2)
                 .setValue(1.5).setSize(150,25);
    
  }
  
  int getR(){
    return int(sliderR.getValue());
  }
  
  float getF(){
    return sliderF.getValue();
  }
  
  float getS(){
    return sliderS.getValue();
  }
}
