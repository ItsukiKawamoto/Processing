import java.awt.Color;

final PVector CAMERA_POSITION = new PVector(0, 0, 500);

final int[] RGB_RANGE = {255, 255, 255};
final int[] HSB_RANGE = {359, 99, 99};

final int COLOR_NUM = 11;
final int S_MAX = 80;
final int S_MIN = 30;
final int B_MAX = 45;
final int B_MIN = 5;
final float PICK_UP_RATE = 5.0;
PImage[][][][] img = new PImage[2][COLOR_NUM][floor((S_MAX - S_MIN) / PICK_UP_RATE) + 1][floor((B_MAX - B_MIN) / PICK_UP_RATE) + 1];

final int BAND_NUM = 45;
float[] ampMax = new float[BAND_NUM];
float[] preAmp = new float[BAND_NUM];

final int BACKGROUND_NUM = 400;
final int BACKGROUND_DISTANCE = 1000;
PVector[] backgroundPosition = new PVector[BACKGROUND_NUM];
int[][] backgroundColor = new int[BACKGROUND_NUM][3];

final int PARTICLE_MAX_NUM = 600;
final float PARTICLE_MAX_SPEED = 15.0;
final float PARTICLE_MIN_ACCELERATION = 1.0;
final float PARTICLE_MAX_ACCELERATION = 3.8;
final float PARTICLE_MIN_SPEED_VARIANT = 100.0;
final float PARTICLE_MAX_SPEED_VARIANT = 250.0;
final float MAX_VIGOR = 5.0;
int tmpParticleNum;
float tmpAcceleration;
float tmpBandAcceleration;
float tmpParticleSpeedVariant;

final int GRAVITY_POINT_NUM_CUBE_ROOT = 3;
final int MAX_X_DISTANCE = 450;
final int MAX_Y_DISTANCE = 200;
final int MAX_Z_DISTANCE = 180;
final float RANDOM_RATE = 0.15;
final float MIN_BLACK_RADIUS = 30.0;
final float MAX_BLACK_RADIUS = 50.0;
float blackRadius;
int[] gravityState = {floor(GRAVITY_POINT_NUM_CUBE_ROOT / 2.0), floor(GRAVITY_POINT_NUM_CUBE_ROOT / 2.0), floor(GRAVITY_POINT_NUM_CUBE_ROOT / 2.0)};
int setCount = int(random(10000, 15000));
int count = 0;
int resetCount = 0;

Particle[] particles;
GravityPoint[][][] gravityPoints;

void createImages() {
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < COLOR_NUM; j++) {
      float h = (((float)HSB_RANGE[0] + 1) * 2 / 3) - j * (((float)HSB_RANGE[0] + 1) * 5 / 6) / ((float)COLOR_NUM - 1);
      h = (h < 0) ? h + (HSB_RANGE[0] + 1) : h;
      for (int s = S_MIN; s < S_MAX + 1; s += PICK_UP_RATE) {
        for (int b = B_MIN; b < B_MAX + 1; b += PICK_UP_RATE) {
          float[] hsbValue = {h, s, (i == 0) ? constrain(b + 20, 0, HSB_RANGE[2]) : b};
          switch (i) {
          case 0:
            img[0][j][floor((s - S_MIN) / PICK_UP_RATE)][floor((b - B_MIN) / PICK_UP_RATE)] = createSparkle(HSBtoRGB(hsbValue)[0], HSBtoRGB(hsbValue)[1], HSBtoRGB(hsbValue)[2]);
            break;
          case 1:
            img[1][j][floor((s - S_MIN) / PICK_UP_RATE)][floor((b - B_MIN) / PICK_UP_RATE)] = createLight(HSBtoRGB(hsbValue)[0], HSBtoRGB(hsbValue)[1], HSBtoRGB(hsbValue)[2]);
            break;
          }
        }
      }
    }
  }
}

