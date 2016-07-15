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
      
      //rotateY(random(0, HALF_PI)); 
      //rotateY(random(0, HALF_PI)); 
      //rotateX(random(0, HALF_PI));
      //rotateZ(random(0, HALF_PI));

      float s = 0, s_add = 10;
      float t = 0, t_add = 180/(float)this.json.size();
      
      // init arraylist for line connection
      ArrayList<Vec3D> lc = new ArrayList<Vec3D>();

      // display settings
      float sphereRadius = 200;
      float strokeWeight = 1;
      float strokeHighlightWeight = 5;
      float radius = 100;
      
      for(int i = 0; i < this.json.size(); i+=1) 
      {
        
        radius += 1;
        pushMatrix();
        
        rotateX(radians(i+noise(i)));
        rotateY(radians(i+noise(i)));
        rotateZ(radians(i+noise(i)));
        
          stroke(0);
          strokeWeight(0.01);
          ellipseMode(CENTER);
          ellipse(0,0,radius,radius);

          s += s_add;
          t += t_add;
                 
          float radianS = radians(s); 
          float radianT = radians(t);
                          
          float thisx = (sphereRadius * cos(radianS) * sin(radianT)); 
          float thisy = (sphereRadius * sin(radianS) * sin(radianT)); 
          float thisz = (sphereRadius * cos(radianT));
            
          JSONObject data = json.getJSONObject(keys[i]);
          
          // save vectors to display structure
          if(data.getBoolean("isKick") || data.getBoolean("isSnare") || data.getBoolean("isHat"))
            lc.add( new Vec3D(thisx, thisy, thisz) );
            
          // draw bezier curves
          float[] details = float(split(data.getString("data"), ','));

          for (int x = 0; x < data_length; x+=4) 
          {  
                          
            float angle = TWO_PI/(float)details.length;
            float value = map(details[x], 0, maxVal, 0.01, 30);

                      
            Vec3D point = new Vec3D(
                                    (radius/2)*(cos(angle*x)),
                                    (radius/2)*(cos(angle*x)),
                                    (radius/2)*(sin(angle*x))
                                    );
          
            stroke(0);
            strokeWeight(value);
            gfx.point(point);
                        
          }
        
          lastx = thisx; 
          lasty = thisy; 
          lastz = thisz;
      
        popMatrix();

      } 
      
      // draw connections    
      stroke(0);
      strokeWeight(strokeHighlightWeight);   
      beginShape(TRIANGLE_STRIP);
      
      for(int j = 0; j < lc.size(); j++)
      {
        
        Vec3D center = new Vec3D(0, 0, 0);
        Vec3D dataPoint = lc.get(j).subSelf(center).scaleSelf(1);
                
        //vertex(dataPoint.x, dataPoint.y, dataPoint.z);
        
      }
      
      endShape();
      
    popMatrix();
    
  }
  
}