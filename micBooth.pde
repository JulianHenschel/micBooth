import processing.pdf.*;
import toxi.geom.*;
import toxi.processing.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import java.text.SimpleDateFormat;
import java.util.Date;

/*------------------------------------------------------------------------------------------------------*/

ToxiclibsSupport     gfx;
Minim                minim;
FFT                  fftLin;
AudioInput           in;
BeatDetect           beat;
BeatListener         bl;
AudioRecorder        recorder;
Geo                  geo;
Date                 date;

/*------------------------------------------------------------------------------------------------------*/

boolean              rec = false;
boolean              display = false;
int                  index;
int                  currentMillis;
JSONObject           data;
PShape               logo;
PFont                font;

/*------------------------------------------------------------------------------------------------------*/

void setup() {
  
  size(550,800,P3D);
  smooth();
  
  // init date
  date = new Date();
  
  // init toxiclibs
  gfx = new ToxiclibsSupport(this);
  
  // init geometry
  geo = new Geo();
  
  // init minim
  minim = new Minim(this);
  
  // init audio utils
  in = minim.getLineIn(Minim.STEREO, 512);
  
  fftLin = new FFT(in.bufferSize(), in.sampleRate());
  
  beat = new BeatDetect(in.bufferSize(), in.sampleRate());
  beat.setSensitivity(1);
  
  bl = new BeatListener(beat, in); 
  
  // init array for data storage
  data = new JSONObject();
  
  // load logo file
  logo = loadShape("logo_02.svg");
  
  logo.disableStyle();
  logo.setFill(0);
  
  // load font
  font = createFont("Block Berthold Condensed.ttf", 90);
  textFont(font);
  
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
    textSize(24);
        
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
    
    // settings
    int scale = 20;
    float smoothFactor = 0.3;
    int resolution = 1;
        
    // display frequency
    for(int i = 0; i < fftLin.specSize(); i++) 
    {
      
      float x = map(i, 0, fftLin.specSize(), 0, -width/2);
      
      if((i % resolution) == 0) 
      {
        if(!display)
        {
          line(x, 0, x, 0 - fftLin.getBand(i) * smoothFactor * scale);
          line(-x, 0, -x, 0 - fftLin.getBand(i) * smoothFactor * scale);
          line(x, 0, x, 0 + fftLin.getBand(i) * smoothFactor * scale);
          line(-x, 0, -x, 0 + fftLin.getBand(i) * smoothFactor * scale);
        }
      }  
            
      if(rec) 
        if((i % resolution) == 0) 
          frequencyData = append(frequencyData,  str(fftLin.getBand(i))  );
          
    }
        
    // save json data
    if(rec) 
    {
      
      JSONObject timer = new JSONObject();
                 timer.setString("data", join(frequencyData, ","));
                 timer.setBoolean("isKick", beat.isKick());
                 timer.setBoolean("isSnare", beat.isSnare());
                 timer.setBoolean("isHat", beat.isHat());
      
      data.setJSONObject( nf((int)millis()-currentMillis, 5) , timer );
      
    }

  popMatrix();
  
  // display graphic
  if(display) 
  {
    
      PGraphicsPDF pdf = (PGraphicsPDF)beginRaw(PDF, "data/archiv/"+nf(index,4)+"/"+nf(index,4)+".pdf"); 
        
        geo.display();
                
        // show logo
        noStroke();
        fill(0);
        shape(logo, (width/2)-15, height-60, 30, 40);
        
        // show date
        SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("dd.MM.yyyy");
        
        textMode(SHAPE);
        textSize(7);
        textLeading(8);
        textAlign(RIGHT, CENTER);
        text(DATE_FORMAT.format(date)+"\n No. "+index, 0, height-61, (width/2)-25, 40);
        
        // show name
        textAlign(LEFT, CENTER);
        text("Haldern Pop \nFestival", (width/2)+25, height-61, width, 40);
      
      endRaw();
          
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

/*
void keyPressed() {
  
  if (key == 'n') 
  {
    
  }

}
*/