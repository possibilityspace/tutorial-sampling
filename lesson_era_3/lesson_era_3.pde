/*
  Procedural Generation Lessons - Sampling
 
 In this sketch we're going to take a simple platformer level generator (inspired by the open source examples at marioai.org) and
 then test its behaviour through sampling. We can change settings in the generator and then see the effects of our changes both
 visually, through generated examples, and in automatic analysis of levels!
 
 */

//The size of a map tile, in pixels
int tilesize = 20;

int tx = 0;
int tr = 40;

//The width and height of our level
int levelWidth = 70;
int levelHeight = 15;  

//We'll use this array to store the level itself - each element is a 'block' in the world, like an enemy, solid floor, etc.
int[][] theLevel;


boolean hasSample = false;

//These are some variables to store various bits of info from our analysis.
//As an extension to this example, you could write some code that shows the
//highest/lowest enemy count in a sample, to give the user extra information!
int minEnemies = 0;
int maxEnemies = 0;
float avgEnemies = 0;
int minPups = 0;
int maxPups = 0;
float avgPups = 0;

//We chose 500 for this one because you're running it on a desktop. Feel free to crank it up or down and see what happens!
int sample_size = 500;

//Some regular setup stuff
void setup() {
  //Size of the canvas we're drawing onto
  size(1400, 510);
  //Importing some images (thanks Kenney!)
   tile_dirt = loadImage("tile_dirt.png");
   tile_grass= loadImage("tile_grass.png");
   tile_box = loadImage("tile_box.png");
   tile_start = loadImage("tile_start.png");
   tile_end = loadImage("tile_end.png");
   tile_enemy = loadImage("tile_enemy_2.png");
   tile_enemy_fly = loadImage("tile_enemy.png");
   tile_crate = loadImage("tile_crate.png");
   image_bg = loadImage("bg.png");
   //This generates our starting level
   theLevel = GenerateLinearLevel();
   //Generate an initial sample too
   SampleEnemies(sample_size);
   SamplePowerups(sample_size);
   hasSample = true;
   //I learned about noloop today! It's useful for not making your Processing sketches waste loads of time drawing stuff
   noLoop();
   //And draw everything on the screen
   redraw();
}

//This was used before I added in fancy sprites, it just gets a simple color palette based on a code.
color GetColor(int code){
   switch(code){
     case 0: return color(228,247,255);
     case 1: return color(102,51,0);
     case 2: return color(255,255,51);
     case -1: return color(255,0,0);
     case -2: return color(102,0,204);
     default: return color(0);
   }
}

//Some variables for images. Why are they here? Who knows.
PImage tile_grass;
PImage tile_box;
PImage tile_dirt;
PImage tile_start;
PImage tile_end;
PImage tile_enemy;
PImage tile_enemy_fly;
PImage tile_crate;
PImage image_bg;


boolean showCalculations = false;

//Okay, so this calculates a sample and counts the enemies in it
int[] SampleEnemies(int num){
   //We're taking 'num' samples, so make an array that size
   int[] data = new int[num];

   //We'll use this to count the sum as we go along, and then divide it at the end
   float avg = 0;
   
   //Alright, this is a for loop that runs for the number of samples we want to take.
   for(int i=0; i<num; i++){
       //We generate a level, count the enemies in it, and then store that in our array
       data[i] = CountEnemies(GenerateLinearLevel());
       //We also add the count to our running total
       //We don't actually need to record a big array of data, but it's useful here in case you want to do
       //more analysis on the data itself, so I've left it here in case you extend it
       avg += data[i]; 
   }
   //Average = sum / num
   avg = avg / num;
   
   avgEnemies = avg;
   
   return data;
}

//I won't comment this one - it's the same as SampleEnemies, but for powerup blocks!
int[] SamplePowerups(int num){
   int[] data = new int[num];
   
   float avg = 0;
   
   for(int i=0; i<num; i++){
       data[i] = CountPowerups(GenerateLinearLevel());
       avg += data[i]; 
   }
   avg = avg / num;
   
   avgPups = avg;
   
   return data;
}