void initializeVisualSettings() {
  hint(DISABLE_DEPTH_TEST);
  blendMode(SCREEN);
  imageMode(CENTER);

  for (int i = 0; i < BAND_NUM; i++) {
    ampMax[i] = 1.0;
    preAmp[i] = 0.0;
  }

  float backgroundHeight = (CAMERA_POSITION.z + BACKGROUND_DISTANCE) * tan(PI / 6);
  float backgroundWidth = backgroundHeight * width / height;
  for (int i = 0; i < BACKGROUND_NUM; i++) {
    backgroundPosition[i] = new PVector(random(-backgroundWidth, backgroundWidth), random(-backgroundHeight, backgroundHeight), -BACKGROUND_DISTANCE);
    backgroundColor[i][0] = round(((((float)HSB_RANGE[0] + 1) * 2 / 3) - random(((float)HSB_RANGE[0] + 1) / 12, ((float)HSB_RANGE[0] + 1) / 6)) / ((((float)HSB_RANGE[0] + 1) * 5 / 6) / ((float)COLOR_NUM - 1)));
    backgroundColor[i][1] = floor(random(floor((S_MAX - S_MIN) / PICK_UP_RATE) * 0.3));
    backgroundColor[i][2] = floor(random(floor((B_MAX - B_MIN) / PICK_UP_RATE) + 1));
  }

  gravityPoints = new GravityPoint[GRAVITY_POINT_NUM_CUBE_ROOT][GRAVITY_POINT_NUM_CUBE_ROOT][GRAVITY_POINT_NUM_CUBE_ROOT];
  for (int x = 0; x < GRAVITY_POINT_NUM_CUBE_ROOT; x++) {
    for (int y = 0; y < GRAVITY_POINT_NUM_CUBE_ROOT; y++) {
      for (int z = 0; z < GRAVITY_POINT_NUM_CUBE_ROOT; z++) {
        float tmpX = map(x, 0, GRAVITY_POINT_NUM_CUBE_ROOT - 1, -1, 1);
        float tmpY = map(y, 0, GRAVITY_POINT_NUM_CUBE_ROOT - 1, -1, 1);
        float tmpZ = map(z, 0, GRAVITY_POINT_NUM_CUBE_ROOT - 1, -1, 1);
        if (Float.isNaN(tmpX)) tmpX = 0.0;
        if (Float.isNaN(tmpY)) tmpY = 0.0;
        if (Float.isNaN(tmpZ)) tmpZ = 0.0;
        if (tmpX == 0.0 && tmpY == 0.0 && tmpZ == 0.0) {
          gravityPoints[x][y][z] = new GravityPoint(new PVector(0, 0, 0));
        } else {
          tmpX *= MAX_X_DISTANCE;
          tmpY *= MAX_Y_DISTANCE;
          tmpZ *= MAX_Z_DISTANCE;
          tmpX *= (CAMERA_POSITION.z - tmpZ) * tan(PI / 6) * 2 / height;
          tmpY *= (CAMERA_POSITION.z - tmpZ) * tan(PI / 6) * 2 / height;
          gravityPoints[x][y][z] = new GravityPoint(new PVector(random(tmpX - MAX_X_DISTANCE * RANDOM_RATE, tmpX + MAX_X_DISTANCE * RANDOM_RATE), random(tmpY - MAX_Y_DISTANCE * RANDOM_RATE, tmpY + MAX_Y_DISTANCE * RANDOM_RATE), random(tmpZ - MAX_Z_DISTANCE * RANDOM_RATE, tmpZ + MAX_Z_DISTANCE * RANDOM_RATE)));
        }
      }
    }
  }

  tmpParticleNum = 0;
  particles = new Particle[PARTICLE_MAX_NUM];
  for (int i = 0; i < PARTICLE_MAX_NUM; i++) {
    particles[i] = new Particle(gravityPoints[gravityState[0]][gravityState[1]][gravityState[2]].position());
  }
}

