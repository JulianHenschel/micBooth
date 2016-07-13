import java.util.Arrays;

class Geo {
  
  JSONObject json;
  float maxVal = 0, minVal = 0;
  String[] keys;
  
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
      
      for(int j = 0; j < fd_array.length; j++) 
      {
        if(fd_array[j] > this.maxVal) 
          this.maxVal = fd_array[j];
          
        if(fd_array[j] < this.minVal) 
          this.minVal = fd_array[j];
      }
            
    }
  }

  void display() {

    background(255);
    
    pushMatrix();
    translate(width/2, height/2, 0);
      
      //rotateY(random(0, HALF_PI)); 
      rotateY(frameCount*0.001); 
      rotateX(frameCount*0.001);
      rotateZ(frameCount*0.001);

      float s = 0, s_add = 10;
      float t = 0, t_add = 180/(float)this.json.size();
      
      // init arraylist for line connection
      ArrayList<Vec3D> lc = new ArrayList<Vec3D>();

      // display settings
      float sphereRadius = 400;
      float strokeWeight = 2;
      float strokeHighlightWeight = 10;
    
      for(int i = 0; i < this.json.size(); i++) 
      {
        
        s += s_add;
        t += t_add;
               
        float radianS = radians(s); 
        float radianT = radians(t);
                        
        float thisx = (sphereRadius * cos(radianS) * sin(radianT)); 
        float thisy = (sphereRadius * sin(radianS) * sin(radianT)); 
        float thisz = (sphereRadius * cos(radianT));
        
        pushMatrix();
        translate(thisx, thisy, thisz);
          
          JSONObject data = json.getJSONObject(keys[i]);
          
          // show structure
          if(data.getBoolean("isKick") || data.getBoolean("isSnare") || data.getBoolean("isHat"))
            lc.add( new Vec3D(thisx, thisy, thisz) );
          
          if (lastx != 0 && t > 0) 
          {
            strokeWeight(strokeWeight);
            stroke(0);
            point(0,0,0);
          }
          
          // show details
          float[] details = float(split(data.getString("data"), ','));
          int details_length = details.length;
          float addition = 0;
                  
          for(int d = 0; d < details_length; d++) 
          {
            
            //float value = map(details[d], minVal, maxVal, 0, sphereRadius);
            addition += details[d];
            
            
          }
          
          
        
          lastx = thisx; 
          lasty = thisy; 
          lastz = thisz;
        
        popMatrix();

      } 
      
      // draw connections
      
      stroke(0);
      strokeWeight(strokeHighlightWeight);   
      beginShape();
      
      for(int j = 0; j < lc.size(); j++)
      {
        vertex(lc.get(j).x, lc.get(j).y, lc.get(j).z);
      }
      
      endShape();
        
    popMatrix();
    
  }
  
}