import processing.pdf.*;
import toxi.geom.*;
import toxi.processing.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Arrays;
import cc.arduino.*;
import org.firmata.*;
import processing.serial.*;

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
Arduino              arduino;

/*------------------------------------------------------------------------------------------------------*/

boolean              rec = false;
int                  index;
int                  currentMillis;
int                  ledPin = 8, buttonPin = 7, lastButtonState = 0, buttonPushCounter = 0, buttonState  = 0;
JSONObject           data;
PShape               logo;
PFont                font;
int                  seconds = 6;

/*------------------------------------------------------------------------------------------------------*/

void setup() {
  
  size(550,800,P3D);
  smooth();
  
  // init arduino board
  //println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[1], 57600);
  
  arduino.pinMode(buttonPin, Arduino.INPUT);
  arduino.pinMode(ledPin, Arduino.OUTPUT);
  
  arduino.digitalWrite(ledPin, Arduino.HIGH);
  
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
  
  // read arduino button
  listenToButton();
    
  // set title
  surface.setTitle((int(frameRate) + " fps"));
  
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
        if(!rec)
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
      
      // stop record after x seconds
      if( (millis()-currentMillis)/1000 > seconds ) {
        stopRecord();
      }
      
      // blink led
      if(beat.isKick() || beat.isSnare() || beat.isHat())
        arduino.digitalWrite(ledPin, Arduino.HIGH);
      else
        arduino.digitalWrite(ledPin, Arduino.LOW);
      
    }else {
      arduino.digitalWrite(ledPin, Arduino.HIGH);  
    }

  popMatrix();
  
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

void listenToButton() {
    
  int buttonState = arduino.digitalRead(buttonPin);
    
  if (buttonState != lastButtonState) 
  {
    
    buttonPushCounter++;
    
    if(buttonState == 1)      
      if(buttonPushCounter%2 != 0)
        buttonPushed();
  }
  
  lastButtonState = buttonState;

}

void buttonPushed() {
  
  if(rec) {
    
    rec = false;
    arduino.digitalWrite(ledPin, Arduino.HIGH);
    
  }else {
    
    rec = true;
    println("*** start record");
    
    // set new index
    setNewIndex();
    
    // start recording
    currentMillis = millis();
    
    // init recorder object
    recorder = minim.createRecorder(in, "data/archiv/"+nf(index,4)+"/"+nf(index,4)+".wav");
  
    // start recording
    if(!recorder.isRecording())
      recorder.beginRecord();
    
  }
}

void stopRecord() {
  
  if(rec) 
  {
    
    rec = false;
    println("*** stop record");

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
    geo.loadData(index);
    
    pushMatrix();
    translate(-width/2, -height/2, 0);
    
      // save pdf
      PGraphicsPDF pdf = (PGraphicsPDF)beginRaw(PDF, "data/prints/"+nf(index,4)+".pdf"); 
    
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
      
    popMatrix();
  
  }

}