void createVisuals(AudioPlayer player, FFT fft, boolean pausing) {
  pushMatrix();
  translate(width / 2.0, height / 2.0, 0.0);
  camera(CAMERA_POSITION.x, CAMERA_POSITION.y, CAMERA_POSITION.z, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);

  float[] gain = new float[BAND_NUM];
  for (int i = 0; i < BAND_NUM; i++) {
    if (fft.getBand(i) > ampMax[i]) ampMax[i] = fft.getBand(i);
    gain[i] = (fft.getBand(i) - preAmp[i]) * 0.08 / sqrt(ampMax[i]) * sq(player.mix.level()) * frameRate;
    if (gain[i] < 0.0) gain[i] = 0.0;
    preAmp[i] = fft.getBand(i);
  }

  if (player.position() > player.length() - 1000.0) {
    tmpParticleNum -= floor(constrain(sq((player.length() - player.position()) / 1000.0) * (PARTICLE_MAX_NUM / frameRate), 5.0, PARTICLE_MAX_NUM / frameRate));
    if (tmpParticleNum < 0) tmpParticleNum = 0;
  } else if (!pausing) {
    tmpParticleNum = int(constrain(player.mix.level() * PARTICLE_MAX_NUM * 300.0, 0, PARTICLE_MAX_NUM));
  }

  tmpAcceleration = (player.mix.level() == 0.0) ? PARTICLE_MIN_ACCELERATION : constrain(sq(player.mix.level()) * 70.0, PARTICLE_MIN_ACCELERATION, PARTICLE_MAX_ACCELERATION);

  PVector tmpGravityPointDirection = PVector.sub(gravityPoints[gravityState[0]][gravityState[1]][gravityState[2]].position(), CAMERA_POSITION);
  PVector zUnit = tmpGravityPointDirection.normalize(null);
  PVector xUnit = (zUnit.x == 0.0 && zUnit.y == 0.0) ? new PVector(1, 0, 0) : new PVector(zUnit.y, -zUnit.x, 0).normalize();
  PVector yUnit = zUnit.cross(xUnit);
  blackRadius = constrain(MAX_BLACK_RADIUS - sq(player.mix.level()) * 10.0 * (MAX_BLACK_RADIUS - MIN_BLACK_RADIUS), MIN_BLACK_RADIUS, MAX_BLACK_RADIUS);

  for (int i = 0; i < BACKGROUND_NUM; i++) {
    if (player.mix.level() == 0.0) {
      pushMatrix();
      translate(backgroundPosition[i].x, backgroundPosition[i].y, backgroundPosition[i].z);
      image(img[0][backgroundColor[i][0]][backgroundColor[i][1]][backgroundColor[i][2]], 0.0, 0.0);
      popMatrix();
    } else {
      PVector tmpBackgroundDirection = PVector.sub(backgroundPosition[i], gravityPoints[gravityState[0]][gravityState[1]][gravityState[2]].position());
      float tmpXNorm = PVector.dot(tmpBackgroundDirection, xUnit);
      float tmpYNorm = PVector.dot(tmpBackgroundDirection, yUnit);
      float tmpZNorm = PVector.dot(tmpBackgroundDirection, zUnit);
      float shadeRadius = blackRadius * (1 + tmpZNorm / tmpGravityPointDirection.mag());
      if (sq(tmpXNorm) + sq(tmpYNorm) > sq(shadeRadius)) {
        pushMatrix();
        translate(backgroundPosition[i].x, backgroundPosition[i].y, backgroundPosition[i].z);
        image(img[0][backgroundColor[i][0]][backgroundColor[i][1]][backgroundColor[i][2]], 0.0, 0.0);
        popMatrix();
      }
    }
  }

  for (int i = 0; i < tmpParticleNum; i++) {
    int tmpBand = i % BAND_NUM;
    int sizeMax = floor(constrain(sq(fft.getBand(tmpBand) / ampMax[tmpBand]) * floor((B_MAX - B_MIN) / PICK_UP_RATE) * 5.0, 0, floor((B_MAX - B_MIN) / PICK_UP_RATE)));
    int size;
    int type = 1;
    float r = random(1);
    if (r < 0.4) {
      type = 0;
      size = floor(random(sizeMax + 1));
    } else if (r >= 0.4 && r < 0.6) {
      size = floor(random((sizeMax + 1) * 3 / 8));
    } else if (r >= 0.6 && r < 0.9) {
      size = floor(random((sizeMax + 1) * 3 / 8, (sizeMax + 1) * 7 / 8));
    } else {
      size = floor(random((sizeMax + 1) * 7 / 8, sizeMax + 1));
    }

    tmpBandAcceleration = tmpAcceleration / log((tmpBand) * 0.03 + 2.72); //e ≒ 2.72
    tmpParticleSpeedVariant = constrain(sq(fft.getBand(tmpBand) / ampMax[tmpBand]) * (tmpBand + 1), PARTICLE_MIN_SPEED_VARIANT, PARTICLE_MAX_SPEED_VARIANT);

    PVector tmpParticleDirection = PVector.sub(particles[i].position(), gravityPoints[gravityState[0]][gravityState[1]][gravityState[2]].position());
    if (tmpParticleDirection.mag() > blackRadius) {
      float tmpZNorm = PVector.dot(tmpParticleDirection, zUnit);
      if (tmpZNorm < 0) {
        particles[i].display(type, floor(map(tmpBand, 0, BAND_NUM - 1, 0, COLOR_NUM - 1)), size);
      } else {
        float tmpXNorm = PVector.dot(tmpParticleDirection, xUnit);
        float tmpYNorm = PVector.dot(tmpParticleDirection, yUnit);
        float shadeRadius = blackRadius * (1 + tmpZNorm / tmpGravityPointDirection.mag());
        if (sq(tmpXNorm) + sq(tmpYNorm) > sq(shadeRadius)) {
          particles[i].display(type, floor(map(tmpBand, 0, BAND_NUM - 1, 0, COLOR_NUM - 1)), size);
        }
      }
    }
    particles[i].update(gain[tmpBand], gravityPoints[gravityState[0]][gravityState[1]][gravityState[2]].position());
  }

  if (player.mix.level() > 0.3) {
    if (millis() - count > setCount) {
      if (random(1) < 0.5) {
        gravityState[0] = floor(random(GRAVITY_POINT_NUM_CUBE_ROOT));
        gravityState[1] = floor(random(GRAVITY_POINT_NUM_CUBE_ROOT));
        gravityState[2] = floor(random(GRAVITY_POINT_NUM_CUBE_ROOT));
        resetCount = millis();
      }
      setCount = int(random(3000, 5000));
      count = millis();
    }
  } else {
    if (gravityState[0] == floor(GRAVITY_POINT_NUM_CUBE_ROOT / 2.0) && gravityState[1] == floor(GRAVITY_POINT_NUM_CUBE_ROOT / 2.0) && gravityState[2] == floor(GRAVITY_POINT_NUM_CUBE_ROOT / 2.0)) {
      resetCount = millis();
    } else {
      if (millis() - resetCount > 10000) {
        gravityState[0] = floor(GRAVITY_POINT_NUM_CUBE_ROOT / 2.0);
        gravityState[1] = floor(GRAVITY_POINT_NUM_CUBE_ROOT / 2.0);
        gravityState[2] = floor(GRAVITY_POINT_NUM_CUBE_ROOT / 2.0);
        resetCount = millis();
      }
    }
  }
  for (GravityPoint[][] gravityPoints1 : gravityPoints) {
    for (GravityPoint[] gravityPoints2 : gravityPoints1) {
      for (GravityPoint gravityPoints3 : gravityPoints2) {
        gravityPoints3.update();
        //gravityPoints3.display();
      }
    }
  }
  popMatrix();
}

