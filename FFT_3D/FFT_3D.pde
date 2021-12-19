import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer player;
AudioInput in;
FFT fft;

float[][] values;
int freqBand = 50; //fft.specSize()
int timeWidth = 100;

float rotX = PI / 3;
float rotZ = PI / 6;

void setup() {
  size(500, 500, P3D);
  frameRate(60);
  fill(0);
  stroke(255);
  strokeWeight(2);

  minim = new Minim(this);
  player = minim.loadFile("サンタは中央線でやってくる.mp3");
  player.play();
  //in = minim.getLineIn(Minim.MONO, 1024);
  fft = new FFT(player.bufferSize(), player.sampleRate());

  values = new float[fft.specSize()][timeWidth];
  for (int i = 0; i < fft.specSize(); i++) {
    for (int j = 0; j < timeWidth; j++) {
      values[i][j] = 0.0;
    }
  }

  for (int i = 0; i < freqBand; i++) { 
    println(i + " = " + fft.getBandWidth()*i + " ~ "+ fft.getBandWidth()*(i+1));
  }
}

void draw() {
  fft.forward(player.mix);
  for (int i = 0; i < fft.specSize(); i++) {
    for (int j = 0; j < timeWidth - 1; j++) {
      if (j != timeWidth - 2) {
        values[i][j] = values[i][j + 1];
      } else {
        values[i][j] = fft.getBand(i);
      }
    }
  } 

  background(0);
  translate(width / 2, height / 2, -150);
  if (mousePressed) {
    rotX = map(constrain(mouseY, 0, height), 0, height, 0, PI / 2);
    rotZ = map(constrain(mouseX, 0, width), 0, width, -PI / 2, PI / 2);
  }
  rotateX(rotX);
  rotateZ(rotZ);

  for (int i = 0; i < freqBand; i++) {
    beginShape();
    for (int j = 0; j < timeWidth; j++) {
      float x = map(i, 0, freqBand - 1, -height / 2, height / 2);
      float y = map(j, 0, timeWidth - 1, width / 2, -width / 2); 
      float z = values[i][j] * 1;
      vertex(x, y, z);
    }
    endShape();
  }
}
