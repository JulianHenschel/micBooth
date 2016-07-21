import java.util.Arrays;

class Geo {
  
  JSONObject json;
  float maxVal = 0, maxAddVal = 0;
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
      }
    } 
    
  }

  void display() {

    background(255);
    
    pushMatrix();
    translate(width/2, (height/2)-50, 0);
      
      rotateY(random(0, HALF_PI)); 
      rotateY(random(0, HALF_PI)); 
      rotateX(random(0, HALF_PI));

      float s = 0, s_add = 10;
      float t = 0, t_add = 180/(float)this.json.size();
      float sphereRadius = 150;
      float radius = 80;
      float radius_add = random(0.3,0.8);

      for(int i = 0; i < this.json.size(); i+=1) 
      {
       
        pushMatrix();
          
          s += s_add;
          t += t_add;
          
          JSONObject data = json.getJSONObject(keys[i]);
                 
          float radianS = radians(s); 
          float radianT = radians(t);
                          
          float thisx = (sphereRadius * cos(radianS) * sin(radianT)); 
          float thisy = (sphereRadius * sin(radianS) * sin(radianT)); 
          float thisz = (sphereRadius * cos(radianT));
          
          boolean mult = false;
        
          rotateX(radians(i+noise(thisx)));
          rotateY(radians(i+noise(thisy)));
          rotateZ(radians(i+noise(thisz)));

          // if "isKick" mult=true
          if(data.getBoolean("isKick") || data.getBoolean("isSnare") || data.getBoolean("isHat")) 
            mult = true;
            
          // draw bezier curves
          float[] details = float(split(data.getString("data"), ','));
          
          beginShape(TRIANGLES);
          
          for (int x = details.length-1; x > 0; x-=1) 
          {  
                          
            float angle = TWO_PI/(float)details.length;
            float value = map(details[x], 0, maxVal, 0.2, 15);
                      
            Vec3D point = new Vec3D((radius/2)*(cos(angle*x)), (radius/2)*(sin(angle*x)), (radius/2)*(cos(angle*x)));                                    
            
            /*
            if(mult) 
            {
              stroke(255,0,0);
              strokeWeight(.1);
              noFill();
              vertex(point.x,point.y,point.z);
            }
            */
            
            strokeWeight(value);
            stroke(0);
            gfx.point(point);
                        
          }
          
          endShape();
        
          lastx = thisx; 
          lasty = thisy; 
          lastz = thisz;
          
          // update radius
          radius += radius_add;
                
        popMatrix();

      }
      
    popMatrix();
    
  }
  
}