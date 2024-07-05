import com.jogamp.opengl.GLProfile;
{
  GLProfile.initSingleton();
}

import processing.sound.*;

AudioIn in;
Amplitude amp;
FFT fft;

final int FFT_BAND_NUM = 128;

boolean keyReleased = true;

void setup() {
  fullScreen(P3D);
  frameRate(60);

  Sound.inputDevice("Background Music");

  in = new AudioIn(this, 0);
  in.start();

  amp = new Amplitude(this);
  amp.input(in);

  fft = new FFT(this, FFT_BAND_NUM);
  fft.input(in);

  createImages();
  initializeVisualSettings();
}

void draw() {
  background(0, 0, 0);
  noCursor();

  createVisuals(amp, fft);

  if (keyPressed) {
    if (keyReleased) {
      if (key == 'd') {
        changeGravityState(0, true);
      } else if (key == 'a') {
        changeGravityState(0, false);
      } else if (key == 's') {
        changeGravityState(1, true);
      } else if (key == 'w') {
        changeGravityState(1, false);
      } else if (key == 'z') {
        changeGravityState(2, true);
      } else if (key == 'x') {
        changeGravityState(2, false);
      }
    }
    keyReleased = false;
  } else {
    keyReleased = true;
  }
}

void stop() {
  in.stop();
  super.stop();
}
