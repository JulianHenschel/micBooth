import java.util.Arrays;

class Geo {
  
  JSONObject json;
  float maxVal = 0, maxAddVal = 0;
  String[] keys;
  int data_length = 0;
  
  float lastx = 0; 
  float lasty = 0; 
  float lastz = 0;
  
  Geo() { }

  void loadData(int i) {
        
    json = loadJSONObject("data/archiv/"+nf(i,4)+"/data.json");
    
    this.keys = (String[]) json.keys().toArray(new String[json.size()]);    
    Arrays.sort(this.keys);
    
    this.preProcessData();
        
  }
  
  // define min and max values for data viz
  void preProcessData() {
        
    for(int i = 0; i < this.json.size(); i++) 
    {

      JSONObject data = json.getJSONObject(keys[i]);
      float[] fd_array = float(split(data.getString("data"), ','));
      
      this.data_length = fd_array.length;
      
      for(int j = 0; j < fd_array.length; j++) 
      {
        if(fd_array[j] > this.maxVal) 
          this.maxVal = fd_array[j];
      }
    } 
    
  }

  void display() {

    background(255);
    
    pushMatrix();
    translate(width/2, height/2, 0);
      
      rotateY(random(0, HALF_PI)); 
      rotateY(random(0, HALF_PI)); 
      rotateX(random(0, HALF_PI));

      float s = 0, s_add = 10;
      float t = 0, t_add = 180/(float)this.json.size();
      
      // init arraylist for line connection
      ArrayList<Vec3D> lc = new ArrayList<Vec3D>();

      // display settings
      float sphereRadius = 150;
      float radius = 80;
      
      for(int i = 0; i < this.json.size(); i+=1) 
      {
       
        pushMatrix();
          
          s += s_add;
          t += t_add;
                 
          float radianS = radians(s); 
          float radianT = radians(t);
                          
          float thisx = (sphereRadius * cos(radianS) * sin(radianT)); 
          float thisy = (sphereRadius * sin(radianS) * sin(radianT)); 
          float thisz = (sphereRadius * cos(radianT));
        
          rotateX(radians(i+noise(thisx)));
          rotateY(radians(i+noise(thisy)));
          rotateZ(radians(i+noise(thisz)));
        
          stroke(0);
          strokeWeight(.1);
          ellipseMode(CENTER);
          
          if( (i % 3) == 0) {
            ellipse(0,0,radius,radius);
          }

          JSONObject data = json.getJSONObject(keys[i]);
          
          boolean mult = false;
          
          // save vectors to display structure
          if(data.getBoolean("isKick") || data.getBoolean("isSnare") || data.getBoolean("isHat"))
            mult = true;
            
          // draw bezier curves
          float[] details = float(split(data.getString("data"), ','));

          for (int x = details.length-1; x > 0; x-=2) 
          {  
                          
            float angle = TWO_PI/(float)details.length;
            float value = map(details[x], 0, maxVal, 0.1, 20);
                      
            Vec3D point = new Vec3D(
                                    (radius/2)*(cos(angle*x)),
                                    (radius/2)*(sin(angle*x)),
                                    (radius/2)*(cos(angle*x))
                                    );                                    
            if(mult)
              strokeWeight(value*3);
            else 
              strokeWeight(value);
            
            stroke(0);
            gfx.point(point);
                        
          }
        
          lastx = thisx; 
          lasty = thisy; 
          lastz = thisz;
          
          // update radius
          radius+=0.5;
                
        popMatrix();

      }
      
    popMatrix();
    
  }
  
}