//Simple little helper methods that go through a level, and count every time they see the code that refers to powerups/enemies
//As a general rule, my software engineering in these examples is not great. Here, we could write a more compact single function
//that counts 'something' and you pass an argument telling it which 'something' to count. But I like this becuase it's clearer and
//more readable for a tutorial. 
int CountPowerups(int[][] level){
  int count = 0;
  for(int i=0; i<levelWidth; i++){
     for(int j=0; j<levelHeight; j++){
       if(level[i][j] == CODE_BLOCK){
           count++;
       }
     }
  }
  return count;
}

int CountEnemies(int[][] level){
  int count = 0;
  for(int i=0; i<levelWidth; i++){
     for(int j=0; j<levelHeight; j++){
       if(level[i][j] == CODE_ENEMY){
           count++;
       }
     }
  }
  return count;
}

//This is a load of stuff to make it look nice, feel free to skip over this.
void draw() {
  background(255, 255, 255);
  
  //Background stuff
  fill(GetColor(0));
  stroke(0);
  rect(tx-1, tr-1, tilesize*levelWidth+1, tilesize*levelHeight+1);
  
  noStroke();

  //Nice tiled background
  for(int i=0; i<levelWidth; i++){
    if(i % levelHeight == 0){
       image(image_bg, tx+(i*tilesize), tr, tilesize*levelHeight, tilesize*levelHeight); 
    }
  }

  //Go over the level, draw a tile for each block type
  for(int i=0; i<levelWidth; i++){
     for(int j=0; j<levelHeight; j++){
          fill(GetColor(theLevel[i][j]));
          //rect(tx+i*tilesize, j*tilesize+tr, tilesize, tilesize);

         if(theLevel[i][j] == 1){
          if((j == 0 || theLevel[i][j-1] != 1)){
             image(tile_grass, tx+i*tilesize, j*tilesize+tr, tilesize, tilesize);
          }
           else{
             image(tile_dirt, tx+i*tilesize, j*tilesize+tr, tilesize, tilesize);
          }
         }
         else if(theLevel[i][j] == 2){
            image(tile_box, tx+i*tilesize, j*tilesize+tr, tilesize, tilesize);
         }
         else if(theLevel[i][j] == 3){
            image(tile_crate, tx+i*tilesize, j*tilesize+tr, tilesize, tilesize); 
         }
         else if(theLevel[i][j] == CODE_START){
            blend(tile_start, 0, 0, 128, 128, tx+i*tilesize, j*tilesize+tr, tilesize, tilesize, BLEND);
         }
         else if(theLevel[i][j] == CODE_END){
           //rect(tx+i*tilesize, j*tilesize+tr, tilesize, tilesize);
            image(tile_end, tx+i*tilesize, j*tilesize+tr, tilesize, tilesize);
         }
         else if(theLevel[i][j] == CODE_ENEMY){
           if(theLevel[i][j+1] == 0){
             image(tile_enemy_fly, tx+i*tilesize, j*tilesize+tr, tilesize, tilesize);
           }
           else{
             image(tile_enemy, tx+i*tilesize, j*tilesize+tr, tilesize, tilesize);
           }          
         }
     }
  }
  
  //Some header text
  fill(0, 0, 0);
  textSize(12);
  textAlign(LEFT, CENTER);
  text("Procedural Generation Lessons: Sampling", tilesize, tilesize);
  textAlign(RIGHT, CENTER);
  text("www.possibilityspace.org", tilesize*levelWidth-tilesize, tilesize);
 
  
  int top = tilesize*levelHeight+tilesize*2+10;
  
  //This is all UI for the controls
  textSize(16);
  textAlign(LEFT, CENTER);
 
    fill(200,200,255);
    rect(tilesize-10, top, 500, 150);
    
    textAlign(CENTER, CENTER);
  if(hasSample){
    fill(0);
    textSize(16);
    text("Results (from 500 level samples)", 250, top+tilesize);
    
    textAlign(LEFT, CENTER);
    //text("Minimum no. of enemies: "+minEnemies, tilesize, top + tilesize*3);
    image(tile_enemy, tilesize*2, top+tilesize*3-15, tilesize*2, tilesize*2);
    //image(tile_enemy_fly, tilesize*2, top+tilesize*3-7, tilesize, tilesize);
    text("Average number of enemies: "+avgEnemies, tilesize*5, top + tilesize*3);
    //text("Maximum no. of enemies: "+maxEnemies, tilesize, top + tilesize*5);
    
    image(tile_box, tilesize*2, top+tilesize*5-7, tilesize*2, tilesize*2);
    //image(tile_box, tilesize*2, top+tilesize*5-7, tilesize, tilesize);
    //text("Minimum no. of powerups: "+minPups, tilesize, top + tilesize*7);
    text("Average number of powerups: "+avgPups, tilesize*5, top + tilesize*5.5);
    //text("Maximum no. of powerups: "+maxPups, tilesize, top + tilesize*9);
  }
  else{
    fill(0);
    textSize(12);
    text("(Press E to analyse the generator)", 250, top+75);
  }
   
  int left = 1400 - tilesize+10 - 900;
  top = tilesize*levelHeight+tilesize*2-10 + tilesize;
  
  fill(255,200,200);
  rect(1400 - tilesize+10 - 900, top, 900, 150);
  
  fill(0);
  
  textAlign(CENTER, CENTER);
  textSize(16);
  text("Generator Settings", left + 450, top+tilesize*1);
  textSize(10);
  text("(Press R to generate new levels with the same settings)", left + 450, top+tilesize*2);
  textSize(16);
  
  textAlign(LEFT, CENTER);
  text("[Q/W] - Enemy Spawn Chance (Currently: "+percent(CHANCE_SPAWN_ENEMY)+"%)", left + tilesize, top+tilesize*4);
  
  text("[A/S] - Powerup Spawn Chance (Currently: "+percent(CHANCE_SPAWN_POWERUP)+"%)", left+tilesize, top+tilesize*6);
  
  text("[O/P] - Gap Chance (Currently: "+percent(CHANCE_TO_ADD_GAP)+"%)", left+450+tilesize, top+tilesize*4);
  
  text("[K/L] - Height Change Chance (Currently: "+percent(CHANCE_TO_CHANGE_HEIGHT)+"%)", left+450+tilesize, top+tilesize*6);
}