float[] HSBtoRGB(float[] hsb) {
  float[] rgb = new float[3];
  Color colorRGB = new Color(Color.HSBtoRGB(hsb[0] / (float)HSB_RANGE[0], hsb[1] / (float)HSB_RANGE[1], hsb[2] / (float)HSB_RANGE[2]));
  rgb[0] = ((float)colorRGB.getRed() * ((float)RGB_RANGE[0] / 255.0));
  rgb[1] = ((float)colorRGB.getGreen() * ((float)RGB_RANGE[1] / 255.0));
  rgb[2] = ((float)colorRGB.getBlue() * ((float)RGB_RANGE[2] / 255.0));
  return rgb;
}

PImage createSparkle(float rPower, float gPower, float bPower) {
  int side = 200;
  float center = side / 2.0;
  PImage img = createImage(side, side, RGB);
  for (int y = 0; y < side; y++) {
    for (int x = 0; x < side; x++) {
      float distance = sqrt(sq(center - x) + sq(center - y));
      int r = int(rPower / distance);
      int g = int(gPower / distance);
      int b = int(bPower / distance);
      img.pixels[x + y * side] = color(r, g, b);
    }
  }
  return img;
}

PImage createLight(float rPower, float gPower, float bPower) {
  int side = 200;
  float center = side / 2.0;
  PImage img = createImage(side, side, RGB);
  for (int y = 0; y < side; y++) {
    for (int x = 0; x < side; x++) {
      float distance = (sq(center - x) + sq(center - y)) / 50.0;
      int r = int(rPower / distance);
      int g = int(gPower / distance);
      int b = int(bPower / distance);
      img.pixels[x + y * side] = color(r, g, b);
    }
  }
  return img;
}

