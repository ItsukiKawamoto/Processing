import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;
AudioPlayer player;
FFT fft;

boolean keyReleased = true;
boolean folderLoaded = false;
boolean trackSelected = false;
boolean pausing = false;
boolean display = false;
boolean looping = false;
int volume = 8;
int displayDelayCount = 0;
int keyDelayCount = 0;

void setup() {
  fullScreen(P3D);
  frameRate(60);

  minim = new Minim(this);

  createImages();
  initializeVisualSettings();
  initializeUISettings();

  selectFolder("Select a folder to load:", "folderSelected");
}

void draw() {
  background(0, 0, 0);
  if (folderLoaded) {
    noCursor();
    if (trackSelected) {
      fft.forward(player.mix);
      createVisuals(player, fft, pausing);

      if (!player.isPlaying() && !pausing && player.position() > 0.0) {
        if (transitionToNextTrack(looping)) {
          player.close();
          player = minim.loadFile(selectedTrack());
          fft = new FFT(player.bufferSize(), player.sampleRate());
          player.play();
        }
      }

      if (display) displayTrackName(looping);
      if (millis() - displayDelayCount < 1000) {
        fill(120, 120, 120);
        rect(width - 320.0, 4.0, 300.0, 20.0);
        fill(255, 255, 255);
        rect(width - 320.0, 4.0, 300.0 / 16 * volume, 20.0);
      }

      if (keyPressed) {
        if (keyReleased) {
          if (key == ENTER) {
            player.pause();
            player.rewind();
            player.play();
          } else if (key == ' ') {
            if (player.isPlaying()) {
              player.pause();
              pausing = true;
            } else {
              player.play();
              pausing = false;
            }
          } else if (keyCode == RIGHT) {
            if (transitionToNextTrack(looping)) {
              player.close();
              player = minim.loadFile(selectedTrack());
              fft = new FFT(player.bufferSize(), player.sampleRate());
              if (!pausing) player.play();
            }
          } else if (keyCode == LEFT) {
            if (transitionToPrevTrack(looping)) {
              player.close();
              player = minim.loadFile(selectedTrack());
              fft = new FFT(player.bufferSize(), player.sampleRate());
              if (!pausing) player.play();
            }
          } else if (key == 'm') {
            player.close();
            trackSelected = false;
          } else if (key == 'n') {
            display = !display;
          } else if (key == 'l') {
            looping = !looping;
          } else if (key == 'd') {
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
        if (millis() - keyDelayCount > 100) {
          if (keyCode == UP) {
            volume = constrain(++volume, 0, 16);
            player.setGain(10.0 * log(map(volume, 0, 16, pow(10.0, -8), 1.0)) / log(10.0));
            displayDelayCount = millis();
          } else if (keyCode == DOWN) {
            volume = constrain(--volume, 0, 16);
            player.setGain(10.0 * log(map(volume, 0, 16, pow(10.0, -8), 1.0)) / log(10.0));
            displayDelayCount = millis();
          }
          keyDelayCount = millis();
        }
        keyReleased = false;
      } else {
        keyReleased = true;
      }
    } else {
      selectTrack();

      if (looping) displayLoopState();

      if (keyPressed) {
        if (keyReleased) {
          if (key == ENTER) {
            player = minim.loadFile(selectedTrack());
            fft = new FFT(player.bufferSize(), player.sampleRate());
            player.play();
            trackSelected = true;
          } else if (key == 'r') {
            randomSort();
          } else if (key == 't') {
            ascendingSort();
          } else if (key == 'l') {
            looping = !looping;
          }
        }
        if (millis() - keyDelayCount > 100) {
          if (keyCode == DOWN) {
            shiftDownward();
          } else if (keyCode == UP) {
            shiftUpward();
          }
          keyDelayCount = millis();
        }
        keyReleased = false;
      } else {
        keyReleased = true;
      }
    }
  }
}

void stop() {
  player.close();
  minim.stop();
  super.stop();
}

void folderSelected(File selection) {
  int loadState = loadFiles(selection);
  if (loadState == 0) {
    folderLoaded = true;
  } else if (loadState == 1) {
    exit();
  } else if (loadState == 2) {
    selectFolder("Select a folder to load:", "folderSelected");
  }
}
