class ButtonLight {
  
  AbstractWave wave;
  float value;
  int mode;
  
  ButtonLight() { 
    
    // init
    this.setMode(1);
    
  }
  
  void update() {

    if(mode == 3) {
      arduino.analogWrite(ledPin, 255);
    }else {
      this.value = map(this.wave.update(),-255,255,0,255);
      arduino.analogWrite(ledPin, (int)value);
    }
    
  }
  
  void setMode(int m) {
    
    this.mode = m;
    
    switch(m) {
      
      case 1:
        this.wave = new FMSineWave(0, 0, 255, 0);
        this.wave.frequency = 0.05;
        break;
        
      case 2:
        this.wave = new FMSquareWave(0, 0, 255, 0);
        this.wave.frequency = 0.2;
        break;
      
    }
  }
  
}