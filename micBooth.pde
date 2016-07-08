import toxi.geom.*;
import toxi.math.*;
import toxi.math.noise.*;
import toxi.processing.*;
import processing.pdf.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

/*------------------------------------------------------------------------------------------------------*/

ToxiclibsSupport     gfx;
Minim                minim;
FFT                  fftLin;
AudioInput           in;
BeatDetect           beat;
BeatListener         bl;

/*------------------------------------------------------------------------------------------------------*/

boolean              rec = false;
int                  index;
int                  currentMillis;
JSONObject           data;

/*------------------------------------------------------------------------------------------------------*/

void setup() {
  
  size(700,1000,P3D);
  
  // init toxiclibs
  gfx = new ToxiclibsSupport(this);
  
  // init minim
  minim = new Minim(this);
  
  // init audio utils
  in = minim.getLineIn(Minim.STEREO, 1024);
  fftLin = new FFT( in.bufferSize(), in.sampleRate() );
  beat = new BeatDetect(in.bufferSize(), in.sampleRate());
  beat.setSensitivity(100);
  bl = new BeatListener(beat, in); 
  
  // init array for data storage
  data = new JSONObject();
  
}

void draw() {
  
  background(255);
  
  // update freuquency info
  fftLin.forward(in.mix);
  
  // set title
  surface.setTitle((int(frameRate) + " fps"));
  
  // show rec info
  if(rec) 
    fill(255,0,0);
  else 
    fill(200);
    
  ellipseMode(CENTER);
  noStroke();
  ellipse(width/2, height-100, 60, 60);
  
  // show time info
  if(rec) 
  {
    fill(0);
    noStroke();
    textAlign(CENTER, CENTER);
    textSize(14);
        
    text(nf((millis()-currentMillis)/1000,2)+" Seconds", 0, height-100, width, 100);
    
  }
  
  // show freuqence
  pushMatrix();
  translate(width/2,height-(height/5),0);
  
    stroke(0);
    noFill();
    strokeWeight(.5);
    
    String[] frequencyData = {};
        
    for(int i = 0; i < fftLin.specSize(); i++) 
    {
      
      float x = map(i, 0, fftLin.specSize(), 0, -width/2);
      int scale = 20;
      float smoothFactor = 0.3;
      
      if((i % 5) == 0) 
      {
        line(x, 0, x, 0 - fftLin.getBand(i) * smoothFactor * scale);
        line(-x, 0, -x, 0 - fftLin.getBand(i) * smoothFactor * scale);
        line(x, 0, x, 0 + fftLin.getBand(i) * smoothFactor * scale);
        line(-x, 0, -x, 0 + fftLin.getBand(i)* smoothFactor * scale);
      }  
      
      if(rec) 
        if((i % 5) == 0) 
          frequencyData = append(frequencyData, str(fftLin.getBand(i)));
          
    }
        
    // save json data
    if(rec) 
    {
      
      JSONObject timer = new JSONObject();
                 timer.setInt("timestamp", millis()-currentMillis);
                 timer.setString("data", join(frequencyData, ","));
                 timer.setBoolean("isKick", beat.isKick());
                 timer.setBoolean("iSnare", beat.isSnare());
                 timer.setBoolean("isHat", beat.isHat());
      
      data.setJSONObject(str(frameCount), timer);
      
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

void resetProject() {
  
  data = new JSONObject();
  
}

void mousePressed() {
  
  rec = true;
  
  // set new index
  setNewIndex();
  
  // start recording
  currentMillis = millis();
  
}

void mouseReleased() {
  
  rec = false;
  
  // save file
  saveJSONObject(data, "data/archiv/"+nf(index,4)+"/new.json");
  
  resetProject();
  
}