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
AudioRecorder        recorder;
Geo                  geo;

/*------------------------------------------------------------------------------------------------------*/

boolean              rec = false;
boolean              display = false;
int                  index;
int                  currentMillis;
JSONObject           data;

/*------------------------------------------------------------------------------------------------------*/

void setup() {
  
  size(700,1000,P3D);
  smooth();
  
  // init toxiclibs
  gfx = new ToxiclibsSupport(this);
  
  // init geometry
  geo = new Geo();
  
  // init minim
  minim = new Minim(this);
  
  // init audio utils
  in = minim.getLineIn(Minim.STEREO, 1024);
  
  fftLin = new FFT(in.bufferSize(), in.sampleRate());
  
  beat = new BeatDetect(in.bufferSize(), in.sampleRate());
  beat.setSensitivity(100);
  
  bl = new BeatListener(beat, in); 
  
  // init array for data storage
  data = new JSONObject();
  
}

void draw() {
  
  background(255);
  
  // set title
  surface.setTitle((int(frameRate) + " fps"));
  
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
  translate(width/2,height/2,0);
    
    // show rec info
    if(rec) 
      stroke(255,0,0);
    else 
      stroke(0);
      
    noFill();
    strokeWeight(.5);
    
    String[] frequencyData = {};
    
    // update freuquency info
    fftLin.forward(in.mix);
    
    // display freuqency
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
  
  // display graphic
  if(display) 
  {
    geo.display();
    noLoop();
  }
  
}


void setNewIndex() {
  
  // get previous id from file
  String lines[] = loadStrings("data/index.txt");
  int newId = parseInt(lines[0]);
  lines[0] = str(newId+=1);
  saveStrings("data/index.txt", lines);
  
  // set new id
  index = newId;
  
  // create archiv folder
  createOutput("data/archiv/"+nf(index,4)+"/.dummy");
  
}

void mousePressed() {
  
  rec = true;
  display = false;
  
  // set new index
  setNewIndex();
  
  // start recording
  currentMillis = millis();
  
  // init recorder object
  recorder = minim.createRecorder(in, "data/archiv/"+nf(index,4)+"/"+nf(index,4)+".wav");
  
  // start recording
  if(!recorder.isRecording())
  {
    recorder.beginRecord();
  }
  
  display = false;
  loop();
  
}

void mouseReleased() {
  
  rec = false;
  
  // save json data
  saveJSONObject(data, "data/archiv/"+nf(index,4)+"/data.json");
  
  // stop and save recording
  if(recorder.isRecording())
  {
    recorder.endRecord();
    recorder.save();
  }
  
  // clear data object
  data = new JSONObject();
  
  // show graphic
  display = true;
  
  geo.loadData(index);
  
}

void keyPressed() {
  
  if (key == 'n') 
  {
    display = false;
    loop();
  }

}