import java.util.Arrays;

class Geo {
  
  JSONObject json;
  float maxVal = 0, minVal = 0;
  String[] keys;

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
    
    // init new mesh

    
}

  void display() {

    background(255);
    noLoop();
    
    pushMatrix();
    translate(width/2, height/2, 0);
    
      strokeWeight(1);
      stroke(0);
      
      for(int i = 0; i < keys.length; i++) 
      {
        
        
      } 
    
    popMatrix();
    
  }
  
}