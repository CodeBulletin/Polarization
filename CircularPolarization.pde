import peasy.*;
import shapes3d.*;

PeasyCam cam;


GraphAxes GX;
float axisLength = 420;
PVector[] wave1, wave2, wave3;

float wave1Phase, wave2Phase, wave1angle, wave2angle;

int animeMode, currentIndex, arrowMode, MarrowMode;
boolean pause;

void setup() {
  fullScreen(P3D);
  cam = new PeasyCam(this, 400);
  GX = new GraphAxes(-axisLength/2, axisLength/2, 0.8f);
  for (Shape3D shape : GX.children()) {
    shape.strokeWeight(0);
  }
  reset();
}

void arrow(float x1, float y1, float z1, float x2, float y2, float z2) {
  line(x1, y1, z1, x2, y2, z2);
  pushMatrix();
  translate(x2, y2);
  rotate(atan2(x1-x2, y2-y1) + PI/2);
  beginShape(TRIANGLES);
  vertex(0, 0, z1);
  vertex(-5, 2.5, z1);
  vertex(-5, -2.5, z1);
  endShape();
  popMatrix();
}

void reset() {
  wave1Phase = 0;
  wave1angle = 0;
  wave2Phase = PI/2;
  wave2angle = PI/2;
  animeMode = 0;
  arrowMode = 0;
  MarrowMode = 0;
  pause = false;
  recompute();
}

void recompute() {
  wave1 = genrateWave(50, 50, wave1Phase, wave1angle, int(axisLength/2) - 10, 3);
  wave2 = genrateWave(50, 50, wave2Phase, wave2angle, int(axisLength/2) - 10, 3);
  wave3 = SumWave(wave1, wave2);
  if (animeMode == 0) { 
    currentIndex = wave3.length;
  } else {
    currentIndex = 1;
  }
}

PVector[] genrateWave(float wavelength, float amp, float phase, float yangle, int lengthofwave, int steps) {
  PVector[] Points = new PVector[(lengthofwave+1)*steps + 1];
  float freq = 2.0f * PI / wavelength;
  int k = 0;
  for (int i = -1; i < lengthofwave; i++) {
    for (int j = steps; j > 0; j--) {
      float t = float(i) + 1/float(j);
      float y = amp * sin(freq * t + phase);
      Points[(i+1) * steps + (steps - j)] = new PVector(-y * sin(yangle), y * cos(yangle), t);
    }
  }
  float t = lengthofwave;
  float y = amp * sin(freq * t + phase);
  Points[Points.length - 1] = new PVector(-y * sin(yangle), y * cos(yangle), t);
  return Points;
}

PVector[] SumWave(PVector[] wave1, PVector[] wave2) {
  PVector[] waveSum = new PVector[min(wave1.length, wave2.length)];
  for (int i = 0; i < waveSum.length; i++) {
    waveSum[i] = new PVector();
    waveSum[i].x = wave1[i].x+wave2[i].x;
    waveSum[i].y = wave1[i].y+wave2[i].y;
    waveSum[i].z = wave1[i].z;
  }
  return waveSum;
}

void draw() {
  background(0);
  GX.draw(getGraphics());
  pushMatrix();
  noFill();
  strokeWeight(5);
  stroke(0, 255, 255, 255);
  beginShape();
  for (int i = 0; i < currentIndex; i++) {
    curveVertex(wave1[i].x, wave1[i].y, wave1[i].z);
  }
  endShape();
  stroke(0, 255, 255, 255);
  beginShape();
  for (int i = 0; i < currentIndex; i++) {
    curveVertex(wave2[i].x, wave2[i].y, wave2[i].z);
  }
  endShape();
  stroke(255, 0, 255, 255);
  beginShape();
  for (int i = 0; i < currentIndex; i++) {
    curveVertex(wave3[i].x, wave3[i].y, wave3[i].z);
  }
  endShape();
  popMatrix();
  if (arrowMode == 1) {
    pushMatrix();
    stroke(255, 255, 0, 255);
    arrow(wave1[currentIndex - 1].x, wave1[currentIndex - 1].y, wave1[currentIndex - 1].z, wave3[currentIndex - 1].x, wave3[currentIndex - 1].y, wave3[currentIndex - 1].z);
    arrow(wave2[currentIndex - 1].x, wave2[currentIndex - 1].y, wave2[currentIndex - 1].z, wave3[currentIndex - 1].x, wave3[currentIndex - 1].y, wave3[currentIndex - 1].z);
    if (MarrowMode == 1) {
      for (int i = 10; i < currentIndex; i+=30) {
        if (i < wave3.length) {        
          arrow(wave1[i].x, wave1[i].y, wave1[i].z, wave3[i].x, wave3[i].y, wave3[i].z);
          arrow(wave2[i].x, wave2[i].y, wave2[i].z, wave3[i].x, wave3[i].y, wave3[i].z);
        }
      }
    }
    popMatrix();
  }
  if (currentIndex < wave3.length && !pause) {
    currentIndex += 1;
  } else {
    animeMode = 0;
  }
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    reset();
    cam.reset();
  } else if (key == '1') {
    cam.reset();
  } else if (key == '2') {
    cam.rotateY(PI/2);
  } else if (key == '3') {
    cam.rotateX(PI/2);
  } else if (key == CODED) {
    if (keyCode == ESC) {
      exit();
    } else if (keyCode == UP) {
      wave1Phase += PI/128;
      recompute();
    } else if (keyCode == DOWN) {
      wave1Phase -= PI/128;
      recompute();
    } else if (keyCode == RIGHT) {
      wave2Phase += PI/128;
      recompute();
    } else if (keyCode == LEFT) {
      wave2Phase -= PI/128;
      recompute();
    }
  } else if (key == 'w' || key == 'W') {
    wave1angle += PI/128;
    recompute();
  } else if (key == 's' || key == 'S') {
    wave1angle -= PI/128;
    recompute();
  } else if (key == 'd' || key == 'D') {
    wave2angle += PI/128;
    recompute();
  } else if (key == 'a' || key == 'A') {
    wave2angle -= PI/128;
    recompute();
  } else if (key == 'z' || key == 'Z') {
    animeMode = animeMode == 0 ? 1 : 0;
    recompute();
  } else if (key == 'x' || key == 'X') {
    arrowMode = arrowMode == 0 ? 1 : 0;
  } else if (key == ' ') {
    pause = !pause;
  } else if (key == 'c' || key == 'C') {
    MarrowMode = MarrowMode == 0 ? 1 : 0;
  }
}