//A helper method to display a percentage nicely
String percent(float f){
   return (round(f*100))+""; 
}

//Some variable values, again for the UI, don't worry
float[][] pvals = new float[][]{
    new float[]{0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0},
    new float[]{0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0},
    new float[]{0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0},
    new float[]{0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0},
};

//This storeos the currently selected setting (and, thus, the initial settings)
int[] vals = new int[]{
    1,5,4,6
};

//More UI/interaction stuff
public void ChangeParam(int p, int c){
    int nv = vals[p] + c;
    
   if(nv >= 0 && nv < pvals[p].length){
        vals[p] += c;
         SetValue(p);
    } 
}

//Input
void keyPressed() {
 
  if(key == 'q'){
     ChangeParam(0, -1); 
  }
  if(key == 'w'){
    ChangeParam(0, +1); 
  }
  
  if(key == 'a'){
     ChangeParam(1, -1); 
  }
  if(key == 's'){
    ChangeParam(1, +1); 
  }
  
   if(key == 'o'){
     ChangeParam(2, -1); 
  }
  if(key == 'p'){
    ChangeParam(2, +1); 
  }
  
  if(key == 'k'){
     ChangeParam(3, -1); 
  }
  if(key == 'l'){
    ChangeParam(3, +1); 
  }
  
  //R - Regenerate a new map
  if (key == 'r') {
    //map = generateMapUsingCellularAutomata(mapsize);
    theLevel = GenerateLinearLevel();
    redraw();
  }
  
}

//Sets parameters when a change is made. Note we also call the Sample method to automatically resample.
void SetValue(int selectedParameter){
   switch(selectedParameter){
          case 0:
            CHANCE_SPAWN_ENEMY = pvals[selectedParameter][vals[selectedParameter]]; break;
          case 1:
            CHANCE_SPAWN_POWERUP = pvals[selectedParameter][vals[selectedParameter]]; break;
          case 2:
            CHANCE_TO_ADD_GAP = pvals[selectedParameter][vals[selectedParameter]]; break;
          case 3:
            CHANCE_TO_CHANGE_HEIGHT = pvals[selectedParameter][vals[selectedParameter]]; break;
       } 
     SampleEnemies(500);
     SamplePowerups(500);
     theLevel = GenerateLinearLevel();
     redraw();
     
}