void changeGravityState(int axis, boolean sign) {
  if (sign) {
    if (gravityState[axis] < GRAVITY_POINT_NUM_CUBE_ROOT - 1) gravityState[axis]++;
  } else {
    if (gravityState[axis] > 0) gravityState[axis]--;
  }
}

class Particle {
  private PVector position;
  private PVector velocity;

  Particle(PVector init) {
    position = new PVector(init.x, init.y, init.z);
    setRandomVelocity();
  }

  void setRandomVelocity() {
    velocity = PVector.random3D();
    velocity.mult(random(PARTICLE_MAX_SPEED * 2) - PARTICLE_MAX_SPEED);
  }

  void display(int type, int band, int size) {
    pushMatrix();
    translate(position.x, position.y, position.z);
    image(img[type][band][floor(map(velocity.mag(), 0, PARTICLE_MAX_SPEED, 0, floor((S_MAX - S_MIN) / PICK_UP_RATE)))][size], 0, 0);
    popMatrix();
  }

  void update(float vigor, PVector gravityPoint) {
    PVector direction = PVector.sub(gravityPoint, position);
    direction.normalize();
    PVector acceleration = PVector.mult(direction, tmpBandAcceleration);
    velocity.add(acceleration);
    PVector velocityVariant = PVector.random3D();
    velocityVariant.mult(map(constrain(sq(vigor), 0, MAX_VIGOR), 0, MAX_VIGOR, 0, tmpParticleSpeedVariant));
    velocity.add(velocityVariant);
    velocity.limit(PARTICLE_MAX_SPEED);
    position.add(velocity);
  }

  PVector position() {
    return position;
  }
}

class GravityPoint {
  private PVector origin;
  private PVector position;
  private PVector velocity;
  private float seedX, seedY, seedZ;
  private long time;

  GravityPoint(PVector origin) {
    this.origin = origin;
    position = PVector.random3D();
    position.mult(random(10, 30));
    position.add(origin);
    velocity = PVector.random3D();
    seedX = random(10);
    seedY = random(10);
    seedZ = random(10);
    time = 0;
  }

  void display() {
    fill(150, 150, 150);
    noStroke();
    lights();
    pushMatrix();
    translate(position.x, position.y, position.z);
    sphere(30);
    popMatrix();
  }

  void update() {
    PVector noise = new PVector(map(noise(seedX, time * 0.05), 0.0, 1.0, -1.0, 1.0), map(noise(seedY, time * 0.05), 0.0, 1.0, -1.0, 1.0), map(noise(seedZ, time * 0.05), 0.0, 1.0, -1.0, 1.0));
    noise.limit(0.01);
    velocity.add(noise);
    PVector acceleration = PVector.sub(origin, position);
    acceleration.normalize().mult(0.02);
    velocity.add(acceleration);
    velocity.limit(1.0);
    position.add(velocity);
    time++;
  }

  PVector position() {
    return position;
  }
}
