import toxi.geom.*;
import toxi.math.*;
import toxi.math.noise.*;
import toxi.processing.*;
import processing.pdf.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

ToxiclibsSupport gfx;
Minim minim;  
FFT fftLin;
AudioInput in;
ScaleMap logMap;

boolean rec = false, debug = true;
int index;

void setup() {
  
  size(700,1000,P3D);
  smooth();
  
  // init toxiclibs
  gfx = new ToxiclibsSupport(this);
  
  // init minim
  minim = new Minim(this);
  
  // init audio utils
  in = minim.getLineIn();
  
  fftLin = new FFT( in.bufferSize(), in.sampleRate() );
  fftLin.linAverages( 10 );
  
  // set index
  setNewIndex();
  
}

void draw() {
  
  background(255);
  
  // show rec info
  if(rec) 
    fill(255,0,0);
  else 
    fill(200);
    
  ellipseMode(CENTER);
  noStroke();
  ellipse(width/2, height-100, 60, 60);
  
  // show freuqence
  pushMatrix();
  translate(width/2,height-(height/5),0);
  
    fftLin.forward(in.mix);
    
    stroke(0);
    noFill();
    strokeWeight(1);
    
    for(int i = 0; i < fftLin.specSize(); i+=1) 
    {
      
      float x = map(i, 0, fftLin.specSize(), 0, -width*2);
      int scale = 10;
      float smoothFactor = 0.2;
      
      line(x, 0, x, 0 - fftLin.getBand(i) * smoothFactor * scale);
      line(-x, 0, -x, 0 - fftLin.getBand(i) * smoothFactor * scale);
      line(x, 0, x, 0 + fftLin.getBand(i) * smoothFactor * scale);
      line(-x, 0, -x, 0 + fftLin.getBand(i)* smoothFactor * scale);
    }

  popMatrix();

}

void setNewIndex() {
  
  String lines[] = loadStrings("data/index.txt");
  int newId = parseInt(lines[0]);
  lines[0] = str(newId+=1);
  saveStrings("data/index.txt", lines);
  
  index = newId;
  
}

void mousePressed() {
  
  rec = true;
  
  // set new index
  setNewIndex();
  
}

void mouseReleased() {
  
  rec = false;
  
}