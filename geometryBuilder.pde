import java.util.Arrays;

class Geo {
  
  JSONObject json;
  float maxVal = 0, minVal = 0;
  String[] keys;

  Geo() {
    
    
    
  }

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
      
      String frequencyData = data.getString("data");
      float[] fd_array = float(split(frequencyData, ','));
      
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
    
    
    noLoop();
    
  }
  
}